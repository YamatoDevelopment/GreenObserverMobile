import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:greenobserver/api_client.dart';
import 'package:greenobserver/models.dart';
import 'package:greenobserver/providers/report_endpoint.dart';
import 'package:greenobserver/settings.dart';
import 'package:greenobserver/view_report.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  SharedPreferences? _prefs; // SharedPreferences instance
  final ReportEndpoint _reportEndpoint = ReportEndpoint(ApiClient().init());

  // List of markers, initially empty
  List<Marker> _markers = [];

  // List of cards initially empty
  List<Widget> _cards = [];

  List<Report> _reports = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _fetchPreferences().then((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    List<Report> reports =
        await _reportEndpoint.getReports(_prefs?.getString('username') ?? "");
    setState(() {
      _reports = reports;
    });
    _fetchMarkers();
    _buildCards();
  }

  Future<void> _fetchPreferences() async {
    _prefs = await SharedPreferences.getInstance();
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
    _markers = await _buildMarkers();
    setState(() {}); // Update state to refresh markers
  }

  void _buildCards() async {
    // Fetch reports and generate cards
    List<Widget> cards = [];
    for (Report report in _reports) {
      cards.add(_buildListTile(report));
    }
    setState(() => _cards = cards);
  }

  void _onItemTapped(int index) {
    _fetchData();
    setState(() {
      _selectedIndex = index;
    });
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
      body: <Widget>[
        _isLoading
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
                            interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.drag |
                                    InteractiveFlag.pinchZoom |
                                    InteractiveFlag.rotate |
                                    InteractiveFlag.doubleTapZoom),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                              subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                            ),
                            MapCompass(
                              icon: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_upward_outlined,
                                    color: Color(0xFF18453B),
                                    size: 30,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.only(top: 350, right: 20),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSegmentSwitch(),
                      ],
                    ),
                  ),
                  // Only show if map view is selected
                  // Only show if map view is selected
                  if (_viewType == 'Map') ...[
                    Positioned(
                      bottom: 320,
                      right: 20,
                      child: FloatingActionButton(
                        onPressed: () {
                          mapController.move(_currentLocation,
                              15.5); // Move to current location
                        },
                        backgroundColor: const Color(0xFF18453B),
                        child: Icon(Icons.my_location, color: Colors.white),
                      ),
                    ),
                  ]
                ],
              ),
        CameraPage(),
        SettingsPage(),
      ][_selectedIndex],
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
    for (Report report in _reports) {
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
    ]);
  }

  Widget _buildSegmentSwitch() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewType = _viewType == "Map" ? "List" : "Map";
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              _viewType == "Map" ? const Color(0xFF18453B) : Colors.grey[300],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: _viewType == "Map"
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.white,
                  child: Icon(
                    _viewType == "Map" ? Icons.map : Icons.list,
                    color: const Color(0xFF18453B),
                  ),
                ),
              ),
            ),
            Center(
              child: Text(
                _viewType,
                style: TextStyle(
                  color: _viewType == "Map"
                      ? Colors.white
                      : const Color(0xFF18453B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/sample.png"), // Set background image
          fit: BoxFit.cover, // Cover the entire background
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
        children: _cards,
      ),
    );
  }

  String tagToCategory(String tag) {
    switch (tag) {
      case 'litter_and_waste':
        return 'Litter & Waste';
      case 'pollution':
        return 'Pollution';
      case 'water_drainage':
        return 'Water Drainage';
      case 'wildlife_and_nature':
        return 'Wildlife & Nature';
      case 'public_hazards':
        return 'Public Hazards';
      default:
        return 'N/A';
    }
  }

  Widget _buildListTile(Report report) {
    return Container(
      height: 600, // Adjusted for better spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        color: Color(0xFF18453B),
        child: Stack(
          children: [
            // Image covering 90% of width
            Positioned.fill(
              top: 60,
              left: 10,
              right: 10,
              bottom: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Opacity(
                  opacity: 0.95, // Slight opacity for blending effect
                  child: InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ViewReportPage(report: report))),
                      child: Image.network(
                        "http://35.21.205.135:8000/${report.photoUrl}",
                        width: double.infinity, // 90% width
                        height: double.infinity, // Maintain aspect ratio
                        fit: BoxFit.cover, // Ensures image fills the space
                      )),
                ),
              ),
            ),
            // Title overlay at the top
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // Category label at the top-right corner
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                decoration: BoxDecoration(
                  color: getColorForReportType(report.tag),
                  // Slight background for contrast
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tagToCategory(report.tag),
                  // Assuming `report.category` holds the category text
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: getColorForReportType(report.tag),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: ButtonTheme(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  fixedSize: const Size(100, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners
                  ),
                ),
                onPressed: () {
                  // Update the local report and upvote
                  _reports.firstWhere((r) => r.id == report.id).upvotes++;
                  _buildCards();

                  _reportEndpoint
                      .upvoteReport(
                          report.id, _prefs?.getString("username") ?? "")
                      .then((_) {
                    _fetchData();
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(MyFlutterApp.megaphone,
                        color: Color(0xFF18453B)),
                    // Icon on the left
                    const SizedBox(width: 3),
                    Text(
                      report.upvotes.toString(),
                      style: const TextStyle(
                        color: Color(0xFF18453B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
            ),
            Positioned(
              bottom: 10,
              left: 120,
              child: ButtonTheme(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  fixedSize: const Size(80, 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
                  ),
                ),
                onPressed: () {
                  //   Redirect to View Report Page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewReportPage(report: report)),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.comment_rounded, color: Color(0xFF18453B)),
                    // Icon on the left
                    const SizedBox(width: 1),
                    Text(
                      report.comments.length.toString(),
                      style: const TextStyle(
                        color: Color(0xFF18453B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
