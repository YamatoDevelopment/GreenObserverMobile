import 'package:flutter/material.dart';
  import 'package:flutter_map/flutter_map.dart';
  import 'package:latlong2/latlong.dart';
  import 'package:geolocator/geolocator.dart';
  import 'camera.dart';

  class HomePage extends StatefulWidget {
    const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
  }

  class _HomePageState extends State<HomePage> {
    final mapController = MapController();
    int _selectedIndex = 0;

    @override
    void initState() {
      super.initState();
      _getUserLocation(); // Fetch location on startup
    }

    Future<void> _getUserLocation() async {
      try {
        Position position = await _determinePosition();
        LatLng currentLocation = LatLng(position.latitude, position.longitude);
        mapController.move(currentLocation, 15.5); // Move map to user's location
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
    }
    // Screens for bottom navigation
    static const List<Widget> _widgetOptions = <Widget>[
      Text('Home Page'),
      Text('Business Page'),
      Text('School Page'),
    ];

    Widget _buildIcon(IconData icon, int index) {
      bool isSelected = _selectedIndex == index;
      return Container(
        decoration: isSelected
            ? BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF18453B).withOpacity(0.2), // Light MSU Green background
        )
            : null,
        padding: isSelected ? EdgeInsets.all(8) : EdgeInsets.zero,
        // Circle padding
        child: Icon(icon, size: isSelected ? 32 : 28,
            color: isSelected ? Color(0xFF18453B) : Colors.grey),
      );
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(

        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: LatLng(55.7509167, 037.6170556),
            initialZoom: 15.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.greenobserver',
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

  }