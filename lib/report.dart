import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:greenobserver/api_client.dart';
import 'package:greenobserver/models.dart';
import 'package:greenobserver/providers/report_endpoint.dart';

class ReportPage extends StatefulWidget {
  final String? path;

  const ReportPage(this.path, {super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiClient apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Image.file(File(widget.path!), fit: BoxFit.cover),
        ),
        Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: FormBuilder(
                child: Column(
              children: [
                FormBuilderTextField(
                    name: 'title',
                    decoration: InputDecoration(labelText: 'Title')),
                FormBuilderTextField(
                    name: 'description',
                    decoration: InputDecoration(labelText: 'Description')),
                FormBuilderDropdown<String>(
                    name: 'tag',
                    initialValue: 'litter_and_waste',
                    items: [
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
                    ]),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                          onPressed: () {
                            print("Submitting report");
                            print(_formKey.currentState?.fields['tag']);
                            ReportFormData report = ReportFormData(
                              photo: File(widget.path!),
                              title:
                                  _formKey.currentState?.fields['title']?.value,
                              description: _formKey
                                  .currentState?.fields['description']?.value,
                              locationLat: 0.0,
                              locationLon: 0.0,
                              tag: _formKey.currentState?.fields['tag']?.value,
                              reportedById:
                                  '00000000-0000-0000-0000-000000000000',
                            );
                            print("Created report");

                            ApiClient apiClient = ApiClient();
                            var reportProvider =
                                ReportEndpoint(apiClient.init());
                            reportProvider.createReport(report);
                          },
                          child: const Text('Submit'))),
                )
              ],
            )))
      ],
    ));
  }
}
