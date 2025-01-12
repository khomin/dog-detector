import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/app.dart';
import 'package:flutter_demo/resource/constants.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor:
          Colors.white, // Set navigation bar color to white
      systemNavigationBarIconBrightness:
          Brightness.dark, // Set icons to dark for contrast
      statusBarColor: Colors
          .transparent, //Constants.colorPrimary, // Optional: Change the status bar color
      statusBarIconBrightness:
          Brightness.dark // Optional: Dark icons on status bar));
      ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          splashColor: Colors.transparent,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // Choose a seed color
            primary: Constants.colorPrimary, // Primary color
            secondary: Colors.green, // Secondary color
            surface: Colors.white, // Surface color
            // background: Colors.grey[200]!, // Background color
            error: Colors.red, // Error color
          )),
      home: const App(),
    );
  }
}
