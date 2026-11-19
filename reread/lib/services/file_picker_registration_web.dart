import 'package:file_picker/_internal/file_picker_web.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// The web picker uses browser file inputs and doesn't need a channel handler.
void ensureFilePickerRegistered() {
  FilePickerWeb.registerWith(Registrar());
}
