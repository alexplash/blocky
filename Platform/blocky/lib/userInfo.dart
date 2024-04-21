import 'dart:typed_data';
import 'package:blocky/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'main.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  final AuthService authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  String? currentUsername;
  String? currentUserType;
  String userType = '';
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  String errorMessage = '';
  bool isLoading = true;

  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    var userDoc = await firestoreConnect.returnCurrentUserDocument();
    if (userDoc != null) {
      setState(() {
        currentUsername = userDoc['username'];
        _usernameController.text = userDoc['username'];
        userType = userDoc['userType'];
        currentUserType = userDoc['userType'];
      });

      if (userDoc['profileImageUrl'].isNotEmpty) {
        String storageUrl = userDoc['profileImageUrl'];
        final ref = FirebaseStorage.instance.refFromURL(storageUrl);
        String actualImageUrl = await ref.getDownloadURL();
        setState(() {
          profileImageUrl = actualImageUrl;
        });
        print(actualImageUrl);
      }
    }
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageBytes = await image.readAsBytes();
      setState(() {
        profileImageBytes = imageBytes;
      });
    }
  }

  ImageProvider<Object>? getImageProvider() {
    if (profileImageBytes != null) {
      return MemoryImage(profileImageBytes!);
    } else if (profileImageUrl != null) {
      return NetworkImage(profileImageUrl!);
    }
    return null;
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: getImageProvider(), // Default placeholder
        child: profileImageBytes == null && profileImageUrl == null
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    width: 120,
                    height: 120,
                  ),
                  const Icon(Icons.person, color: Colors.white60, size: 60),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 15),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: Color.fromARGB(255, 17, 0, 47),
          body: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 17, 0, 47),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Image.asset(
                  'assets/images/main_icon.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  margin:
                      const EdgeInsets.only(left: 40.0, right: 40.0, top: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 30),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authService.signOut();
                              Navigator.of(context)
                                  .popUntil((route) => route.isFirst);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                  color: Colors.white, width: 2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Log out',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Text(
                        'User Info',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Debis',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _buildProfileImage(),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _usernameController,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            labelText: "Username",
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            hintStyle: TextStyle(
                              color: Colors.white54,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: userType == 'Data Provider'
                                      ? Colors.blue
                                      : const Color.fromARGB(255, 40, 33, 183),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Data Provider',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Debis',
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Market and distribute your unique work to the community of Blocky.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: userType == 'Data Seeker'
                                      ? Colors.blue
                                      : const Color.fromARGB(255, 40, 33, 183),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12.0),
                                ),
                                child: const Column(
                                  children: [
                                    Text(
                                      'Data Seeker',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Debis',
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Access quality data for your needs: custom datasets, work samples, or artpieces.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: updateProfile,
                        child: const Text("Update Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Debis',
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 40, 33, 183),
                          minimumSize: const Size(150, 48),
                        ),
                      ),
                      if (errorMessage.isNotEmpty)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    String newUsername = _usernameController.text;
    if (newUsername.isEmpty) {
      setState(() {
        errorMessage = "Username can't be empty";
      });
      return;
    }
    if (newUsername != currentUsername) {
      bool isTaken = await firestoreConnect.isUsernameTaken(newUsername);
      if (isTaken) {
        setState(() {
          errorMessage = 'Username already exists';
        });
        return;
      }
    }

    String? newProfileImageUrl = profileImageUrl;
    if (profileImageBytes != null) {
      if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
        try {
          final oldRef = FirebaseStorage.instance.refFromURL(profileImageUrl!);
          await oldRef.delete();
        } catch (e) {
          print("Error deleting old profile image: $e");
        }
      }

      newProfileImageUrl = await firestoreConnect.uploadProfileImage(
          profileImageBytes!, newUsername);
      if (newProfileImageUrl == null) {
        setState(() {
          errorMessage = 'Failed to upload image';
        });
        return;
      }
    }

    setState(() {
      isLoading = true;
    });

    await firestoreConnect.updateUserProfile(currentUsername!, newUsername,
        currentUserType!, userType, newProfileImageUrl ?? "");

    setState(() {
      errorMessage = '';
      currentUsername = newUsername;
      profileImageUrl = newProfileImageUrl;
      currentUserType = userType;
    });

    await Future.delayed(const Duration(seconds: 1));
    await authService.signOut();
    appKey.currentState?.popUntil((route) => route.isFirst);
    appKey = GlobalKey<NavigatorState>();
    runApp(MyApp(key: appKey));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
