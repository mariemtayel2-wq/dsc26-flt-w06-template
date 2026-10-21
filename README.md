# dsc26-flt-w06 · Wiqaya guided capture: the logic behind the camera

DSC Summer Internship 2026 · Flutter track · Week 6 · **Flutter 3.47.6, Dart 3.13, `crypto` 3.0.7** · expected time 3–4 hours

## Scenario

A Wiqaya claimant must photograph their car from 8 standard angles, plus close-ups of the damage. The camera itself cannot run in a test, but almost everything that decides whether the claim file is good can: whether each photo is usable, which angle comes next, whether the same photo was used twice, whether the evidence record is trustworthy, and whether the app asks for the camera politely. You build that logic, and one small widget that guides the user.

## Getting started

1. **Use this template** → a **public** repository in your own account named exactly **`dsc26-flt-w06`**.
2. `flutter pub get`, then `flutter test` (the public tests fail until you implement the task).

Do **not** rename the package (`name: dsc26_flt_w06`). A renamed package scores 0.

## File layout

```text
lib/
  capture/capture_angle.dart     CaptureAngle, angleLabel (given, do not change)
  capture/quality_checker.dart   GrayImage, QualityIssue, QualityThresholds (given); meanBrightness, laplacianVariance, checkQuality (you write them)
  capture/capture_session.dart   CaptureResult, Accepted, Rejected, Duplicate (given); CaptureSession (you write it)
  evidence/evidence.dart         GeoPoint (given); sha256Hex, EvidenceRecord.canonicalJson (you write them)
  permissions/camera_permission_flow.dart   CameraPermissionState, PermissionDecision subclasses, PermissionGateway (given); CameraPermissionFlow (you write it)
  ui/capture_guide.dart          CaptureGuide (you write it)
  main.dart                      demo app (given, not graded; uses a fake gateway and a placeholder grey image, no camera plugin)
test/public_test.dart
AI_USAGE.md
```

You may add files, but keep every class, method and constructor named below with the exact signature: the hidden tests import them directly.

## Part 1: quality checker (`lib/capture/quality_checker.dart`)

On the given `GrayImage({required int width, required int height, required Uint8List pixels})` (row-major, one byte per pixel):

- `double meanBrightness(GrayImage img)`: the mean of every pixel.
- `double laplacianVariance(GrayImage img)`: for every interior pixel (not on the 1-pixel border) compute `L = top + bottom + left + right − 4 × centre`, then return the **population** variance (divide by `n`, not `n − 1`) of all the `L` values. Images narrower or shorter than 3 pixels (no interior pixel) return `0.0`.
- `List<QualityIssue> checkQuality(GrayImage img, {QualityThresholds thresholds = const QualityThresholds()})`, with defaults `minWidth 640`, `minHeight 480`, `darkBelow 50`, `brightAbove 215`, `minSharpness 100`. If the image is smaller than the minimum width or height, return `[QualityIssue.tooSmall]` only — skip every other check. Otherwise include `tooDark` if the mean brightness is below `darkBelow`, `tooBright` if it is above `brightAbove`, `blurry` if the sharpness (`laplacianVariance`) is below `minSharpness`, **in that order** (the order of the `QualityIssue` enum).
- Must handle a 640×480 image in under 200 ms in the test environment: a couple of straightforward loops over the pixels, no need for anything clever.

## Part 2: capture session (`lib/capture/capture_session.dart`)

`class CaptureSession extends ChangeNotifier`:

- Angles are the given `CaptureAngle` enum, asked for in its declared order: `front, frontLeft, left, rearLeft, rear, rearRight, right, frontRight`.
- `CaptureAngle? get nextRequiredAngle`: the first angle in enum order with no accepted photo; `null` once all 8 have one.
- `bool get isComplete`; `double get progress` (accepted angles ÷ 8).
- `CaptureResult submit(CaptureAngle angle, Uint8List bytes, List<QualityIssue> issues)`:
  1. If `issues` is non-empty, return `Rejected(issues)` — whatever else is true about the bytes or the angle.
  2. Otherwise, if `angle` already has an accepted photo, **throw `StateError`** (a plain double submit).
  3. Otherwise, if the same bytes (compare by SHA-256) are already accepted for a *different* angle, return `Duplicate(thatAngle)`; if they match an already-accepted close-up instead, return `Duplicate(null)`.
  4. Otherwise accept the photo, notify listeners, and return `Accepted()`.
- `void retake(CaptureAngle angle)` removes the accepted photo for that angle (if any) and notifies listeners, reopening the angle.
- `CaptureResult addCloseUp(Uint8List bytes, List<QualityIssue> issues)`: the same quality and duplicate rules as `submit` (steps 1 and 3, there is no "angle" to double-submit); once `maxCloseUps` (constructor parameter, default 6) close-ups are accepted, further calls **throw `StateError`**. Accepting a close-up does not notify listeners.

`CaptureResult`, `Accepted`, `Rejected(issues)` and `Duplicate(existingAngle)` are given; do not change them.

