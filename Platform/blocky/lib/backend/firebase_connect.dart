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
}