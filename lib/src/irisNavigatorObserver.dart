import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_route/src/stackList.dart';

import 'package:iris_route/src/appRouteNoneWeb.dart'
if (dart.library.html) 'package:iris_route/src/appRouteWeb.dart' as web;


class IrisNavigatorObserver extends NavigatorObserver  /*NavigatorObserver or RouteObserver*/ {
  static final IrisNavigatorObserver _instance = IrisNavigatorObserver._();
  static final StackList<String> _routeList = StackList();
  static final List<MapEntry<int, String>> _routeToLabel = [];
  static final List<WebRoute> webRoutes = [];
  static String homeName = '';

  IrisNavigatorObserver._();

  static IrisNavigatorObserver instance(){
    return _instance;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    /*if(route is! PageRoute){
      return;
    }*/

    /// AppBroadcast.rootNavigatorKey.currentState    <==>    route.navigator
    String? name = route.settings.name;

    if(name == '/') {
      _routeList.clear();
    }
    else {
      if (homeName.toLowerCase() == name?.toLowerCase()) {
        name = '/';
      }

      if (name == null) {
        name = _generateKey(10);
        _routeToLabel.add(MapEntry(route.hashCode, name));
      }

      _routeList.push(name);
    }

    print('########## push');
    _changeAddressBar();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    _routeList.pop();
    print('########## pop');
    _changeAddressBar();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    String? name = route.settings.name;

    if(name == null){
      for(final kv in _routeToLabel){
        if(kv.key == route.hashCode){
          _routeList.popUntil(kv.value);
        }
      }
    }
    else {
      _routeList.popUntil(name);
    }

    print('########## remove');
    _changeAddressBar();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    String? name = newRoute?.settings.name;

    if(homeName.toLowerCase() == name?.toLowerCase()){
      name = '/';
      _routeList.push(name);
    }
    else {
      if(name == null){
        name = _generateKey(10);
        _routeToLabel.add(MapEntry(newRoute.hashCode, name));
      }

      _routeList.pop();
      _routeList.push(name);
    }

    print('########## replace');
    _changeAddressBar();
  }

  static Route? onUnknownRoute(RouteSettings settings) {
    print('########## onUnknownRoute');
    return null;
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    if(kIsWeb){
      print('########## onGenerateRoute');
      if(_routeList.isEmpty && web.getCurrentWebAddress() != web.getBaseWebAddress()) {
        final address = web.getCurrentWebAddress();
        final lastPath = _getLastPart(address);

        for(final r in webRoutes){
          if(r.routeName.toLowerCase() == lastPath.toLowerCase()){

            return MaterialPageRoute(
                builder: (ctx){
                  return r.view;
                },
                settings: settings);
          }
        }
      }
    }

    return null;
  }

  static bool onPopPage(Route<dynamic> route, result) {
    return route.didPop(result);
  }

  void _changeAddressBar() {
    String url = '';

    for(final sec in _routeList.toList()){
      if(sec == '/' || sec.toLowerCase() == homeName.toLowerCase()){
        continue;
      }

      url += '$sec/';
    }

    web.changeAddressBar(url);
  }

  static String appBaseUrl(){
    return web.getBaseWebAddress();
  }

  static String currentUrl(){
    return web.getCurrentWebAddress();
  }

  static String currentPath(){
    final fullUrl = web.getCurrentWebAddress();
    final baseUrl = web.getBaseWebAddress();

    if(fullUrl.startsWith(baseUrl)){
      return fullUrl.substring(baseUrl.length);
    }

    return fullUrl;
  }

  static List<String> pathSegments(){
    final paths = currentPath();
    return paths.split('/');
  }

  static String lastRoute(){
    return _routeList.top();
  }

  static List<String> currentRoutes(){
    return _routeList.toList();
  }

  static String _getLastPart(String address){
    final split = address.split('/');

    if(split.length > 1){
      final last = split.last;

      int idxQuestionMark = last.indexOf('?');
      int idxSharpMark = last.indexOf('#');

      //int idx = MathHelper.minInt(idxQuestionMark, idxSharpMark);
      int idx = idxQuestionMark;

      if(idx < 0){
        idx = idxSharpMark;
      }

      if(idx > 0){
        return last.substring(0, idx);
      }

      return last;
    }

    return address;
  }

  static String _generateKey(int len){
    const s = 'abcdefghijklmnopqrstwxyz0123456789ABCEFGHIJKLMNOPQRSTUWXYZ';
    var res = '';

    for(var i=0; i<len; i++) {
      final j = Random().nextInt(s.length);
      res += s[j];
    }

    return res;
  }
}