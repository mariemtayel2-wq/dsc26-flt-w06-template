/// Evidence integrity: a hash of the exact bytes uploaded, and a canonical,
/// privacy-aware metadata record.
///
/// TODO(intern): implement sha256Hex and EvidenceRecord.canonicalJson.
/// GeoPoint is given.
import 'dart:typed_data';

import '../capture/capture_angle.dart';

/// A coarse geographic point. Given: do not change.
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// The lower-case hex SHA-256 digest of [bytes].
String sha256Hex(Uint8List bytes) {
  throw UnimplementedError('sha256Hex');
}

/// One captured photo plus the facts a surveyor or a regulator needs to
/// trust it.
class EvidenceRecord {
  const EvidenceRecord({
    required this.bytes,
    required this.angle,
    required this.capturedAt,
    required this.deviceModel,
    required this.appVersion,
    required this.locationConsent,
    this.location,
  });

  final Uint8List bytes;
  final CaptureAngle angle;
  final DateTime capturedAt;
  final String deviceModel;
  final String appVersion;
  final bool locationConsent;
  final GeoPoint? location;

  /// A canonical JSON string: keys in sorted order, no whitespace beyond
  /// what `jsonEncode` produces, times as UTC ISO-8601, location rounded to
  /// 3 decimal places and omitted entirely without consent or a point.
  String canonicalJson() {
    throw UnimplementedError('EvidenceRecord.canonicalJson');
  }
}
