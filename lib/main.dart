import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/local/hive_boxes.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBoxes.initFlutterAndOpen();
  runApp(const PawCareApp());
}
