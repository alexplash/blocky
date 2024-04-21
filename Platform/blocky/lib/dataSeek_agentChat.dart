import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'backend/firebase_connect.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataSeekerAgentChatPage extends StatefulWidget {
  final String providerId;

  DataSeekerAgentChatPage({Key? key, required this.providerId})
      : super(key: key);

  @override
  _DataSeekerAgentChatPageState createState() =>
      _DataSeekerAgentChatPageState();
}

class _DataSeekerAgentChatPageState extends State<DataSeekerAgentChatPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  Map<String, dynamic>? agentConfig;
  Map<String, dynamic>? providerInfo;
  String? firstResponse;
  String? secondResponse;
  String? answer1;
  String? answer2;
  List<Map<String, String>> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeChat();
  }

  Future<void> initializeChat() async {
    await fetchAgentConfigData();
    await fetchFirstChat();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchAgentConfigData() async {
    agentConfig =
        await firestoreConnect.returnAgentConfiguration(widget.providerId);
    providerInfo = await firestoreConnect.getProviderInfo(widget.providerId);
    agentConfig!['username'] = providerInfo!['username'];
  }

  Future<void> fetchFirstChat() async {
    try {
      var url = Uri.parse('http://127.0.0.1:5000/firstchat');
      var response = await http.post(url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(agentConfig));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            messages.add({"sender": "bot", "text": data['response']});
            firstResponse = data['response'];
          });

          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                messages.add({
                  "sender": "bot",
                  "text":
                      "Describe clearly exactly what data you need from ${providerInfo!['username']}."
                });
              });
            }
          });
        }
      } else {
        print('Failed to load chat: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat: $e');
    }
  }

  Future<void> fetchSecondChat() async {
    try {
      var url = Uri.parse('http://127.0.0.1:5000/secondchat');
      var requestData = {
        'username': providerInfo!['username'],
        'firstResponse': firstResponse,
        'answer1': answer1,
        'answer2': answer2,
      };
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData)
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (mounted) {
          setState(() {
            secondResponse = data['Contract'];
            messages.add({"sender": "bot", "text": data['Contract']});
          });
        }
      }
    } catch (e) {
      print('Error fetching second chat: $e');
    }
  }

  void sendMessage() {
    String text = messageController.text;
    if (text.isNotEmpty) {
      setState(() {
        messages.add({"sender": "user", "text": text});
        messageController.clear();

        if (firstResponse != null && answer1 == null) {
          answer1 = text;
          print("answer1: $answer1");
          Future.delayed(Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                messages.add({
                  "sender": "bot",
                  "text": "How many units of ${providerInfo!['username']}'s data would you like? Make sure to use their unit definition."
                });
              });
            }
          });
        } else if (answer1 != null && answer2 == null) {
          answer2 = text;
          print("answer2: $answer2");

          Future.delayed(Duration(seconds: 2), () {
            fetchSecondChat();
          });
        }
      });
    }
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
                        'Agent Chat',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Debis'),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          bool isUser = messages[index]['sender'] == 'user';
                          return Column(
                            children: [
                              Container(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: isUser
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  children: [
                                    if (!isUser)
                                      Icon(Icons.support_agent,
                                          color: Colors.white),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 5.0),
                                        decoration: BoxDecoration(
                                          color: isUser
                                              ? const Color.fromARGB(
                                                  255, 40, 33, 183)
                                              : Color.fromARGB(
                                                  125, 141, 141, 141),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border:
                                              Border.all(color: Colors.white),
                                        ),
                                        child: Text(
                                          messages[index]['text']!,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      TextField(
                        controller: messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.black,
                          hintText: "Type your message here...",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: sendMessage,
                          ),
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
  }
}
