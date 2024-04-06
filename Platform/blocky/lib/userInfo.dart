import 'package:flutter/material.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_connect.dart';
import 'userInfo.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key? key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  final AuthService authService = AuthService();

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
                            primary: Colors.white,
                            side: BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Log out',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    Text(
                      'User Info',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Debis',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(),
                    const SizedBox(height: 20),
                    Container(),
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
