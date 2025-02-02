import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenobserver/api_client.dart';
import 'package:greenobserver/models.dart';
import 'package:greenobserver/providers/report_endpoint.dart';
import 'package:greenobserver/home.dart';
import 'package:greenobserver/util.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import home screen

class ReportPage extends StatefulWidget {
  final String? path;

  const ReportPage(this.path, {super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  LatLng? _currentLocation;
  final TextEditingController _descriptionController = TextEditingController();
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();
    _getUserLocation();
  }

  Future<void> _loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await determinePosition();
      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _currentLocation = currentLocation;
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF18453B), // MSU Green
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Report',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Hide keyboard when tapping outside
          child: SingleChildScrollView(
            reverse: true, // Ensures scrolling when keyboard appears
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom, // Adjust for keyboard
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Column(
              children: <Widget>[
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20), // Rounded image corners
                  child: AspectRatio(
                    aspectRatio: 8 / 10,
                    child: Image.file(File(widget.path!), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 20),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'title',
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B)), // MSU Green
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _descriptionController,
                        maxLines: null,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Write something about this report...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B)), // MSU Green
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B), width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FormBuilderDropdown<String>(
                        name: 'tag',
                        initialValue: 'litter_and_waste',
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B)), // MSU Green
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                                color: Color(0xFF18453B), width: 2),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'litter_and_waste',
                            child: Text('Litter and Waste'),
                          ),
                          DropdownMenuItem(
                            value: 'pollution',
                            child: Text('Pollution'),
                          ),
                          DropdownMenuItem(
                            value: 'water_drainage',
                            child: Text('Water Drainage'),
                          ),
                          DropdownMenuItem(
                            value: 'wildlife_and_nature',
                            child: Text('Wildlife and Nature'),
                          ),
                          DropdownMenuItem(
                            value: 'public_hazards',
                            child: Text('Public Hazards'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Other'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          ReportFormData report = ReportFormData(
                            photo: File(widget.path!),
                            title:
                                _formKey.currentState?.fields['title']?.value,
                            description: _descriptionController.text,
                            locationLat: _currentLocation?.latitude ?? 0.0,
                            locationLon: _currentLocation?.longitude ?? 0.0,
                            tag: _formKey.currentState?.fields['tag']?.value,
                            reportedBy:
                                prefs?.getString('username') ?? 'Anonymous',
                          );

                          ApiClient apiClient = ApiClient();
                          var reportProvider = ReportEndpoint(apiClient.init());
                          reportProvider.createReport(report).then((value) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()),
                              (Route<dynamic> route) =>
                                  false, // Clears back stack
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF18453B), // MSU Green
                          foregroundColor: Colors.white,
                          minimumSize: const Size(
                              double.infinity, 50), // Full-width button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
