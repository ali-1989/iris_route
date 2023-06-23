import 'dart:html' as html;

import 'package:flutter/foundation.dart';

void changeAddressBar(String url, {dynamic data, bool reload = false}) async {
  //final location = '${html.window.location.protocol}//${html.window.location.host + (html.window.location.pathname?? '')}';
  // html.window.location.href == location
  /// html.window.location.href = location   : this is reload page
  if(!kIsWeb) {
    return;
  }

  data ??= html.window.history.state;

  if(!url.toLowerCase().startsWith(getBaseWebAddress())){
    var base = getBaseWebAddress();

    if(base.endsWith('/')){
      url = '$base$url';
    }
    else {
      url = '$base/$url';
    }
  }

  if(url == getCurrentWebAddress()){
    return;
  }

  await Future.delayed(const Duration(milliseconds: 50));

  print('@@@@@@@@@@ change to $url');
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
  print('@@@@@@@@@@ clear');
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

void backAddressBar() {
  print('@@@@@@@@@@ back');
  html.window.history.back();
}
