import 'package:flutter/material.dart';
import 'backend/firebase_connect.dart';
import 'dataSeek_agentChat.dart';

class DataSeekerMailboxPage extends StatefulWidget {
  DataSeekerMailboxPage({Key? key}) : super(key: key);

  @override
  _DataSeekerMailboxPageState createState() => _DataSeekerMailboxPageState();
}

class _DataSeekerMailboxPageState extends State<DataSeekerMailboxPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  bool isLoading = false;
  Map<String, dynamic>? mailboxInfo = {};
  Map<String, Map<String, dynamic>?> addedProviderInfo = {};
  Map<String, bool> agentConfigExists = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    try {
      mailboxInfo = await firestoreConnect
          .returnSeekerMailbox(firestoreConnect.auth.currentUser?.uid ?? '');
      if (mailboxInfo != null && mailboxInfo!.isNotEmpty) {
        for (String providerId in mailboxInfo!.keys) {
          var providerInfo = await firestoreConnect.getProviderInfo(providerId);
          if (providerInfo != null) {
            addedProviderInfo[providerId] = providerInfo;
          }
        }
      }

      for (String providerId in mailboxInfo!.keys) {
        Map<String, dynamic>? configData = await firestoreConnect.returnAgentConfiguration(providerId);
        if (configData != null) {
          agentConfigExists![providerId] = true;
        } else {
          agentConfigExists![providerId] = false;
        }
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showRemoveDialog(
      BuildContext context, String receiverId, Function(String) onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text("Remove from Mailbox",
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
                        await firestoreConnect.removeFromSeekerMailbox(
                            firestoreConnect.auth.currentUser?.uid ?? '',
                            receiverId);
                        Navigator.of(context).pop();
                        onConfirm(receiverId);
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

  void showAgentDialog(
      BuildContext context, String providerId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            title: const Text("Speak with Agent",
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
                                      DataSeekerAgentChatPage(providerId: providerId),
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
                        "Confirm",
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

  void removeProviderFromList(String receiverId) {
    setState(() {
      addedProviderInfo.remove(receiverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
          backgroundColor: Color.fromARGB(255, 17, 0, 47),
          body: Center(child: CircularProgressIndicator()));
    } else {
      List<Widget> providerListTiles = addedProviderInfo.entries.map((entry) {
        var uid = entry.key;
        var providerInfo = entry.value;
        var imageUrl = providerInfo?['profileImageUrl'] as String?;
        var username = providerInfo?['username'] as String?;
        var category = providerInfo?['category'] as String?;
        var subcategories = providerInfo?['sub'] as String?;
        bool agentConfigAvailable = agentConfigExists[uid] ?? false;

        return ListTile(
          leading: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade800,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null || imageUrl.isEmpty
                ? const Icon(Icons.person, color: Colors.white60, size: 30)
                : null,
          ),
          title: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: const BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 1.0)),
                  ),
                  child: Text(
                    username ?? 'Unknown',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Category: $category',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              Text(
                'Subcategories: $subcategories',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize
                .min,
            children: [
              if (agentConfigAvailable)
                IconButton(
                  icon: const Icon(Icons.support_agent,
                    color: Colors.grey),
                  onPressed: () {
                    showAgentDialog(context, uid);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.do_not_disturb_on, color: Colors.grey),
                onPressed: () {
                  showRemoveDialog(context, uid, removeProviderFromList);
                },
              ),
            ],
          ),
        );
      }).toList();

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
                        'Mailbox',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Debis'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ...providerListTiles,
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
