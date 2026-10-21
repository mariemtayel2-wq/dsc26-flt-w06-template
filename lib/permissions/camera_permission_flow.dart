/// The camera permission decision logic, kept plain and testable behind
/// [PermissionGateway] so it never has to touch a real plugin.
///
/// TODO(intern): implement CameraPermissionFlow. Everything else here is
/// given.

/// The states a camera permission can be in, mapped from whatever the real
/// plugin reports. Given: do not change.
enum CameraPermissionState {
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted,
}

/// What the UI should do next. Given: do not change.
sealed class PermissionDecision {
  const PermissionDecision();
}

/// Open the camera.
class Proceed extends PermissionDecision {
  const Proceed();
}

/// Show the app's own rationale before asking the system.
class ShowRationale extends PermissionDecision {
  const ShowRationale();
}

/// The system will not ask again; point the user at Settings only if they
/// ask to use the feature.
class ShowSettingsHelp extends PermissionDecision {
  const ShowSettingsHelp();
}

/// The feature cannot run right now.
class Unavailable extends PermissionDecision {
  const Unavailable({required this.canAskAgain});
  final bool canAskAgain;
}

/// A thin, testable wrapper over whatever permission plugin the app uses.
/// Given: do not change.
abstract interface class PermissionGateway {
  Future<CameraPermissionState> status();
  Future<CameraPermissionState> request();
  Future<bool> shouldShowRationale();
  Future<bool> openSettings();
}

/// Decides what to do about the camera permission without ever asking twice
/// in a row and without nagging after a denial.
class CameraPermissionFlow {
  CameraPermissionFlow(this._gateway);

  final PermissionGateway _gateway;

  /// Called when the user taps the button that starts photo capture.
  Future<PermissionDecision> onCaptureTapped() async {
    throw UnimplementedError('onCaptureTapped');
  }

  /// Called after the user accepts the app's own rationale card.
  Future<PermissionDecision> onRationaleAccepted() async {
    throw UnimplementedError('onRationaleAccepted');
  }

  /// Called when the user dismisses the rationale card without proceeding.
  /// Never touches the gateway.
  Future<PermissionDecision> onRationaleDeclined() async {
    throw UnimplementedError('onRationaleDeclined');
  }

  /// The only method that may open the system settings screen.
  Future<bool> onOpenSettingsTapped() {
    throw UnimplementedError('onOpenSettingsTapped');
  }
}
