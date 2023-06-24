import 'package:flutter/material.dart';

class IrisPageRoute {
  late final String routeName;
  late Widget view;
  String? routeAddress;
  //bool show404OnInvalidSupPath = false;

  IrisPageRoute();

  IrisPageRoute.by(this.routeName, this.view);
}
