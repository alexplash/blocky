import 'package:flutter/material.dart';
import 'backend/firebase_connect.dart';
import 'userProfile_class.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataSeekerSearchPage extends StatefulWidget {
  final String category;
  final String prompt;

  DataSeekerSearchPage({Key? key, required this.category, required this.prompt})
      : super(key: key);

  @override
  _DataSeekerSearchPageState createState() => _DataSeekerSearchPageState();
}

class _DataSeekerSearchPageState extends State<DataSeekerSearchPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  List<String>? subCategories;
  Map<String, int> providerMap = {};
  List<UserProfile> sortedUserProfiles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    prepareData();
  }

  Future<void> prepareData() async {
    await bloomOutputProcess(widget.prompt);
    await createProviderMap(widget.category, subCategories!);
    await fetchAndSortUserProfiles();
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> bloomOutputProcess(String prompt) async {
    var url = Uri.parse('http://127.0.0.1:5000/categorize');
    try {
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'input': prompt}));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String modelOutput = data['result'];
        modelOutput = modelOutput.trim();
        List<String> keywordsList = [];

        RegExp exp = RegExp(r"KEYWORDS: \s*'([^#]+)' ### END");
        Iterable<RegExpMatch> matches = exp.allMatches(modelOutput);
        for (RegExpMatch match in matches) {
          String keywords = match.group(1)!;
          List<String> words =
              keywords.split(',').map((s) => s.trim().toLowerCase()).toList();
          keywordsList.addAll(words);
        }
        keywordsList = keywordsList.toSet().toList();
        subCategories = keywordsList;
        print(subCategories);
      } else {
        print(
            'Failed to load categorized data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught while requesting categorization: $e');
    }
  }

  Future<void> createProviderMap(
      String category, List<String> subCategories) async {
    Map<String, List<String>> subCategoryProviders =
        await firestoreConnect.fetchCategoryProviders(category);

    for (String subCategory in subCategories) {
      for (String providerSubCategory in subCategoryProviders.keys) {
        double similarityScore =
            await calculateSimilarity(subCategory, providerSubCategory);
        if (similarityScore >= 0.55) {
          List<String> userIds =
              subCategoryProviders[providerSubCategory] ?? [];
          for (String userId in userIds) {
            if (providerMap.containsKey(userId)) {
              providerMap[userId] = providerMap[userId]! + 1;
            } else {
              providerMap[userId] = 1;
            }
          }
        }
      }
    }

    providerMap.forEach((userId, count) {
      print('User ID: $userId, Count: $count');
    });
  }

  Future<double> calculateSimilarity(String word1, String word2) async {
    var url = Uri.parse('http://127.0.0.1:5000/similarity');
    try {
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'word1': word1, 'word2': word2}));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['similarity'];
      } else {
        print('Failed with status code: ${response.statusCode}');
        print('Reason: ${response.body}');
        return 0.0;
      }
    } catch (e) {
      print('Exception caught: $e');
      return 0.0;
    }
  }

  Future<void> fetchAndSortUserProfiles() async {
    List<Future<UserProfile?>> fetchFutures = [];
    providerMap.forEach((userId, count) {
      fetchFutures
          .add(firestoreConnect.getProviderInfo(userId).then((profileData) {
        if (profileData != null) {
          return UserProfile.fromMap(profileData, userId, count);
        }
        return null;
      }).catchError((e) {
        print("Error fetching profile for user $userId: $e");
        return null;
      }));
    });

    try {
      List<UserProfile?> profiles = await Future.wait(fetchFutures);
      List<UserProfile> validProfiles =
          profiles.whereType<UserProfile>().toList();
      validProfiles.sort((a, b) => b.count.compareTo(a.count));

      setState(() {
        sortedUserProfiles = validProfiles;
      });
    } catch (e) {
      print("An error occurred while sorting profiles: $e");
    }
  }

  void showRequestDialog(BuildContext context, String receiverId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: const Text("Add Provider to Mailbox",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                content:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                                  horizontal: 32, vertical: 12))),
                      const SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: () async {
                            await firestoreConnect.addToSeekerMailbox(
                              firestoreConnect.auth.currentUser?.uid ?? '',
                              receiverId,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12))),
                    ],
                  ),
                  const SizedBox(height: 10),
                ]));
          });
        });
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
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Text(
                        'Data Providers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontFamily: 'Debis',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      sortedUserProfiles.isEmpty
                          ? const Text(
                              'No data providers found for your specifications',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            )
                          : Column(
                              children: sortedUserProfiles
                                  .map((profile) => ListTile(
                                        leading: CircleAvatar(
                                          radius: 60,
                                          backgroundColor: Colors.grey.shade800,
                                          backgroundImage:
                                              profile.profileImageUrl != null
                                                  ? NetworkImage(
                                                      profile.profileImageUrl)
                                                  : null,
                                          child: (profile.profileImageUrl ==
                                                      null ||
                                                  profile.profileImageUrl == '')
                                              ? Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade800,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            60),
                                                  ),
                                                  child: const Icon(
                                                      Icons.person,
                                                      color: Colors.white60,
                                                      size: 30),
                                                )
                                              : null,
                                        ),
                                        title: IntrinsicWidth(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2),
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      color: Colors.white,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                ),
                                                child: Text(
                                                  profile.username,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Category: ${profile.category}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              'Subcategories: ${profile.sub}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: IconButton(
                                          icon: const Icon(Icons.add,
                                              color: Colors.grey),
                                          onPressed: () {
                                            showRequestDialog(
                                                context, profile.userId);
                                          },
                                        ),
                                      ))
                                  .toList(),
                            )
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

  @override
  void dispose() {
    super.dispose();
  }
}
