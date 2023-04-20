import 'package:flutter/material.dart';
import 'package:iris_route/iris_route.dart';

class IrisRouterDelegate<T> extends RouterDelegate<T> with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /*static IrisRouterDelegate? _instance;

  IrisRouterDelegate._();

  static IrisRouterDelegate<T> instance<T>(){
    _instance ??= IrisRouterDelegate<T>._();

    return _instance! as IrisRouterDelegate<T>;
  }*/

  late final GlobalKey<NavigatorState> _navigatorKey;
  late final Widget _root;

  IrisRouterDelegate(this._navigatorKey, this._root);

  @override
  GlobalKey<NavigatorState>? get navigatorKey => _navigatorKey;

  /*@override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
  }
  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
  }

  Router(
        routerDelegate: AppRouterDelegate.instance(),
        backButtonDispatcher: RootBackButtonDispatcher(),
      )

  */

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      //initialRoute: '/',
      //onUnknownRoute: ,
      onGenerateRoute: IrisNavigatorObserver.onGenerateRoute,
      observers: [IrisNavigatorObserver.instance()],
      onPopPage: IrisNavigatorObserver.onPopPage,
      pages: [
        MaterialPage(child: _root)
      ],
    );
  }

  @override
  Future<bool> popRoute() async {
    print('-------------------------------------------------- p1');
    return false;
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    return;
  }
}