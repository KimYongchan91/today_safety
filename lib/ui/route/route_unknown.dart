import 'package:flutter/material.dart';
import 'package:today_safety/ui/widget/icon_error.dart';

class RouteUnknown extends StatefulWidget {
  const RouteUnknown({Key? key}) : super(key: key);

  @override
  State<RouteUnknown> createState() => _RouteUnknownState();
}

class _RouteUnknownState extends State<RouteUnknown> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: IconError(),
        ),
      ),
    );
  }
}
