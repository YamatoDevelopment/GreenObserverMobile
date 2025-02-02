import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:greenobserver/models.dart';
import 'package:intl/intl.dart';

class ViewReportPage extends StatefulWidget {
  final Report report;

  const ViewReportPage({super.key, required this.report});

  @override
  State<ViewReportPage> createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  List<Placemark> _placemarks = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      var placemarks = await placemarkFromCoordinates(
          widget.report.locationLat, widget.report.locationLon);
      setState(() {
        // Update the state to reflect the new placemarks
        _placemarks = placemarks;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.report.title)),
        body: SingleChildScrollView(
            child: Column(children: [
          Image.network("http://35.21.205.135:8000/${widget.report.photoUrl}"),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Description"),
                Text(widget.report.description ?? "No description provided"),
                Text("Location"),
                Text(_placemarks.isNotEmpty
                    ? "${_placemarks.first.street}, ${_placemarks.first.locality}, ${_placemarks.first.administrativeArea} ${_placemarks.first.postalCode}, ${_placemarks.first.country}"
                    : "No location provided"),
                // Text(widget.report.locationLat.toString() ??
                //     "No location provided"),
                // Text(widget.report.locationLon.toString() ??
                //     "No location provided"),
                Text("Date"),
                // Convert epoch timestamp to DateTime
                Text(DateFormat('dd/MM/yyyy HH:mm:ss').format(
                    DateTime.fromMillisecondsSinceEpoch(
                        widget.report.timestamp * 1000))),
              ],
            ),
          ),
        ])));
  }
}
