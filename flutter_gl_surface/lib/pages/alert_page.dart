import 'package:flutter/material.dart';
import 'package:flutter_demo/pages/components/circle_button.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/model/app_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
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
    return Scaffold(
        backgroundColor: Constants.colorBar,
        // backgroundColor: Colors.transparent,
        body: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(children: [
                        const Padding(
                            padding: EdgeInsets.only(left: 25),
                            child:
                                Text('Alert', style: TextStyle(fontSize: 25))),
                        const Spacer(),
                        RoundButton(
                            color: Colors.transparent,
                            iconColor:
                                Constants.colorTextAccent.withOpacity(0.8),
                            size: 70,
                            // margin: EdgeInsets.only(bottom: 10),
                            vertTransform: true,
                            iconData: Icons.arrow_back_ios_new,
                            // iconData: Icons.arrow_back_ios,
                            onPressed: (p0) {
                              var model = context.read<AppModel>();
                              model.setCollapse(!model.collapse);
                            })
                      ]))),
              // SliverFillRemaining(child: _camera())
            ]));
  }
}
