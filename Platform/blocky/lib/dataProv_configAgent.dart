import 'package:flutter/material.dart';
import 'backend/firebase_connect.dart';
import 'main.dart';

class DataProvConfigAgentPage extends StatefulWidget {
  DataProvConfigAgentPage({Key? key}) : super(key: key);

  @override
  _DataProvConfigAgentPageState createState() =>
      _DataProvConfigAgentPageState();
}

class _DataProvConfigAgentPageState extends State<DataProvConfigAgentPage> {
  final FirestoreConnect firestoreConnect = FirestoreConnect();
  bool isLoading = true;
  final TextEditingController _dataTypesController = TextEditingController();
  final TextEditingController _dataUnitController = TextEditingController();
  final TextEditingController _dataCostController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _discountDetailsController =
      TextEditingController();
  String? _selectedLicense;
  String errorMessage = '';
  Map<String, dynamic>? oldConfig;

  final List<String> _licenses = [
    'Creative Commons Attribution (CC BY)',
    'Creative Commons Attribution-ShareAlike (CC BY-SA)',
    'Creative Commons Attribution-NoDerivs (CC BY-ND)',
    'Creative Commons Attribution-NonCommercial (CC BY-NC)',
    'Creative Commons Attribution-NonCommercial-ShareAlike (CC BY-NC-SA)',
    'Creative Commons Attribution-NonCommercial-NoDerivs (CC BY-NC-ND)',
    'GNU General Public License (GPL)',
    'GNU Lesser General Public License (LGPL)',
    'MIT License'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    oldConfig = await firestoreConnect.returnAgentConfiguration(firestoreConnect.auth.currentUser?.uid ?? '');
    if (oldConfig != null) {
      _dataTypesController.text = oldConfig!['dataType'];
      _dataUnitController.text = oldConfig!['dataUnit'];
      _dataCostController.text = oldConfig!['dataPrice'];
      _selectedLicense = oldConfig!['license'];
      _discountDetailsController.text = oldConfig!['discount'];
      _contactInfoController.text = oldConfig!['contactInfo'];
    }
    setState(() {
      isLoading = false;
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
                        'Configure Agent',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Debis'),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      buildTextField(
                        controller: _dataTypesController,
                        labelText:
                            'Further clarify the types of data you provide. Make clear any constraints or specializations.',
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: _dataUnitController,
                        labelText:
                            'Define what one single unit of your data is.',
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: _dataCostController,
                        labelText:
                            'How much do you charge for one unit of your data, in ETH?',
                      ),
                      const SizedBox(height: 20),
                      buildDropdownField(
                        value: _selectedLicense,
                        items: _licenses,
                        labelText:
                            'Choose the license with which you are willing to provide your data.',
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: _discountDetailsController,
                        labelText:
                            'Describe any discounts you offer for certain quantities or types of data.',
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        controller: _contactInfoController,
                        labelText:
                            'Optionally, provide your contact information.',
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveConfiguration,
                        child: const Text(
                          'Save Configuration',
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

  Widget buildTextField(
      {required TextEditingController controller, required String labelText}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 40, 33, 183)),
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        fillColor: const Color.fromARGB(65, 158, 158, 158),
        filled: true,
      ),
      style: const TextStyle(color: Colors.white),
    );
  }

  Widget buildDropdownField(
      {String? value, required List<String> items, required String labelText}) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.black,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.white),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 40, 33, 183)),
          ),
          fillColor: const Color.fromARGB(65, 158, 158, 158),
          filled: true,
        ),
        style: const TextStyle(color: Colors.white),
        dropdownColor: Colors.black,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedLicense = newValue;
          });
        },
      ),
    );
  }

  Future<void> _saveConfiguration() async {
    if (_dataTypesController.text.isEmpty ||
        _dataUnitController.text.isEmpty ||
        _dataCostController.text.isEmpty ||
        _selectedLicense == null) {
      setState(() {
        errorMessage = "Please fill in fields 1 - 4";
      });
      return;
    }

    Map<String, dynamic> configData = {
      'dataType':
          _dataTypesController.text,
      'dataUnit': _dataUnitController.text,
      'dataPrice':
          _dataCostController.text,
      'license':
          _selectedLicense!,
      'discount':
          _discountDetailsController.text,
      'contactInfo':
          _contactInfoController.text,
    };

    setState(() {
      isLoading = true;
    });

    try {
      await firestoreConnect.saveAgentConfiguration(
          firestoreConnect.auth.currentUser?.uid ?? '', configData);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to save configuration: $e";
      });
      return;
    }

    setState(() {
      isLoading = false;
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _dataTypesController.dispose();
    _dataUnitController.dispose();
    _dataCostController.dispose();
    _discountDetailsController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }
}
