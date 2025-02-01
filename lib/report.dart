import 'dart:io';

import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  final String? path;

  const ReportPage(this.path, {super.key});

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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
        Form(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton(
                          onPressed: () {}, child: const Text('Submit'))),
                )
              ],
            ),
          ),
        )
      ],
    ));
  }
}
