import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppServices.initialize();

  runApp(const PlantCareApp());
}
