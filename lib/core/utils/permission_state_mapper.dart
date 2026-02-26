import 'package:permission_handler/permission_handler.dart';

import '../types/permission_state.dart';

PermissionState mapPermissionStatus(PermissionStatus status) {
  if (status.isGranted) {
    return PermissionState.granted;
  }
  if (status.isPermanentlyDenied) {
    return PermissionState.permanentlyDenied;
  }
  if (status.isRestricted) {
    return PermissionState.restricted;
  }
  if (status.isDenied) {
    return PermissionState.denied;
  }
  return PermissionState.unavailable;
}

