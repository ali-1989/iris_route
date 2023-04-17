[//]: # ([![Dart CI]&#40;https://github.com/dart-lang/args/actions/workflows/test-package.yml/badge.svg&#41;]&#40;https://github.com/dart-lang/args/actions/workflows/test-package.yml&#41;)

## Iris
# 
This library is a flutter routing and navigation tools.



### navigatorObservers

In first step set [onGenerateRoute] and [navigatorObservers] for App:

```dart
MaterialApp(
  navigatorKey: ...,
  onGenerateRoute: IrisNavigatorObserver.onGenerateRoute,
  navigatorObservers: [IrisNavigatorObserver.instance()],
)
```

Then :

Get all routes:
```dart
IrisNavigatorObserver.routes(); 
```

Get current route:
```dart
IrisNavigatorObserver.lastRoute(); 
```


# 
# 
### Web Route

for web, must define a `WebRoute` for any route(page).


```dart
static prepareWebRoute(){
  final aboutPage = WebRoute.by((AboutPage).toString(), AboutPage());
  final homePage = WebRoute.by((HomePage).toString(), HomePage());
  final supportPage = WebRoute.by((SupportPage).toString(), SupportPage());
  
  IrisNavigatorObserver.webRoutes.add(aboutPage);
  IrisNavigatorObserver.webRoutes.add(homePage);
  IrisNavigatorObserver.webRoutes.add(walletPage);
  
  IrisNavigatorObserver.homeName = homePage.routeName;
}
```
