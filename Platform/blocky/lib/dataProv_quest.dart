import 'package:flutter/material.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_connect.dart';
import 'userInfo.dart';

class DataProviderQuestionsPage extends StatefulWidget {
  DataProviderQuestionsPage({Key? key}) : super(key: key);

  @override
  _DataProviderQuestionsPageState createState() => _DataProviderQuestionsPageState();
}

class _DataProviderQuestionsPageState extends State<DataProviderQuestionsPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  final TextEditingController _questionController = TextEditingController();

  final List<String> dataOptions = [
    "Writing",
    "Graphic",
    "Music",
    "Stock Market",
    "Energy",
    "CyberSecurity",
    "Automotive",
    "E-commerce",
    "Agriculture",
    "Machine Learning",
    "Blockchain",
    "Telecommunications",
    "Healthcare",
    "Fashion",
    "Quantum Computing",
    "Biotech",
    "Gaming",
    "Urban Planning",
  ];

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
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.account_circle,
                            color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    UserInfoPage(),
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
                        ),
                      ),
                    ),
                    const Text(
                      'Data Provider',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Debis',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _questionController,
                      maxLines: 4,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText:
                            "Be more specific. Go into detail about the types of content and/or data you specialize in.",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        fillColor: Colors.grey[850],
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Implement the search functionality here
                      },
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Debis',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 40, 33, 183),
                        minimumSize: Size(150, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
