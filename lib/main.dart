/// Demo app for trying the capture flow on your own phone. Not graded: the
/// grader never runs this file. A real app would wire `lib/permissions/
/// camera_permission_flow.dart` to the `permission_handler` plugin and
/// `lib/capture/` to the `camera` plugin's preview and `takePicture()`; this
/// demo uses an in-memory fake gateway and a generated grey image instead,
/// so the template keeps exactly the pinned dependencies in pubspec.yaml and
/// nothing here can fail to compile for someone without a phone attached.
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'capture/capture_angle.dart';
import 'capture/capture_session.dart';
import 'capture/quality_checker.dart';
import 'permissions/camera_permission_flow.dart';
import 'ui/capture_guide.dart';

class _DemoGateway implements PermissionGateway {
  CameraPermissionState current = CameraPermissionState.denied;
  int requests = 0;

  @override
  Future<CameraPermissionState> status() async => current;

  @override
  Future<CameraPermissionState> request() async {
    requests++;
    current = CameraPermissionState.granted;
    return current;
  }

  @override
  Future<bool> shouldShowRationale() async => requests == 0;

  @override
  Future<bool> openSettings() async => true;
}

void main() => runApp(const WiqayaCaptureDemo());

class WiqayaCaptureDemo extends StatelessWidget {
  const WiqayaCaptureDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wiqaya guided capture (demo)')),
        body: _CaptureDemoBody(
          session: CaptureSession(),
          flow: CameraPermissionFlow(_DemoGateway()),
        ),
      ),
    );
  }
}

class _CaptureDemoBody extends StatefulWidget {
  const _CaptureDemoBody({required this.session, required this.flow});

  final CaptureSession session;
  final CameraPermissionFlow flow;

  @override
  State<_CaptureDemoBody> createState() => _CaptureDemoBodyState();
}

class _CaptureDemoBodyState extends State<_CaptureDemoBody> {
  String _status = 'Tap "Start photos" to begin.';

  Future<void> _onStartPhotos() async {
    final decision = await widget.flow.onCaptureTapped();
    setState(() => _status = decision.runtimeType.toString());
  }

  void _onSimulateShot() {
    // A plain mid-grey 640x480 placeholder, standing in for a real frame.
    final img = GrayImage(
      width: 640,
      height: 480,
      pixels: Uint8List(640 * 480)..fillRange(0, 640 * 480, 140),
    );
    final issues = checkQuality(img);
    final bytes = Uint8List.fromList(img.pixels);
    final angle = widget.session.nextRequiredAngle;
    if (angle == null) return;
    final result = widget.session.submit(angle, bytes, issues);
    setState(() => _status = result.runtimeType.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CaptureGuide(session: widget.session),
          const SizedBox(height: 16),
          Text(_status),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _onStartPhotos, child: const Text('Start photos')),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _onSimulateShot, child: const Text('Simulate a shot')),
        ],
      ),
    );
  }
}
