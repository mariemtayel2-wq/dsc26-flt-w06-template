/// The 8 standard angles a Wiqaya claimant photographs, in the fixed order
/// the capture flow asks for them. Given: do not change.
enum CaptureAngle {
  front,
  frontLeft,
  left,
  rearLeft,
  rear,
  rearRight,
  right,
  frontRight,
}

/// A short, claimant-facing label for [angle].
String angleLabel(CaptureAngle angle) => switch (angle) {
      CaptureAngle.front => 'Front',
      CaptureAngle.frontLeft => 'Front-left corner',
      CaptureAngle.left => 'Left side',
      CaptureAngle.rearLeft => 'Rear-left corner',
      CaptureAngle.rear => 'Rear',
      CaptureAngle.rearRight => 'Rear-right corner',
      CaptureAngle.right => 'Right side',
      CaptureAngle.frontRight => 'Front-right corner',
    };
