import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:greenobserver/Home.dart';
import 'package:greenobserver/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  SharedPreferences? prefs;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
  }
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CameraPage()),
      );
    }
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  }

  Future<void> _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    _formKey.currentState?.fields['displayName']
        ?.didChange(prefs?.getString('displayName') ?? '');
    _formKey.currentState?.fields['username']
        ?.didChange(prefs?.getString('username') ?? '');
  }
  Widget _buildIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      decoration: isSelected
          ? BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF18453B)
            .withValues(alpha: 0.2), // Light MSU Green background
      )
          : null,
      padding: isSelected ? const EdgeInsets.all(8) : EdgeInsets.zero,
      child: Icon(icon,
          size: isSelected ? 32 : 28,
          color: isSelected ? const Color(0xFF18453B) : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 150),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  name: 'displayName',
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                  ),
                ),
                FormBuilderTextField(
                  name: 'username',
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        String displayName =
                            _formKey.currentState?.fields['displayName']
                                ?.value;
                        String username = _formKey.currentState
                            ?.fields['username']?.value;
                        await prefs?.setString('displayName', displayName);
                        await prefs?.setString('username', username);
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:  BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.map, 0),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.add, 1),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.settings, 2),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF18453B),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
