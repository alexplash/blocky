import 'package:flutter/material.dart';
import 'backend/firebase_options.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_connect.dart';
import 'dataProv_quest.dart';
import 'dataSeek_prompt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: defaultFirebaseOptions);
  runApp(MyApp(key: appKey));
}

GlobalKey<NavigatorState> appKey = GlobalKey();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appKey,
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.active) {
            User? user = userSnapshot.data;
            if (user != null) {
              return FutureBuilder<Map<String, dynamic>?>(
                future: FirestoreConnect().returnCurrentUserDocument(),
                builder: (context, docSnapshot) {
                  if (docSnapshot.connectionState != ConnectionState.done) {
                    return const Scaffold(
                      backgroundColor: Color.fromARGB(255, 17, 0, 47),
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }
                  Map<String, dynamic>? userDoc = docSnapshot.data;
                  if (userDoc!['username'].isEmpty || userDoc['username'] == null) {
                    return const ChooseUserInfoPage();
                  } else if (userDoc['userType'] == 'Data Provider') {
                    return DataProviderQuestionsPage();
                  } else if (userDoc['userType'] == 'Data Seeker') {
                    return DataSeekerPromptPage();
                  } else {
                    return const LoginPage();
                  }
                },
              );
            } else {
              return const LoginPage();
            }
          } else {
            return const Scaffold(
              backgroundColor: Color.fromARGB(255, 17, 0, 47),
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String loginErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 0, 47),
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
                margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: attemptLogin,
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Debis',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                minimumSize: Size(150, 48),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        const CreateAccountPage(),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                  ),
                                );
                              },
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Debis',
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(255, 40, 33, 183),
                                minimumSize: Size(150, 48),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (loginErrorMessage.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            loginErrorMessage,
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

  void attemptLogin() async {
    setState(() {
      loginErrorMessage = '';
    });

    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      dynamic result = await _authService.signInWithEmailAndPassword(
          _emailController.text, _passwordController.text);
      if (result != null) {
        print('Logged In');
      } else {
        setState(() {
          loginErrorMessage = 'Incorrect credentials';
        });
      }
    } else {
      setState(() {
        loginErrorMessage = 'Please fill in all fields';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();
  String createAccountErrorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 17, 0, 47),
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
                margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
                      ),
                    ),
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: attemptCreateAccount,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Debis',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 40, 33, 183),
                        minimumSize: Size(150, 48),
                      ),
                    ),
                    if (createAccountErrorMessage.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            createAccountErrorMessage,
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

  Future<void> attemptCreateAccount() async {
    setState(() {
      createAccountErrorMessage = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        createAccountErrorMessage = 'Passwords do not match';
      });
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print("Account created");

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ChooseUserInfoPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          createAccountErrorMessage = 'The email address is not valid.';
          break;
        case 'email-already-in-use':
          createAccountErrorMessage = 'The email address is already in use.';
          break;
        case 'operation-not-allowed':
          createAccountErrorMessage =
              'Email and password accounts are not enabled.';
          break;
        case 'weak-password':
          createAccountErrorMessage = 'The password is too weak.';
          break;
        case 'network-request-failed':
          createAccountErrorMessage = 'Network error, please try again later.';
          break;
        case 'too-many-requests':
          createAccountErrorMessage =
              'Too many requests. Please try again later.';
          break;
        default:
          createAccountErrorMessage = 'An undefined Error happened.';
      }
    } catch (e) {
      createAccountErrorMessage = 'An error occurred. Please try again.';
    }

    if (createAccountErrorMessage.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class ChooseUserInfoPage extends StatefulWidget {
  const ChooseUserInfoPage({Key? key}) : super(key: key);

  @override
  _ChooseUserInfoPageState createState() => _ChooseUserInfoPageState();
}

class _ChooseUserInfoPageState extends State<ChooseUserInfoPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  TextEditingController _usernameController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  String userType = '';
  Uint8List? profileImageBytes;
  String profileImageUrl = '';
  String errorMessage = '';

  Future<void> pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageData = await pickedFile.readAsBytes();
      setState(() {
        profileImageBytes = imageData;
      });
    }
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade800,
        child: profileImageBytes != null
            ? ClipOval(
                child: Image.memory(
                  profileImageBytes!,
                  fit: BoxFit.cover,
                  width: 120,
                  height: 120,
                ),
              )
            : Stack(
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
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                margin: const EdgeInsets.only(left: 40.0, right: 40.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProfileImage(),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Username",
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        fillColor: Colors.grey[900],
                        filled: true,
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
                              onPressed: () =>
                                  setState(() => userType = 'Data Provider'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: userType == 'Data Provider'
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 40, 33, 183),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
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
                              onPressed: () =>
                                  setState(() => userType = 'Data Seeker'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: userType == 'Data Seeker'
                                    ? Colors.blue
                                    : const Color.fromARGB(255, 40, 33, 183),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
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
                    SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: finishButton,
                      child: const Text(
                        'Finish',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Debis',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 40, 33, 183),
                        minimumSize: Size(150, 48),
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

  Future<void> finishButton() async {
    setState(() {
      errorMessage = '';
    });

    if (_usernameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a username.';
      });
      return;
    }

    bool isTaken =
        await firestoreConnect.isUsernameTaken(_usernameController.text);
    if (isTaken) {
      setState(() {
        errorMessage = 'Username is already taken.';
      });
      return;
    }

    if (userType.isEmpty) {
      setState(() {
        errorMessage = 'Please select a user type.';
      });
      return;
    }

    if (profileImageBytes != null) {
      profileImageUrl = await firestoreConnect.uploadProfileImage(
              profileImageBytes!, _usernameController.text) ??
          '';
      if (profileImageUrl.isEmpty) {
        setState(() {
          errorMessage = 'Failed to upload profile image.';
        });
        return;
      }
    }

    await firestoreConnect.addUserToDatabase(
        _usernameController.text, userType, profileImageUrl);

    Widget nextPage = userType == 'Data Provider'
        ? DataProviderQuestionsPage()
        : DataSeekerPromptPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
