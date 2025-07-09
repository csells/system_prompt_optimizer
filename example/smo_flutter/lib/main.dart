import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/smo_provider.dart';
import 'screens/smo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  runApp(
    ChangeNotifierProvider(create: (_) => SmoProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Message Optimizer',
      home: const SmoScreen(),
    );
  }
}
