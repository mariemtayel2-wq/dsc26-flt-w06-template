/// The small widget that tells the claimant which angle to shoot next.
///
/// TODO(intern): implement CaptureGuide. See the README for the exact keys
/// and the semantics label `CaptureGuide` must expose.
import 'package:flutter/material.dart';

import '../capture/capture_session.dart';

class CaptureGuide extends StatelessWidget {
  const CaptureGuide({super.key, required this.session});

  final CaptureSession session;

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError('CaptureGuide.build');
  }
}
