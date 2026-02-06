import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routes.dart' as page;

void main() {
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends MaterialApp {
  MainApp({super.key})
    : super.router(
        title: "Nile University Schedule Generator",
        theme: ThemeData(brightness: Brightness.light),
        darkTheme: ThemeData(brightness: Brightness.dark),
        themeMode: ThemeMode.system,
        routerConfig: page.routerConfig,
      );
}
