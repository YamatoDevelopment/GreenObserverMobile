import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class ReportPage extends StatefulWidget {
  final String? path;

  const ReportPage(this.path, {super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormBuilderState>();

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
                FormBuilderDropdown(name: 'tag', items: [
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
                          onPressed: () {}, child: const Text('Submit'))),
                )
              ],
            )))
      ],
    ));
  }
}
