import 'package:flutter/material.dart';
import 'backend/firebase_connect.dart';
import 'userInfo.dart';
import 'dataSeek_viewMailbox.dart';
import 'dataSeek_search.dart';

class DataSeekerPromptPage extends StatefulWidget {
  DataSeekerPromptPage({Key? key}) : super(key: key);

  @override
  _DataSeekerPromptPageState createState() => _DataSeekerPromptPageState();
}

class _DataSeekerPromptPageState extends State<DataSeekerPromptPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  final TextEditingController _searchController = TextEditingController();
  final List<String> options = [
    'Writer',
    'Graphic Designer',
    'Videographer',
    'Musician',
    'Dataset Engineer'
  ];
  String? selectedCategory;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
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
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween,
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
                          icon: const Icon(Icons.mail,
                              color: Colors.white,
                              size:
                                  30),
                          onPressed: () => Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      DataSeekerMailboxPage(),
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
                      ],
                    ),
                    const Text(
                      'Data Seeker',
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
                        'What type of data provider do you need?',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCheckboxList(),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _searchController,
                      maxLines: 4,
                      maxLength: 200,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                          hintText:
                              "Be specific with the type of data you need. Please include clear keywords in your description.",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          fillColor: Colors.grey[850],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          counterStyle: const TextStyle(color: Colors.white),
                          counterText: "${_searchController.text.length}/200"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onSearch,
                      child: const Text(
                        'Search',
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

  Future<void> onSearch() async {
    setState(() {
      errorMessage = "";
    });
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      setState(() {
        errorMessage = "Please select the type of data provider you desire";
      });
      return;
    }
    if (_searchController.text.length < 50) {
      setState(() {
        errorMessage =
            "Please use more than 50 characters in your data description";
      });
      return;
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DataSeekerSearchPage(
                category: selectedCategory!, prompt: _searchController.text),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(() {
      setState(() {});
    });
    _searchController.dispose();
    super.dispose();
  }
}
