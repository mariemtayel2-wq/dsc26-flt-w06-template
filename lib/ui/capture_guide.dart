/// The small widget that tells the claimant which angle to shoot next.
///
/// TODO(intern): implement CaptureGuide. See the README for the exact keys
/// and the semantics label `CaptureGuide` must expose.
import 'package:flutter/material.dart';

import '../capture/capture_angle.dart';
import '../capture/capture_session.dart';

class CaptureGuide extends StatelessWidget {
  const CaptureGuide({super.key, required this.session});

  final CaptureSession session;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: session,
      builder: (context, child) {
        final next = session.nextRequiredAngle;
        if (next == null) {
          return const Text('Capture complete', key: Key('capture-complete'));
        }

        final step = CaptureAngle.values.indexOf(next) + 1;
        final label = angleLabel(next);
        return Semantics(
          key: const Key('capture-step'),
          label: 'Step $step of 8: $label',
          excludeSemantics: true,
          child: Text(label, key: const Key('capture-instruction')),
        );
      },
    );
  }
}
