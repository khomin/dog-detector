// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// enum MainRouteType {
//   main,
//   settings
// }

// class MainPage extends StatefulWidget {
//   const MainPage({super.key});
//   @override
//   State<MainPage> createState() => MainPageState();
// }

// // TODO: here is main page
// // 1 start recording button
// // 2 an optioon to see previous videos -> delete, ListView
// // NavigationBar -> Settings

// class MainPageState extends State<MainPage> {
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) async {
//           if (didPop) return;
//           // var nav = context.read<AppModel>().appNavKey;
//           // if (nav.currentState?.canPop() == true) {
//           //   nav.currentState?.pop();
//           //   return;
//           // }
//           SystemNavigator.pop();
//         },
//         child: Builder(builder: (context) {
//           var page = context.watch<AppModel>().page;
//           return Scaffold(
//               //
//               // drawer mobile
//               drawer:
//                   (UiHelper.isMobile() && context.watch<AppModel>().drawerOn)
//                       ? const Drawer(child: DrawerMenu())
//                       : null,
//               appBar: AppBar(
//                   surfaceTintColor: Theme.of(context).colorScheme.baseColor1,
//                   backgroundColor: Theme.of(context).colorScheme.baseColor1,
//                   centerTitle: true,
//                   shadowColor: Theme.of(context).colorScheme.titel3,
//                   foregroundColor: Theme.of(context).colorScheme.iconColor,
//                   automaticallyImplyLeading: context.watch<AppModel>().drawerOn,
//                   titleSpacing:
//                       (Platform.isIOS || Platform.isAndroid) ? 0 : null,
//                   title: Stack(alignment: Alignment.center, children: [
//                     if (!context.watch<AppModel>().drawerOn)
//                       Row(children: [
//                         CircleButton(
//                             iconData: Icons.arrow_back,
//                             color: Colors.transparent,
//                             onPressed: (_) {
//                               var nav = context.read<AppModel>().appNavKey;
//                               if (nav.currentState?.canPop() == true) {
//                                 nav.currentState?.pop();
//                               }
//                             })
//                       ]),
//                     Text(Utils().pageToHeader(page),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 14,
//                             color: Theme.of(context).colorScheme.titel1)),
//                     if (page == MenuPageType.reviewCard ||
//                         page == MenuPageType.numerals)
//                       StreamBuilder(
//                           stream: AppRep().onProgressChanged,
//                           builder: (context, snapshot) {
//                             var v = snapshot.data ?? 0.0;
//                             return Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Padding(
//                                     padding: const EdgeInsets.all(10),
//                                     child: SizedBox(
//                                         child: CircularProgressIndicator(
//                                             value: v,
//                                             backgroundColor: Theme.of(context)
//                                                 .colorScheme
//                                                 .page,
//                                             color: Theme.of(context)
//                                                 .colorScheme
//                                                 .titel1))));
//                           })
//                   ])),
//               body: Column(children: [
//                 Expanded(
//                     child: Navigator(
//                         key: context.read<AppModel>().appNavKey,
//                         initialRoute: MainRouteType.main,
//                         observers: [context.read<AppModel>().appNavObserver],
//                         onGenerateRoute: (RouteSettings settings) {
//                           var type = UiHelper().routeNameToType(settings.name);
//                           switch (type) {
//                             //
//                             // cards (default)
//                             case MainRouteType.home:
//                               return PageRouteBuilder(
//                                   transitionDuration: Duration.zero,
//                                   reverseTransitionDuration: Duration.zero,
//                                   settings: RouteSettings(name: type.name),
//                                   transitionsBuilder: (context, animation,
//                                       secondaryAnimation, child) {
//                                     return child;
//                                   },
//                                   pageBuilder: (_, __, ___) => Text('TODO'));
//                           });
//   }
// }
// )