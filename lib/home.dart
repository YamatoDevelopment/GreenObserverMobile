import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:greenobserver/api_client.dart';
import 'package:greenobserver/models.dart';
import 'package:greenobserver/providers/report_endpoint.dart';
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

  // List of markers, initially empty
  List<Marker> _markers = [];
  // List of cards initially empty
  List<Widget> _cards = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchMarkers();
    _buildCards();
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

  Future<void> _fetchMarkers() async {
    try {
      setState(() async {
        _markers = await _buildMarkers();
      });
    } catch (e) {
      print("Error fetching markers: $e");
    }
  }

  void _buildCards() async {
    // Fetch reports and generate cards
    ApiClient apiClient = ApiClient();
    ReportEndpoint reportEndpoint = ReportEndpoint(apiClient.init());
    List<Report> reports = await reportEndpoint.getReports();
    List<Widget> cards = [];
    for (Report report in reports) {
      cards.add(_buildListTile(report));
    }
    setState(() => _cards = cards);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF18453B)))
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
                            markers: _markers,
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

  IconData getIconForReportType(String type) {
    switch (type) {
      case 'litter_and_waste':
        return MyFlutterApp.trash_marker;
      case 'pollution':
        return MyFlutterApp.polution;
      case 'water_drainage':
        return MyFlutterApp.water_polution;
      case 'wildlife_and_nature':
        return MyFlutterApp.wildlife;
      case 'public_hazards':
        return MyFlutterApp.hazard;
      default:
        return Icons.location_on;
    }
  }

  Color getColorForReportType(String type) {
    switch (type) {
      case 'litter_and_waste':
        return Colors.red;
      case 'pollution':
        return Colors.brown;
      case 'water_drainage':
        return Colors.blue;
      case 'wildlife_and_nature':
        return const Color(0xFF99CC33);
      case 'public_hazards':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Future<List<Marker>> _buildMarkers() async {
    List<Marker> markers = [];
    ApiClient apiClient = ApiClient();
    ReportEndpoint reportEndpoint = ReportEndpoint(apiClient.init());
    List<Report> reports = await reportEndpoint.getReports();
    for (Report report in reports) {
      markers.add(Marker(
        point: LatLng(report.locationLat, report.locationLon),
        width: 60,
        height: 60,
        child: _buildMarker(getIconForReportType(report.tag),
            getColorForReportType(report.tag)),
      ));
    }
    return markers;
  }

  Widget _buildMarker(IconData icon, Color bgColor) {
    return Icon(icon, size: 60, color: bgColor, shadows: [
      Shadow(
        blurRadius: 10,
        color: Colors.black.withAlpha(255),
        offset: const Offset(2, 4),
      ),
    ]
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
      children: _cards,
    );
  }

  Widget _buildListTile(Report report) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Image.network("http://35.21.205.135:8000/${report.photoUrl}"),
        title: Text(report.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(report.description ?? ""),
        tileColor: getColorForReportType(report.tag).withValues(alpha: 0.1),
      ),
    );
  }
}
