import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:greenobserver/Home.dart';
import 'package:greenobserver/settings.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'camera.dart';
import 'package:flutter/widgets.dart';
import 'my_flutter_app_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final mapController = MapController();
  int _selectedIndex = 0;
  String _viewType = 'Map'; // Default view is Map

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await _determinePosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      mapController.move(currentLocation, 15.5);
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
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
    if (index == 2) {
      // Navigate to Settings Page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettingsPage()),
      );
    }
  }

  Widget _buildIcon(IconData icon, int index) {
    bool isSelected = _selectedIndex == index;
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF18453B)
                  .withOpacity(0.2), // Light MSU Green background
            )
          : null,
      padding: isSelected ? EdgeInsets.all(8) : EdgeInsets.zero,
      child: Icon(icon,
          size: isSelected ? 32 : 28,
          color: isSelected ? Color(0xFF18453B) : Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _viewType == 'Map'
              ? FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(55.7509167, 037.6170556),
                    initialZoom: 15.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}', // Satellite view from Google Maps
                      subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(42.7314, -84.4818),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFF0000), // Red background
                              shape: BoxShape.circle,   // Make it circular
                            ),
                            child: Icon(
                              MyFlutterApp.trash_marker,
                              size: 60,  // Adjust size to fit the container
                              color: Colors.white, // White icon color for contrast
                            ),
                          ),
                        ),
                        Marker(
                          point: LatLng(42.7314, -84.4830),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF8B4513), // Brown background
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              MyFlutterApp.polution,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Marker(
                          point: LatLng(42.7314, -84.4890),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF0000FF), // Blue background
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              MyFlutterApp.water_polution,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Marker(
                          point: LatLng(42.7330, -84.4818),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF99CC33), // Salad green background
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              MyFlutterApp.wildlife,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Marker(
                          point: LatLng(42.7350, -84.4818),
                          width: 60,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFFFFF00), // Yellow background
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              MyFlutterApp.hazard,
                              size: 60,
                              color: Colors.black, // Black icon color for contrast
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              : _buildListView(), // Show List View when toggled

          // Segmented Button for View Selection
          Positioned(
            top: 60,
            left: 116,
            right: 116,
            child: Container(
              width: 0,
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSegmentButton('Map'),
                  SizedBox(width: 22),
                  _buildSegmentButton('List'),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        selectedItemColor: Color(0xFF18453B), // MSU Green
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // Helper method to create segment buttons
  Widget _buildSegmentButton(String type) {
    bool isSelected = _viewType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF18453B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xFF18453B), width: 2),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF18453B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Placeholder List View
  Widget _buildListView() {
    return ListView(
      padding: EdgeInsets.only(top: 100, left: 20, right: 20),
      children: [
        _buildListTile("Location 1", "123 Main Street"),
        _buildListTile("Location 2", "456 Oak Avenue"),
        _buildListTile("Location 3", "789 Pine Road"),
        _buildListTile("Location 4", "101 Maple Lane"),
      ],
    );
  }

  Widget _buildListTile(String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(Icons.location_on, color: Color(0xFF18453B)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
