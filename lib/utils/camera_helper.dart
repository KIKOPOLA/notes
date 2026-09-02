import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'camera_helper_io.dart' if (dart.library.html) 'camera_helper_web.dart';

Future<Uint8List?> captureCameraPhoto(BuildContext context) => captureCameraPhotoImpl(context);
