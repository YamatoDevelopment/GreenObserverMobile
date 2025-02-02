import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  final _formKey = GlobalKey<FormBuilderState>();
  SharedPreferences? _prefs;
  List<Placemark> _placemarks = [];

  @override
  void initState() {
    super.initState();
    _getLocation();
    _getPrefs();
  }

  Future<void> _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
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
                Text("Comments"),
                FormBuilder(
                  key: _formKey,
                  child: Column(children: <Widget>[
                    FormBuilderTextField(
                        name: 'comment',
                        decoration:
                            InputDecoration(labelText: 'Add a comment')),
                    Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: ElevatedButton(
                                onPressed: () {
                                  ReportEndpoint reportEndpoint =
                                      ReportEndpoint(ApiClient().init());
                                  reportEndpoint.addComment(
                                      widget.report.id,
                                      _formKey.currentState?.fields['comment']
                                          ?.value,
                                      _prefs?.getString('username') ?? "");
                                },
                                child: Text("Submit")))),
                  ]),
                ),
                ...widget.report.comments.map((comment) => Card(
                      margin: EdgeInsets.zero,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                            title: Text(comment.comment),
                            subtitle: Text(comment.authorId)),
                      ),
                    )),
              ],
            ),
          ),
        ])));
  }
}