## Part 3: evidence (`lib/evidence/evidence.dart`)

- `String sha256Hex(Uint8List bytes)`: the lower-case hex SHA-256 digest (use `package:crypto`).
- `EvidenceRecord({required Uint8List bytes, required CaptureAngle angle, required DateTime capturedAt, required String deviceModel, required String appVersion, required bool locationConsent, GeoPoint? location})` with `String canonicalJson()`: a JSON object (plain `jsonEncode`, no extra whitespace) with keys in exactly this order: `angle` (the enum's `.name`), `appVersion`, `capturedAt` (`capturedAt.toUtc().toIso8601String()`), `deviceModel`, `location` (an object `{"lat": ..., "lng": ...}`, each coordinate rounded with `(v * 1000).round() / 1000` — **the key is omitted entirely** unless `locationConsent` is `true` and `location` is not `null`), `sha256` (of `bytes`), `sizeBytes` (`bytes.length`).

`GeoPoint` is given; do not change it.

## Part 4: permission flow (`lib/permissions/camera_permission_flow.dart`)

`CameraPermissionFlow(PermissionGateway gateway)`:

- `Future<PermissionDecision> onCaptureTapped()`: read `gateway.status()`.
  - `granted` or `limited` → `Proceed()`.
  - `restricted` → `Unavailable(canAskAgain: false)`.
  - `permanentlyDenied` → `ShowSettingsHelp()`.
  - `denied` → if `gateway.shouldShowRationale()` is `true`, return `ShowRationale()` **without calling `request()`**; otherwise call `gateway.request()` once and map the result (below).
- `Future<PermissionDecision> onRationaleAccepted()`: call `gateway.request()` once and map the result.
- `Future<PermissionDecision> onRationaleDeclined()`: return `Unavailable(canAskAgain: true)` **without any gateway call**.
- Mapping a `request()` result: `granted`/`limited` → `Proceed()`; `permanentlyDenied` → `ShowSettingsHelp()`; `restricted` → `Unavailable(canAskAgain: false)`; `denied` → `Unavailable(canAskAgain: true)`.
- `Future<bool> onOpenSettingsTapped()` is the **only** method allowed to call `gateway.openSettings()`.

`CameraPermissionState`, `PermissionDecision` and its subclasses, and `PermissionGateway` are given; do not change them.

## Part 5: guide widget (`lib/ui/capture_guide.dart`)

`CaptureGuide({required CaptureSession session})` listens to the session (it is a `ChangeNotifier`) and rebuilds when it changes:

- While incomplete: a `Text` with key `capture-instruction` showing `angleLabel(next)` (the given helper, `next = session.nextRequiredAngle`), wrapped in a widget keyed `capture-step` whose **entire** semantics label is `Step N of 8: <label>`, where `N = ` (accepted angles so far) `+ 1`. No other text should merge into that semantics node.
- Once `session.isComplete`: show a widget keyed `capture-complete` instead of `capture-step`/`capture-instruction`.

## Keys the tests use

| Key | Widget |
|---|---|
| `capture-step` | The step container, while incomplete (carries the `Step N of 8: ...` semantics label) |
| `capture-instruction` | The `Text` showing the current angle's label |
| `capture-complete` | Shown instead of the two above once all 8 angles are accepted |

## How grading works

Push, then press **Submit for grading** on DSC Hex (5 attempts per task per day). The grader copies your `lib/` into a clean project with the pinned packages, adds the hidden tests and runs `flutter test` on Flutter 3.47.6 with the network off: 10-minute limit, 30 s per test.

| Row | Public name | Weight |
|---|---|---|
| H01 | brightness | 8 |
| H02 | sharpness | 12 |
| H03 | quality thresholds | 10 |
| H04 | custom thresholds | 5 |
| H05 | session: progress | 8 |
| H06 | session: rejections and retakes | 10 |
| H07 | close-ups | 5 |
| H08 | hashing | 5 |
| H09 | canonical evidence | 12 |
| H10 | permission: no request needed | 8 |
| H11 | permission: asking | 9 |
| H12 | guide widget | 8 |

Row score = weight × passed ÷ total. If `lib/` does not compile, you score 0 and see the first compiler errors in your files. H01 and H02 are generated from a per-submission seed and compared against DSC's own reference implementation, so a hard-coded value cannot pass, and the tolerance is tight enough that a sample variance (dividing by `n − 1` instead of `n`) fails. H09 compares your exact canonical string, so key order and formatting matter. H11 counts how many times your flow called `gateway.request()`, so a flow that "works" by always requesting fails.

Late policy: ×1.0 within 72 hours of the session starting, ×0.6 for the following 7 days, ×0.5 after that. Best attempt counts.

## `AI_USAGE.md` (required)

Fill in: the tools you used; your best prompts; one place the assistant got the maths or the permission rules wrong (for example sample vs population variance, or opening Settings automatically); and two sentences on which part of Wiqaya's capture flow you would run on the phone and which on the server, and why.
