import 'dart:html' as html;

import 'package:flutter/foundation.dart';

void changeAddressBar(String url, {dynamic data, bool reload = false}) async {
  // final location = '${html.window.location.protocol}//${html.window.location.host + (html.window.location.pathname?? '')}';
  // html.window.location.href <==> location
  /// html.window.location.href = xxx   : this do reload page

  if(!kIsWeb) {
    return;
  }

  data ??= html.window.history.state;
  var base = getBaseWebAddress();

  if(!url.toLowerCase().startsWith(base)){
    if(base.endsWith('/')){
      url = '$base$url';
    }
    else {
      url = '$base/$url';
    }
  }

  print('============= u1:$url');
  url = url.replaceAll('//', '/');
  print('============= u2:$url');
  url = url.replaceFirst('/:', '//:');
  print('============= u3:$url');

  await Future.delayed(const Duration(milliseconds: 50));
  if(url == getCurrentWebAddress()){
    return;
  }

  if(reload) {
    // can press Back button
    html.window.history.pushState(data, '', url);
  }
  else {
    // can not press Back button
    html.window.history.replaceState(data, '', url);
  }
}

void clearAddressBar() {
  if(!kIsWeb) {
    return;
  }

  final location = '${html.window.location.protocol}//${html.window.location.host}/';
  html.window.history.replaceState(html.window.history.state, '', location);
}

String getBaseWebAddress() {
  if(!kIsWeb) {
    return '';
  }

  return html.document.baseUri?? '';
}

String getCurrentWebAddress() {
  if(!kIsWeb) {
    return '';
  }

  return html.window.location.href;
}

void simulateBrowserBack() {
  html.window.history.back();
}
