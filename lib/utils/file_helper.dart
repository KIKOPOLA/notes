import 'dart:typed_data';

import 'file_helper_io.dart' if (dart.library.html) 'file_helper_web.dart';

Future<Uint8List> readFileBytes(String path) => readFileBytesImpl(path);
