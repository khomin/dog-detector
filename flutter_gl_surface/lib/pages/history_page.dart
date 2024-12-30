import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => HistoryPageState();
}

// TODO: here is main page
// 1 start recording button
// 2 an optioon to see previous videos -> delete, ListView
// NavigationBar -> Settings

class HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Text('history');
  }
}
