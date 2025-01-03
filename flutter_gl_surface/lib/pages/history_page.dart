import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/history_item.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _fetch();
    });
  }

  Future _fetch() async {
    var history = await MyRep().history();
    if (!mounted) return;
    context.read<AppModel>().setHistory(history);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          await _fetch();
        },
        child: Container(
            color: Constants.colorCard,
            margin: const EdgeInsets.only(top: 20),
            height: double.infinity,
            child: Column(children: [
              Expanded(
                  child: Column(children: [
                Builder(builder: (context) {
                  var history = context
                      .select<AppModel, List<HistoryRecord>>((v) => v.history);
                  return history.isNotEmpty
                      ? Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: history.length,
                                  itemBuilder: (context, index) {
                                    var i = history[index];
                                    return HistoryItem(
                                        history: i,
                                        size: Size(NavigatorRep().size.width,
                                            NavigatorRep().size.width / 2),
                                        onPressed: () {
                                          // NavigatorRep().routeBloc.goto(Panel(
                                          //     type: PageType.history, arg: i));
                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Container(
                                                    height: 200,
                                                    decoration: const BoxDecoration(
                                                        color:
                                                            Constants.colorCard,
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    12))),
                                                    child: Center(
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                          ElevatedButton(
                                                              child: const Text(
                                                                  'Delete'),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              })
                                                        ])));
                                              });
                                        });
                                  })))
                      : const Flexible(
                          child: Center(
                              child: Text("You don't have history yet")));
                }),
                Container(color: Colors.red)
              ]))
            ])));
  }
}
