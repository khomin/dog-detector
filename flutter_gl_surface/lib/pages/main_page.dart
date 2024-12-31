import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/history_item_thumb.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
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
            color: Constants.colorBackground,
            margin: const EdgeInsets.only(top: 20),
            height: double.infinity,
            child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [_item1()])));
  }

  Widget _item1() {
    return Builder(builder: (context) {
      var history =
          context.select<AppModel, List<HistoryRecord>>((v) => v.history);
      return Container(
          margin: const EdgeInsets.only(left: 30, right: 30, top: 30),
          decoration: const BoxDecoration(
              color: Constants.colorCard,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 210,
          child: Column(children: [
            if (history.isNotEmpty)
              Column(children: [
                // header
                const Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: Row(children: [
                      Icon(Icons.info_outline, size: 18),
                      Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text('Statistic',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w400)))
                    ])),
                // body
                _itemSubLine(
                    text: 'Sessions',
                    value: '${history.length}',
                    firstLine: true),
                _itemSubLine(text: 'Images', value: '450', firstLine: false),
                _itemSubLine(text: 'Storage', value: '4.5Gb', firstLine: false)
              ]),
            history.isNotEmpty
                ? Container(
                    // color: Colors.pink,
                    height: 60,
                    width: double.infinity,
                    margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
                    child: Row(children: [
                      ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            var i = history[index];
                            return HistoryItemThumbnail(
                                history: i,
                                padding: const EdgeInsets.only(right: 2),
                                size: const Size(50, 50),
                                onPressed: () {
                                  NavigatorRep().routeBloc.goto(
                                      Panel(type: PageType.history, arg: i));
                                });
                          })
                    ]))
                : const Flexible(
                    child: Center(child: Text("You don't have history yet")))
          ]));
    });
  }

  Widget _itemSubLine(
      {required String text, required String value, required bool firstLine}) {
    return Padding(
        padding: EdgeInsets.only(left: 20, right: 10, top: firstLine ? 15 : 5),
        child: Row(children: [
          SizedBox(
              width: 100,
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Constants.colorTextSecond.withOpacity(0.7)))),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Constants.colorTextSecond.withOpacity(0.7)))
        ]));
  }
}
