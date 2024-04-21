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

  Future<String?> uploadProfileImage(
      Uint8List fileBytes, String username) async {
    String fileName =
        "${Path.basename(username)}_${DateTime.now().millisecondsSinceEpoch}.jpg";
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
    DocumentSnapshot snapshot =
        await firestore.collection('usernames').doc(username).get();
    return snapshot.exists;
  }

  Future<void> updateUserProfile(String oldUsername, String newUsername,
      String oldUserType, String newUserType, String profileImageUrl) async {
    String? uid = auth.currentUser?.uid;
    if (uid == null) return;

    if (oldUserType == 'Data Provider' && newUserType == 'Data Seeker') {
      var providerInfo = await getProviderInfo(uid);
      if (providerInfo != null) {
        String category = providerInfo['category'] ?? '';
        List<String> subcategories = providerInfo['sub']?.split(', ') ?? [];
        if (category != '' && subcategories.isNotEmpty) {
          await removeFromCategories(uid, subcategories, category);
        }
      }
    }

    await firestore.collection('usernames').doc(oldUsername).delete();
    await firestore
        .collection('usernames')
        .doc(newUsername)
        .set({'username': newUsername});

    String oldUserTypeCollection =
        oldUserType == 'Data Provider' ? 'data_providers' : 'data_seekers';
    String newUserTypeCollection =
        newUserType == 'Data Provider' ? 'data_providers' : 'data_seekers';

    if (oldUserTypeCollection != newUserTypeCollection) {
      await firestore.collection(oldUserTypeCollection).doc(uid).delete();
    }

    await firestore.collection(newUserTypeCollection).doc(uid).set({
      'username': newUsername,
      'userType': newUserType,
      'profileImageUrl': profileImageUrl
    }, SetOptions(merge: true));
  }

  Future<void> addUserToDatabase(
      String username, String userType, String profileImageUrl) async {
    String? uid = auth.currentUser?.uid;
    if (uid != null) {
      await firestore
          .collection('usernames')
          .doc(username)
          .set({'username': username});
      String collection =
          userType == 'Data Provider' ? 'data_providers' : 'data_seekers';
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

    DocumentSnapshot providerSnapshot =
        await firestore.collection('data_providers').doc(currentUser.uid).get();
    if (providerSnapshot.exists) {
      return providerSnapshot.data() as Map<String, dynamic>;
    }

    DocumentSnapshot seekerSnapshot =
        await firestore.collection('data_seekers').doc(currentUser.uid).get();
    if (seekerSnapshot.exists) {
      return seekerSnapshot.data() as Map<String, dynamic>;
    }

    return null;
  }

  Future<Map<String, List<String>>> fetchCategoryProviders(
      String categoryName) async {
    Map<String, List<String>> categoryMap = {};
    String formattedCategory = categoryName.toLowerCase().replaceAll(' ', '_');

    try {
      DocumentSnapshot subCategoryDoc = await firestore
          .collection('subCategoryNames')
          .doc(formattedCategory)
          .get();
      if (!subCategoryDoc.exists || subCategoryDoc.data() == null) {
        print("No subcategory information available for $categoryName");
        return categoryMap;
      }

      Map<String, dynamic> subCategoriesData =
          subCategoryDoc.data()! as Map<String, dynamic>;
      List<String> subCollectionNames = subCategoriesData.keys
          .where((k) => subCategoriesData[k] == 1)
          .toList();

      DocumentReference categoryDocRef =
          firestore.collection('categories').doc(formattedCategory);

      for (String subCollectionName in subCollectionNames) {
        CollectionReference subRef =
            categoryDocRef.collection(subCollectionName);
        QuerySnapshot snapshot = await subRef.get();
        List<String> userIds = snapshot.docs.map((doc) => doc.id).toList();
        categoryMap[subCollectionName] = userIds;
      }
    } catch (e) {
      print('An error occurred while fetching category providers: $e');
    }

    return categoryMap;
  }

  Future<Map<String, dynamic>?> getProviderInfo(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await firestore.collection('data_providers').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      } else {
        print("No data found for user ID: $userId");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

  Future<void> removeFromCategories(
      String userId, List<String> subcategories, String category) async {
    String formattedCategory = category.toLowerCase().replaceAll(' ', '_');
    DocumentReference categoryRef =
        firestore.collection('categories').doc(formattedCategory);
    List<String> emptySubcategories = [];

    for (String subcategory in subcategories) {
      DocumentReference subRef =
          categoryRef.collection(subcategory).doc(userId);
      await subRef.delete();
      QuerySnapshot snapshot = await categoryRef.collection(subcategory).get();
      if (snapshot.docs.isEmpty) {
        emptySubcategories.add(subcategory);
      }
    }

    if (emptySubcategories.isNotEmpty) {
      DocumentReference subCategoryNamesRef =
          firestore.collection('subCategoryNames').doc(formattedCategory);
      Map<String, dynamic> updates = {};
      for (String emptySub in emptySubcategories) {
        updates[emptySub] = FieldValue.delete();
      }
      await subCategoryNamesRef.update(updates);
    }
  }

  Future<void> addToCategories(
      String userId, List<String> subcategories, String category) async {
    String formattedCategory = category.toLowerCase().replaceAll(' ', '_');
    DocumentReference categoryRef =
        firestore.collection('categories').doc(formattedCategory);
    DocumentReference subCategoryNamesRef =
        firestore.collection('subCategoryNames').doc(formattedCategory);

    DocumentSnapshot subCategoryDoc = await subCategoryNamesRef.get();
    Map<String, dynamic> subCategoryData = {};
    if (subCategoryDoc.data() != null) {
      subCategoryData = subCategoryDoc.data() as Map<String, dynamic>;
    }
    Map<String, dynamic> updates = {};
    for (String sub in subcategories) {
      if (!subCategoryData.containsKey(sub) || subCategoryData[sub] != 1) {
        updates[sub] = 1;
      }
    }
    if (updates.isNotEmpty) {
      await subCategoryNamesRef.set(updates, SetOptions(merge: true));
    }

    for (String subcategory in subcategories) {
      DocumentReference subRef =
          categoryRef.collection(subcategory).doc(userId);
      await subRef.set({'active': true});
    }
  }

  Future<void> updateProviderCategories(
      String userId, List<String> sub, String category) async {
    DocumentReference userRef =
        firestore.collection('data_providers').doc(userId);
    String subString = sub.join(', ');

    await userRef.update({'category': category, 'sub': subString});
  }

  Future<void> addToSeekerMailbox(String senderId, String receiverId) async {
    DocumentReference sentRef = firestore
        .collection('data_seekers')
        .doc(senderId)
        .collection('mailbox')
        .doc(receiverId);
    await sentRef.set({'mailbox': true}, SetOptions(merge: true));
  }

  Future<void> removeFromSeekerMailbox(
      String senderId, String receiverId) async {
    DocumentReference sentRef = firestore
        .collection('data_seekers')
        .doc(senderId)
        .collection('mailbox')
        .doc(receiverId);
    try {
      await firestore.runTransaction((transaction) async {
        transaction.delete(sentRef);
      });
    } catch (e) {
      print("Error deleting documents: $e");
    }
  }

  Future<Map<String, dynamic>?> returnSeekerMailbox(senderId) async {
    DocumentReference seekerRef =
        firestore.collection('data_seekers').doc(senderId);
    CollectionReference sentRequestsRef = seekerRef.collection('mailbox');
    QuerySnapshot snapshot = await sentRequestsRef.get();

    Map<String, dynamic> requests = {};
    for (var doc in snapshot.docs) {
      requests[doc.id] = doc.get('mailbox') as bool;
    }

    return requests;
  }

  Future<void> saveAgentConfiguration(String userId, Map<String, dynamic> configData) async {
    DocumentReference userRef =
        firestore.collection('data_providers').doc(userId);
    List<Future> tasks = [];

    configData.forEach((key, value) {
      DocumentReference agentConfigRef =
          userRef.collection('agentConfig').doc(key);
      var task = agentConfigRef.set({'answer': value}, SetOptions(merge: true));
      tasks.add(task);
    });

    try {
      await Future.wait(tasks);
    } catch (e) {
      print('Error saving configuration: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> returnAgentConfiguration(String userId) async {
    CollectionReference agentConfigRef = firestore.collection('data_providers').doc(userId).collection('agentConfig');
    QuerySnapshot agentConfigSnapshot = await agentConfigRef.get();

    if (agentConfigSnapshot.docs.isEmpty) {
      return null;
    }
    
    Map<String, dynamic> configData = {};
    for (var doc in agentConfigSnapshot.docs) {
      configData[doc.id] = doc.get('answer');
    }
    return configData;
  }
}
