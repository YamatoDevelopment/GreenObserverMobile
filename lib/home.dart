import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:greenobserver/settings.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'camera.dart';
import 'my_flutter_app_icons.dart';
import "util.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController mapController = MapController();
  int _selectedIndex = 0;
  String _viewType = 'Map';
  bool _isLoading = true; // Loading state flag
  LatLng _currentLocation = LatLng(42.7314, -84.4818); // Default location (MSU)

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await determinePosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false; // Location set, stop loading
      });
      mapController.move(_currentLocation, 15.5);
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false); // Stop loading even if failed
    }
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
        color: const Color(0xFF18453B).withOpacity(0.2),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF18453B)))
          : Stack(
        children: [
          _viewType == 'Map'
              ? FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentLocation,
              initialZoom: 15.5,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
              ),
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          )
              : _buildListView(),

          Positioned(
            top: 60,
            left: 116,
            right: 116,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSegmentButton('Map'),
                  const SizedBox(width: 22),
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
        selectedItemColor: const Color(0xFF18453B),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  List<Marker> _buildMarkers() {
    return [
      Marker(
        point: LatLng(42.7314, -84.4818),
        width: 60,
        height: 60,
        child: _buildMarker(MyFlutterApp.trash_marker, Colors.red),
      ),
      Marker(
        point: LatLng(42.7314, -84.4830),
        width: 60,
        height: 60,
        child: _buildMarker(MyFlutterApp.polution, Colors.brown),
      ),
      Marker(
        point: LatLng(42.7314, -84.4890),
        width: 60,
        height: 60,
        child: _buildMarker(MyFlutterApp.water_polution, Colors.blue),
      ),
      Marker(
        point: LatLng(42.7330, -84.4818),
        width: 60,
        height: 60,
        child: _buildMarker(MyFlutterApp.wildlife, const Color(0xFF99CC33)),
      ),
      Marker(
        point: LatLng(42.7350, -84.4818),
        width: 60,
        height: 60,
        child: _buildMarker(MyFlutterApp.hazard, Colors.yellow),
      ),
    ];
  }

  Widget _buildMarker(IconData icon, Color bgColor) {
    return Container(
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, size: 60, color: Colors.white),
    );
  }

  Widget _buildSegmentButton(String type) {
    bool isSelected = _viewType == type;
    return GestureDetector(
      onTap: () => setState(() => _viewType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18453B) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF18453B), width: 2),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF18453B),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
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
        leading: const Icon(Icons.location_on, color: Color(0xFF18453B)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
