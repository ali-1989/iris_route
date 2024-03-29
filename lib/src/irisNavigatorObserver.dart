import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_route/src/stackList.dart';

import 'package:iris_route/src/appRouteNoneWeb.dart'
if (dart.library.html) 'package:iris_route/src/appRouteWeb.dart' as web;


typedef OnNotFound = Route? Function(RouteSettings settings);
typedef OnGenerateRoute = Route? Function(RouteSettings settings, Route? route);
typedef EventListener = void Function(Route? route, NavigateState state);
///=============================================================================
enum NavigateState {
  push,
  pop,
  replace,
  remove,
}
///=============================================================================
class IrisNavigatorObserver extends NavigatorObserver  /*NavigatorObserver or RouteObserver*/ {
  static final IrisNavigatorObserver _instance = IrisNavigatorObserver._();
  static final StackList<String> _currentRoutedList = StackList();
  static final List<MapEntry<int, String>> _routeToLabel = [];
  static final List<IrisPageRoute> allAppRoutes = [];
  static final List<EventListener> _eventListener = [];
  static OnGenerateRoute? onGenerateRoute;
  static OnNotFound? notFoundHandler;
  static String homeName = '';

  IrisNavigatorObserver._();

  static IrisNavigatorObserver instance(){
    return _instance;
  }

  static void addEventListener(EventListener listener){
    if(!_eventListener.contains(listener)){
      _eventListener.add(listener);
    }
  }

  static void removeEventListener(EventListener listener){
    _eventListener.remove(listener);
  }

  // MaterialNavigatorKey.currentState    <==>    route.navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    String? name = route.settings.name;

    super.didPush(route, previousRoute);

    /*if(route is! PageRoute){
      return;
    }*/

    if(name == '/') {
      _currentRoutedList.clear();
    }
    else {
      if (homeName.toLowerCase() == name?.toLowerCase()) {
        name = '/';
      }

      if (name == null) {
        name = '/${_generateKey(10)}';
        _routeToLabel.add(MapEntry(route.hashCode, name));
      }

      _currentRoutedList.push(name);
    }

    _changeAddressBarOnWeb();

    for (final lis in _eventListener) {
      try{
        lis.call(route, NavigateState.push);
      }
      catch (e){/**/}
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    _currentRoutedList.pop();
    _changeAddressBarOnWeb();

    for (final lis in _eventListener) {
      try{
        lis.call(route, NavigateState.pop);
      }
      catch (e){/**/}
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);

    String? name = route.settings.name;

    if(name == null){
      for(final kv in _routeToLabel){
        if(kv.key == route.hashCode){
          _currentRoutedList.popUntil(kv.value);
        }
      }
    }
    else {
      _currentRoutedList.popUntil(name);
    }

    _changeAddressBarOnWeb();

    for (final lis in _eventListener) {
      try{
        lis.call(route, NavigateState.remove);
      }
      catch (e){/**/}
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    String? name = newRoute?.settings.name;

    if(homeName.toLowerCase() == name?.toLowerCase()){
      name = '/';
      _currentRoutedList.push(name);
    }
    else {
      if(name == null){
        name = _generateKey(10);
        _routeToLabel.add(MapEntry(newRoute.hashCode, name));
      }

      _currentRoutedList.pop();
      _currentRoutedList.push(name);
    }

    _changeAddressBarOnWeb();

    for (final lis in _eventListener) {
      try{
        lis.call(newRoute, NavigateState.replace);
      }
      catch (e){/**/}
    }
  }

  static Route? onUnknownRoute(RouteSettings settings) {
    return null;
  }

  /// this method will call:
  /// on Web: on first launch, if address bar has extra of base url. [www.domain.com/x]
  /// settings.name == /page1?k1=v1#first
  static Route? generateRoute(RouteSettings settings) {
    final address = web.getCurrentWebAddress();
    final lastPath = getLastPathSegmentWithoutQuery(address);
    Route? result;

    for(final r in allAppRoutes){
      if(r.routeName.toLowerCase() == lastPath.toLowerCase()){
        result = MaterialPageRoute(
            builder: (ctx){
              return r.view;
            },
            settings: settings,
        );
      }
    }

    if(result == null && notFoundHandler != null){
      return notFoundHandler!.call(settings);
    }

    if(onGenerateRoute != null){
      result = onGenerateRoute?.call(settings, result);
    }

    /// if result be null, didPush() will call with '/' address
    return result;
  }

  static bool onPopPage(Route<dynamic> route, result) {
    return route.didPop(result);
  }

  void _changeAddressBarOnWeb() {
    if(!kIsWeb){
      return;
    }

    String url = '';

    for(final sec in _currentRoutedList.toList()){
      if(sec == '/' || sec.toLowerCase() == homeName.toLowerCase()){
        continue;
      }

      url += '$sec/';
    }

    final lastPage = getLastPathSegmentWitQuery(web.getCurrentWebAddress());

    if(!url.endsWith(lastPage) && !url.endsWith('$lastPage/')){
      url += lastPage;
    }
    /*final query = getPathQuery(web.getCurrentWebAddress());

    if(query.isNotEmpty) {
      url += '?$query';
    }*/

    web.changeAddressBar(url);
  }

  /// [reload]: if be false, can not use Back button on browser
  static void setAddressBar(String url, {bool reload = false}){
    if(!kIsWeb){
      return;
    }

    web.changeAddressBar(url, reload: reload);
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
    return _currentRoutedList.top();
  }

  static List<String> currentRoutes(){
    return _currentRoutedList.toList();
  }

  static String getLastPathSegmentWitQuery(String address){
    final split = address.split('/');

    if(split.length > 1){
      return split.last;
    }

    return address;
  }

  static String getLastPathSegmentWithoutQuery(String address){
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

      if(idx > -1){
        return last.substring(0, idx);
      }

      return last;
    }

    return address;
  }

  static String getPathQuery(String address){
    final split = address.split('/');
    var query = address;

    if(split.isNotEmpty){
      query = split.last;
    }

    int idxQuestionMark = query.indexOf('?');
    int idxSharpMark = query.indexOf('#');

    //int idx = MathHelper.minInt(idxQuestionMark, idxSharpMark);
    int idx = idxQuestionMark;

    if(idx < 0){
      idx = idxSharpMark;
    }

    if(idx > -1){
      return query.substring(idx+1);
    }

    return query;
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