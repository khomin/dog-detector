import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => SettingsPageState();
}

// TODO: here is main page
// 1 start recording button
// 2 an optioon to see previous videos -> delete, ListView
// NavigationBar -> Settings

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Text('settings');
  }
}
