import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.awesome(
        sensorConfig: SensorConfig.single(
          aspectRatio: CameraAspectRatios.ratio_16_9,
          flashMode: FlashMode.none,
          zoom: 0.0,
        ),
        saveConfig: SaveConfig.photo(),
        onMediaCaptureEvent: (event) {
          switch (event.status) {
            case MediaCaptureStatus.capturing:
              print('Media capturing...');
            case MediaCaptureStatus.failure:
              print('Media capture failed');
            case MediaCaptureStatus.success:
              print('Media captured successfully');
              event.captureRequest.when(
                single: (single) {
                  print('Photo captured: ${single.file?.path}');
                },
              );
          }
        },
        topActionsBuilder: (state) {
          return Container();
        },
        // Hide the filter button
        // middleContentBuilder: (state) {
        //   return Container();
        // },
        availableFilters: [],
      ),
    );
  }
}
