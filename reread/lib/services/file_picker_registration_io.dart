import 'dart:io';

import 'package:file_picker/file_picker.dart';
// ignore: implementation_imports
import 'package:file_picker/src/windows/file_picker_windows.dart'
    as windows_picker;

/// Explicitly register file_picker on native targets before the first use.
/// This also covers desktop runners where the generated Dart plugin
/// registration may not have run after adding a new dependency.
void ensureFilePickerRegistered() {
  if (Platform.isLinux) {
    FilePickerLinux.registerWith();
  } else if (Platform.isMacOS) {
    FilePickerMacOS.registerWith();
  } else if (!Platform.isWindows) {
    FilePickerIO.registerWith();
  } else {
    windows_picker.FilePickerWindows.registerWith();
  }
}
