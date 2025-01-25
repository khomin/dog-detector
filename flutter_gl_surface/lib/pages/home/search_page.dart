import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/pages/home/grid_dialog.dart';
import 'package:flutter_demo/pages/home/view_item1.dart';
import 'package:flutter_demo/pages/home/search_model.dart';
import 'package:flutter_demo/repo/my_rep.dart';
import 'package:flutter_demo/repo/nav_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:flutter_demo/resource/disposable_stream.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final _model = SearchModel();
  final _scrollCtr = ScrollController();
  final _focus = FocusNode();
  final _dispStream = DisposableStream();
  final _textCtr = TextEditingController();

  @override
  void initState() {
    super.initState();

    _scrollCtr.addListener(() {
      _focus.unfocus();
    });
    _textCtr.addListener(() {
      _model.setSearch(_textCtr.value.text);
    });
  }

  @override
  void dispose() {
    _scrollCtr.dispose();
    _dispStream.dispose();
    _textCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: _model,
        builder: (context, child) {
          return Container(
              color: Constants.colorBar,
              child: SafeArea(
                  child: Scaffold(
                      backgroundColor: Constants.colorBgUnderCard,
                      appBar: AppBar(
                          centerTitle: false,
                          shadowColor: Colors.black,
                          elevation: 0.1,
                          backgroundColor: Constants.colorBgUnderCard,
                          leading: RoundButton(
                              color: Colors.transparent,
                              iconColor: Colors.black,
                              size: 50,
                              iconSize: 22,
                              padding: const EdgeInsets.only(left: 10),
                              iconData: Icons.arrow_back_ios,
                              onPressed: (v) async {
                                Navigator.pop(context);
                              }),
                          titleSpacing: 0,
                          title: _header()),
                      body: _gallery())));
        });
  }

  Widget _header() {
    return HoverClick(
        onPressedL: (_) {
          _focus.requestFocus();
        },
        child: SizedBox(
            // color: Colors.amber,
            height: kToolbarHeight,
            child: Row(children: [
              Flexible(
                  child: TextField(
                      controller: _textCtr,
                      focusNode: _focus,
                      maxLines: 1,
                      decoration: const InputDecoration.collapsed(
                          hintText: 'Search ex: 01.01.2025',
                          hintStyle: TextStyle(
                              color: Constants.colorTextSecond,
                              fontSize: 15,
                              fontWeight: FontWeight.w400)),
                      style: const TextStyle(
                          color: Constants.colorTextAccent,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                      cursorColor: Constants.colorTextSecond)),
              Builder(builder: (context) {
                var search = context.watch<SearchModel>().search;
                var empty = search == null || search.isEmpty;
                if (empty) {
                  return const SizedBox();
                }
                return RoundButton(
                    iconData: Icons.clear_sharp,
                    color: Colors.transparent,
                    iconSize: 22,
                    margin: const EdgeInsets.only(right: 15),
                    size: 40,
                    iconColor: Constants.colorTextAccent.withOpacity(0.5),
                    onPressed: (_) {
                      _textCtr.clear();
                    });
              })
            ])));
  }

  Widget _gallery() {
    return Builder(builder: (context) {
      var search = context.watch<SearchModel>().search;
      var history =
          context.select<SearchModel, List<HistoryRecord>>((v) => v.result);
      if (history.isEmpty) {
        return HoverClick(
            onPressedL: (_) {
              _focus.unfocus();
            },
            child: SizedBox(
                // color: Colors.yellow,
                height: NavigatorRep().size.height / 1.2,
                width: double.infinity,
                child: search != null && search.isNotEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                            Icon(
                              Icons.screen_search_desktop_rounded,
                              size: NavigatorRep().size.width / 5,
                              color: Constants.colorPrimary,
                              shadows: [
                                Shadow(
                                    color:
                                        Constants.colorPrimary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 1))
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text('No results',
                                style: TextStyle(
                                    color: Constants.colorTextAccent
                                        .withOpacity(0.7),
                                    fontSize: 18,
                                    shadows: const <Shadow>[
                                      // Shadow(
                                      //     color: Constants.colorPrimary
                                      //         .withOpacity(0.6),
                                      //     blurRadius: 25,
                                      //     offset: const Offset(0, 1)
                                      //     // offset: Offset(10.0, 10.0),
                                      //     // blurRadius: 5.0,
                                      //     // color: Colors.black,
                                      //     )
                                    ]))
                          ])
                    : const SizedBox()));
      }
      return SizedBox(
          height: ((270 + 28) * history.length).toDouble(),
          child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverList.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      var model = history[index];
                      return ViewItem1(
                          history: model,
                          useSwipe: false,
                          key: ValueKey('history-${model.items.lastOrNull}'),
                          onPressed: () {
                            GridDialog()
                                .show(
                                    context: context,
                                    history: model,
                                    initialIndex: index)
                                .then((value) {});
                          },
                          onDelete: () async {
                            await MyRep().deleteHistoryRoot([model]);
                          });
                    })
              ]));
    });
  }
}
