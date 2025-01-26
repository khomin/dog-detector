import 'package:flutter/material.dart';
import 'package:flutter_demo/resource/constants.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => SplashState();
}

class SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.colorBar,
        body: Center(
            child: Row(children: [
          const Spacer(),
          Image.asset(
            'assets/logo.png',
            cacheWidth: 200,
          ),
          const Spacer()
        ])));
  }
}
