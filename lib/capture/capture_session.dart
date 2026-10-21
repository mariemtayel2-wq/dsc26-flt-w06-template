/// The state of one claimant's 8-angle capture plus close-ups, independent
/// of the camera: whichever bytes `submit`/`addCloseUp` receive.
///
/// TODO(intern): implement CaptureSession. CaptureResult and its subclasses
/// are given.
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'capture_angle.dart';
import 'quality_checker.dart';

/// The outcome of submitting one photo. Given: do not change.
sealed class CaptureResult {
  const CaptureResult();
}

/// The photo was accepted.
class Accepted extends CaptureResult {
  const Accepted();
}

/// The photo failed the quality gate.
class Rejected extends CaptureResult {
  const Rejected(this.issues);
  final List<QualityIssue> issues;
}

/// The same bytes (by SHA-256) are already accepted somewhere. [existingAngle]
/// is the angle that already holds them, or `null` when the match is a
/// close-up.
class Duplicate extends CaptureResult {
  const Duplicate(this.existingAngle);
  final CaptureAngle? existingAngle;
}

/// Tracks the 8 required angles plus up to [maxCloseUps] close-ups for one
/// claim.
class CaptureSession extends ChangeNotifier {
  CaptureSession({this.maxCloseUps = 6});

  final int maxCloseUps;

  /// The first angle, in enum order, with no accepted photo. `null` once
  /// every angle has one.
  CaptureAngle? get nextRequiredAngle => throw UnimplementedError('nextRequiredAngle');

  bool get isComplete => throw UnimplementedError('isComplete');

  /// Accepted angles out of the 8 required, as a fraction.
  double get progress => throw UnimplementedError('progress');

  /// Submits a photo for [angle]. Rejects on quality issues first; then, if
  /// [angle] already has an accepted photo, throws [StateError] (a plain
  /// double submit, whatever the bytes); then checks for a duplicate against
  /// every other accepted angle and every close-up; otherwise accepts.
  CaptureResult submit(
    CaptureAngle angle,
    Uint8List bytes,
    List<QualityIssue> issues,
  ) {
    throw UnimplementedError('submit');
  }

  /// Removes the accepted photo for [angle] (if any), reopening it.
  void retake(CaptureAngle angle) {
    throw UnimplementedError('retake');
  }

  /// Adds a close-up. Same quality and duplicate rules as [submit]; once
  /// [maxCloseUps] close-ups are accepted, further calls throw [StateError].
  CaptureResult addCloseUp(Uint8List bytes, List<QualityIssue> issues) {
    throw UnimplementedError('addCloseUp');
  }
}
