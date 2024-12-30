import 'package:flutter/material.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/pages/components/history_item.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  List<HistoryRecord> _history = [];
  @override
  void initState() {
    super.initState();

    _fetch();
  }

  Future _fetch() async {
    var history = await MyRep().history();
    setState(() {
      _history = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // color: Theme.of(context).colorScheme.baseColor2,
        child: RefreshIndicator(
            // color: Theme.of(context).colorScheme.baseColor1,
            // backgroundColor: Theme.of(context).colorScheme.iconColor,
            onRefresh: () async {
              await _fetch();
            },
            child: Column(children: [
              Expanded(
                  child: Column(children: <Widget>[
                const Text('Header'),
                Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _history.length,
                        itemBuilder: (context, index) {
                          var i = _history[index];
                          return HistoryItem(history: i);
                        })),
                Expanded(child: Container(color: Colors.red)),
                const Text('Footer'),
              ]))
            ])));
  }
}
