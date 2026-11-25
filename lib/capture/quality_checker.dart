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
  if (img.pixels.isEmpty) return 0.0;

  var total = 0;
  for (final pixel in img.pixels) {
    total += pixel;
  }
  return total / img.pixels.length;
}

/// The population variance of the discrete Laplacian `L = top + bottom +
/// left + right - 4 * centre`, computed at every interior pixel (one pixel
/// away from every edge). Images narrower or shorter than 3 pixels, which
/// have no interior pixel, return `0.0`.
double laplacianVariance(GrayImage img) {
  if (img.width < 3 || img.height < 3) return 0.0;

  var count = 0;
  var mean = 0.0;
  var sumOfSquaredDeviations = 0.0;
  for (var row = 1; row < img.height - 1; row++) {
    final rowOffset = row * img.width;
    for (var column = 1; column < img.width - 1; column++) {
      final index = rowOffset + column;
      final laplacian =
          img.pixels[index - img.width] +
          img.pixels[index + img.width] +
          img.pixels[index - 1] +
          img.pixels[index + 1] -
          4 * img.pixels[index];
      count++;
      final delta = laplacian - mean;
      mean += delta / count;
      sumOfSquaredDeviations += delta * (laplacian - mean);
    }
  }

  return sumOfSquaredDeviations / count;
}

/// The quality problems with [img] against [thresholds], in [QualityIssue]
/// order. If the image is smaller than the minimum size, every other check
/// is skipped and only [QualityIssue.tooSmall] is reported.
List<QualityIssue> checkQuality(
  GrayImage img, {
  QualityThresholds thresholds = const QualityThresholds(),
}) {
  if (img.width < thresholds.minWidth || img.height < thresholds.minHeight) {
    return [QualityIssue.tooSmall];
  }

  final issues = <QualityIssue>[];
  final brightness = meanBrightness(img);
  if (brightness < thresholds.darkBelow) {
    issues.add(QualityIssue.tooDark);
  }
  if (brightness > thresholds.brightAbove) {
    issues.add(QualityIssue.tooBright);
  }
  if (laplacianVariance(img) < thresholds.minSharpness) {
    issues.add(QualityIssue.blurry);
  }
  return issues;
}
