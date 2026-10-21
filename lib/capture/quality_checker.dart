/// Plain image statistics used to accept or reject a claim photo before it
/// ever leaves the phone. No camera, no plugin: a [GrayImage] is just bytes.
///
/// TODO(intern): implement meanBrightness, laplacianVariance and
/// checkQuality. GrayImage, QualityIssue and QualityThresholds are given.
import 'dart:typed_data';

/// A greyscale image, row-major, one byte (0-255) per pixel. Given: do not
/// change.
class GrayImage {
  const GrayImage({
    required this.width,
    required this.height,
    required this.pixels,
  });

  final int width;
  final int height;

  /// Length must be `width * height`. `pixels[y * width + x]` is the pixel
  /// at column `x`, row `y`.
  final Uint8List pixels;
}

/// A problem found with a captured photo, in the order [checkQuality]
/// reports them. Given: do not change.
enum QualityIssue { tooSmall, tooDark, tooBright, blurry }

/// Default thresholds for [checkQuality]. Given: do not change.
class QualityThresholds {
  const QualityThresholds({
    this.minWidth = 640,
    this.minHeight = 480,
    this.darkBelow = 50,
    this.brightAbove = 215,
    this.minSharpness = 100,
  });

  final int minWidth;
  final int minHeight;
  final double darkBelow;
  final double brightAbove;
  final double minSharpness;
}

/// The mean of every pixel in [img]. An empty image (`width * height == 0`)
/// has a mean brightness of `0.0`.
double meanBrightness(GrayImage img) {
  throw UnimplementedError('meanBrightness');
}

/// The population variance of the discrete Laplacian `L = top + bottom +
/// left + right - 4 * centre`, computed at every interior pixel (one pixel
/// away from every edge). Images narrower or shorter than 3 pixels, which
/// have no interior pixel, return `0.0`.
double laplacianVariance(GrayImage img) {
  throw UnimplementedError('laplacianVariance');
}

/// The quality problems with [img] against [thresholds], in [QualityIssue]
/// order. If the image is smaller than the minimum size, every other check
/// is skipped and only [QualityIssue.tooSmall] is reported.
List<QualityIssue> checkQuality(
  GrayImage img, {
  QualityThresholds thresholds = const QualityThresholds(),
}) {
  throw UnimplementedError('checkQuality');
}
