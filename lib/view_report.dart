import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greenobserver/api_client.dart';
import 'package:greenobserver/models.dart';
import 'package:greenobserver/providers/report_endpoint.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewReportPage extends StatefulWidget {
  final Report report;

  const ViewReportPage({super.key, required this.report});

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  List<Placemark> _placemarks = [];
  SharedPreferences? _prefs;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
    _getSharedPreferences();
  }

  Future<void> _getSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _getLocation() async {
    try {
      var placemarks = await placemarkFromCoordinates(
          widget.report.locationLat, widget.report.locationLon);
      setState(() {
        _placemarks = placemarks;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _addComment() {
    String newComment = _commentController.text.trim();
    if (newComment.isNotEmpty) {
      setState(() {
        widget.report.comments.add(Comment(
          comment: newComment,
          authorId: "You",
          id: _prefs?.getString("username") ?? "unknown",
        ));
      });
      ReportEndpoint reportEndpoint = ReportEndpoint(ApiClient().init());
      reportEndpoint.addComment(widget.report.id, newComment,
          _prefs?.getString("username") ?? "unknown");
      _commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF18453B), // MSU Green background
      appBar: AppBar(
        title: Text(
          widget.report.title,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF18453B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      "http://35.21.205.135:8000/${widget.report.photoUrl}",
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Section
                  _buildInfoRow(Icons.description,
                      widget.report.description ?? "No description provided"),

                  const SizedBox(height: 12),

                  // Location Section
                  _buildInfoRow(
                    Icons.location_on,
                    _placemarks.isNotEmpty
                        ? "${_placemarks.first.street}, ${_placemarks.first.locality}, ${_placemarks.first.administrativeArea} ${_placemarks.first.postalCode}, ${_placemarks.first.country}"
                        : "No location provided",
                  ),

                  const SizedBox(height: 12),

                  // Date Section
                  _buildInfoRow(
                    Icons.calendar_today,
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          widget.report.timestamp * 1000),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comments Section Title
                  const Text(
                    "Comments",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),

                  // Comment List
                  widget.report.comments.isEmpty
                      ? const Text("No comments yet.",
                          style: TextStyle(color: Colors.white))
                      : Column(
                          children: widget.report.comments.map((comment) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile icon placeholder
                                  const CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.white,
                                    child: Icon(Icons.person,
                                        color: Color(0xFF18453B)),
                                  ),
                                  const SizedBox(width: 10),

                                  // Comment content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.authorId,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        Text(
                                          comment.comment,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          ),

          // Add Comment Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                // Profile icon placeholder
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF18453B),
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),

                // Text field
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Add a comment...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF18453B)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build rows with icons & text
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
