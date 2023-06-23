import 'package:flutter/material.dart';

class WebRoute {
  late String routeName;
  late Widget view;
  String? routeAddress;
  bool show404OnInvalidSupPath = false;

  WebRoute();

  WebRoute.by(this.routeName, this.view);
}
