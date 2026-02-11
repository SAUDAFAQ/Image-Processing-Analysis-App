/// Base failure for the app. All domain/data errors map to this.
/// Enables consistent handling in UI (snackbar/dialog) without leaking impl details.
abstract class AppFailure {
  const AppFailure(this.message);
  final String message;

  /// When an [AppFailure] is shown in logs / snackbars using `toString()`,
  /// we want the human‑readable message instead of `Instance of 'XFailure'`.
  @override
  String toString() => message;
}

class PermissionFailure extends AppFailure {
  const PermissionFailure(super.message);
}

class ImageLoadFailure extends AppFailure {
  const ImageLoadFailure(super.message);
}

class MLFailure extends AppFailure {
  const MLFailure(super.message);
}

class StorageFailure extends AppFailure {
  const StorageFailure(super.message);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
