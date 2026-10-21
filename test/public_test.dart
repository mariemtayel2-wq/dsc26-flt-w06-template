import 'dart:convert';
import 'dart:typed_data';

import 'package:dsc26_flt_w06/capture/capture_angle.dart';
import 'package:dsc26_flt_w06/capture/capture_session.dart';
import 'package:dsc26_flt_w06/capture/quality_checker.dart';
import 'package:dsc26_flt_w06/evidence/evidence.dart';
import 'package:dsc26_flt_w06/permissions/camera_permission_flow.dart';
import 'package:flutter_test/flutter_test.dart';

GrayImage flat(int w, int h, int value) => GrayImage(
    width: w, height: h, pixels: Uint8List(w * h)..fillRange(0, w * h, value));

GrayImage checker(int w, int h) {
  final px = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      px[y * w + x] = (x + y).isEven ? 0 : 255;
    }
  }
  return GrayImage(width: w, height: h, pixels: px);
}

class FakeGateway implements PermissionGateway {
  FakeGateway(this.current);
  CameraPermissionState current;
  int requests = 0;

  @override
  Future<CameraPermissionState> status() async => current;
  @override
  Future<CameraPermissionState> request() async {
    requests++;
    return current;
  }
  @override
  Future<bool> shouldShowRationale() async => false;
  @override
  Future<bool> openSettings() async => true;
}

void main() {
  test('a flat grey photo is blurry and nothing else', () {
    expect(checkQuality(flat(640, 480, 128)), [QualityIssue.blurry]);
  });

  test('a checkerboard is sharp and well exposed', () {
    final img = checker(640, 480);
    expect(laplacianVariance(img), closeTo(1040400, 1e-6));
    expect(checkQuality(img), isEmpty);
  });

  test('sha256Hex matches the standard test vector', () {
    expect(sha256Hex(Uint8List.fromList(utf8.encode('abc'))),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
  });

  test('the session asks for angles in order', () {
    final session = CaptureSession();
    expect(session.nextRequiredAngle, CaptureAngle.front);
    final result = session.submit(
        CaptureAngle.front, Uint8List.fromList([1, 2, 3]), const []);
    expect(result, isA<Accepted>());
    expect(session.nextRequiredAngle, CaptureAngle.frontLeft);
    expect(session.progress, closeTo(1 / 8, 1e-9));
  });

  test('a granted camera proceeds without asking again', () async {
    final gateway = FakeGateway(CameraPermissionState.granted);
    final decision = await CameraPermissionFlow(gateway).onCaptureTapped();
    expect(decision, isA<Proceed>());
    expect(gateway.requests, 0);
  });
}
