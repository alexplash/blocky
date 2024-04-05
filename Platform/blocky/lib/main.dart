import 'package:flutter/material.dart';
import 'backend/firebase_options.dart';
import 'backend/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: defaultFirebaseOptions);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return const LoginPage();
            }
            return MyHomePage();
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to the Main Page!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are now signed in.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _authService.signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
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
                  borderRadius: BorderRadius.circular(12),
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
                        hintStyle: TextStyle(color: Colors.grey[500]),
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
                              child: const Text('Login'),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.deepPurple,
                                onPrimary: Colors.white,
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
                              child: const Text('Create Account'),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromARGB(255, 40, 33, 183),
                                onPrimary: Colors.white,
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
                                color: Colors.red, fontSize: 14),
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
                  borderRadius: BorderRadius.circular(12),
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
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        hintStyle: TextStyle(color: Colors.grey[500]),
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
                      child: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 40, 33, 183),
                        onPrimary: Colors.white,
                        minimumSize: Size(150, 48),
                      ),
                    ),
                    if (createAccountErrorMessage.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            createAccountErrorMessage,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 14),
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
      createAccountErrorMessage =
          '';
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
      setState(() {
        
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
