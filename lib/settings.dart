import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }

  Future<void> _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    // Load the values from shared preferences
    _formKey.currentState?.fields['displayName']
        ?.didChange(prefs?.getString('displayName') ?? '');
    _formKey.currentState?.fields['username']
        ?.didChange(prefs?.getString('username') ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 150),
                child: FormBuilder(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      FormBuilderTextField(
                        name: 'displayName',
                        decoration: InputDecoration(
                          labelText: 'Display Name',
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'username',
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Align(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    String displayName = _formKey.currentState
                                        ?.fields['displayName']?.value;
                                    String username = _formKey.currentState
                                        ?.fields['username']?.value;
                                    // Save the values to shared preferences
                                    await prefs?.setString(
                                        'displayName', displayName);
                                    await prefs?.setString(
                                        'username', username);
                                    print('Saved: $displayName, $username');
                                    print(prefs?.getString('displayName'));
                                  },
                                  child: const Text("Save")))),
                    ])))));
  }
}
