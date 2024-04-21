import 'package:blocky/dataProv_configAgent.dart';
import 'package:flutter/material.dart';
import 'backend/auth_service.dart';
import 'backend/firebase_connect.dart';
import 'userInfo.dart';
import 'main.dart';

class DataProviderQuestionsPage extends StatefulWidget {
  DataProviderQuestionsPage({Key? key}) : super(key: key);

  @override
  _DataProviderQuestionsPageState createState() =>
      _DataProviderQuestionsPageState();
}

class _DataProviderQuestionsPageState extends State<DataProviderQuestionsPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  final TextEditingController _key1 = TextEditingController();
  final TextEditingController _key2 = TextEditingController();
  final TextEditingController _key3 = TextEditingController();
  final TextEditingController _key4 = TextEditingController();
  final TextEditingController _key5 = TextEditingController();
  final List<String> options = [
    'Writer',
    'Graphic Designer',
    'Videographer',
    'Musician',
    'Dataset Engineer'
  ];
  String? selectedCategory;
  String errorMessage = '';
  List<String> oldSub = [];
  String? oldCategory;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    prepareInitData();
  }

  Future<void> prepareInitData() async {
    await _fetchCurrentUserDocument();
    if (oldSub.length == 5) {
      _key1.text = oldSub[0];
      _key2.text = oldSub[1];
      _key3.text = oldSub[2];
      _key4.text = oldSub[3];
      _key5.text = oldSub[4];
    }
    selectedCategory = oldCategory;
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> _fetchCurrentUserDocument() async {
    var doc = await firestoreConnect.returnCurrentUserDocument();
    if (doc != null) {
      if (doc.containsKey('sub') && doc['sub'] is String) {
        oldSub = doc['sub'].split(', ');
      }
      if (doc.containsKey('category') && doc['category'] is String) {
        oldCategory = doc['category'];
      }
    }
  }

  Widget _buildCheckboxList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: options.map((option) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: selectedCategory == option,
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedCategory = option;
                      } else {
                        selectedCategory = null;
                      }
                    });
                  },
                ),
                Text(option, style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void showAgentDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text("Configure your Agent",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(46, 158, 158, 158),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        DataProvConfigAgentPage(),
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
                        "Continue",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
    );
  }

  void showRequireDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text("Define Profile Details",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(46, 158, 158, 158),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Ok",
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        });
      },
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
                  width: MediaQuery.of(context).size.width * 0.1,
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
                          IconButton(
                            icon: const Icon(Icons.support_agent,
                                color: Colors.white, size: 30),
                            onPressed: () {
                              if (oldSub.isEmpty || oldCategory == null) {
                                showRequireDialog(context);
                              } else {
                                showAgentDialog(context);
                              }
                            },
                          ),
                        ],
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
                      Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: const Text(
                          'What type of data provider are you?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildCheckboxList(),
                      const SizedBox(height: 20),
                      ...List.generate(5, (index) {
                        return Column(
                          children: [
                            TextField(
                              controller: [
                                _key1,
                                _key2,
                                _key3,
                                _key4,
                                _key5
                              ][index],
                              maxLines: 1,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Category ${index + 1}",
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                fillColor: Colors.grey[850],
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5)
                          ],
                        );
                      }),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: onSaveInfo,
                        child: const Text(
                          'Save Info',
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
  }

  Future<void> onSaveInfo() async {
    setState(() {
      errorMessage = "";
    });

    if (_key1.text.isEmpty ||
        _key2.text.isEmpty ||
        _key3.text.isEmpty ||
        _key4.text.isEmpty ||
        _key5.text.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all of your categories";
      });
      return;
    }

    List<String> inputs = [
      _key1.text,
      _key2.text,
      _key3.text,
      _key4.text,
      _key5.text
    ].map((s) => s.toLowerCase()).toList();
    var uniqueInputs = Set<String>();
    for (String input in inputs) {
      if (!uniqueInputs.add(input)) {
        setState(() {
          errorMessage = "Each category must be unique";
        });
        return;
      }
    }

    if (selectedCategory == null || selectedCategory == "") {
      setState(() {
        errorMessage = "Please select your data provider type";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    List<String> newSub = inputs;
    String newCategory = selectedCategory!;
    if (firestoreConnect.auth.currentUser?.uid != null) {
      String userId = firestoreConnect.auth.currentUser!.uid;
      try {
        if (oldSub.isNotEmpty && oldCategory != null) {
          await firestoreConnect.removeFromCategories(
              userId, oldSub, oldCategory!);
        }
        await firestoreConnect.addToCategories(userId, newSub, newCategory);
        await firestoreConnect.updateProviderCategories(
            userId, newSub, newCategory);
      } catch (e) {
        print("Error during Firestore operations: $e");
        setState(() {
          errorMessage = "An error occurred while saving data.";
          isLoading = false;
        });
        return;
      }
    }

    setState(() {
      isLoading = false;
    });

    appKey.currentState?.popUntil((route) => route.isFirst);
    appKey = GlobalKey<NavigatorState>();
    runApp(MyApp(key: appKey));
  }

  @override
  void dispose() {
    _key1.dispose();
    _key2.dispose();
    _key3.dispose();
    _key4.dispose();
    _key5.dispose();
    super.dispose();
  }
}
