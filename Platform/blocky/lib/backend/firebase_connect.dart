import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as Path;

class FirestoreConnect {
  FirestoreConnect._internal();
  static final FirestoreConnect _instance = FirestoreConnect._internal();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  factory FirestoreConnect() {
    return _instance;
  }

  Future<String?> uploadProfileImage(Uint8List fileBytes, String username) async {
    String fileName = "${Path.basename(username)}_${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = storage.ref().child('profileImages/$fileName');

    try {
      UploadTask uploadTask = ref.putData(fileBytes);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    DocumentSnapshot snapshot = await firestore.collection('usernames').doc(username).get();
    return snapshot.exists;
  }

  Future<void> updateUserProfile(String oldUsername, String newUsername, String oldUserType, String newUserType, String profileImageUrl) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) return;

    await firestore.collection('usernames').doc(oldUsername).delete();
    await firestore.collection('usernames').doc(newUsername).set({'username': newUsername});

    String oldUserTypeCollection = oldUserType == 'Data Provider' ? 'data_providers' : 'data_seekers';
    String newUserTypeCollection = newUserType == 'Data Provider' ? 'data_providers' : 'data_seekers';

    if (oldUserTypeCollection != newUserTypeCollection) {
      await firestore.collection(oldUserTypeCollection).doc(uid).delete();
    }
    
    await firestore.collection(newUserTypeCollection).doc(uid).set({
      'username': newUsername,
      'userType': newUserType,
      'profileImageUrl': profileImageUrl
    }, SetOptions(merge: true));
  }

  Future<void> addUserToDatabase(String username, String userType, String profileImageUrl) async {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      await firestore.collection('usernames').doc(username).set({'username': username});
      String collection = userType == 'Data Provider' ? 'data_providers' : 'data_seekers';
      await firestore.collection(collection).doc(uid).set({
        'username': username,
        'userType': userType,
        'profileImageUrl': profileImageUrl,
      });
    }
  }

  Future<Map<String, dynamic>?> returnCurrentUserDocument() async {
    User? currentUser = auth.currentUser;
    if (currentUser == null) {
      return null;
    }

    DocumentSnapshot providerSnapshot = await firestore.collection('data_providers').doc(currentUser.uid).get();
    if (providerSnapshot.exists) {
      return providerSnapshot.data() as Map<String, dynamic>;
    }

    DocumentSnapshot seekerSnapshot = await firestore.collection('data_seekers').doc(currentUser.uid).get();
    if (seekerSnapshot.exists) {
      return seekerSnapshot.data() as Map<String, dynamic>;
    }

    return null;
  }
}