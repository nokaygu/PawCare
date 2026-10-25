import 'package:flutter/material.dart';

import 'app/bootstrap.dart';

export 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PawCareBootstrap());
}
