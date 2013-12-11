import 'dart:async';
import 'dart:html';
import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart' show initPolymer;

import "routing.dart" show RouteHandler;

var body = querySelector('body');
StreamSubscription clickOutsideMenuExit;

void main() {
  Logger.root
  ..level = Level.INFO
  ..onRecord.listen((r) =>
      print('${new DateTime.now()} [${r.loggerName}:${r.level}]: ${r.message}'));

  initPolymer().run(() {
    querySelector('.menutrigger').onClick.listen(menutoogle);
    new RouteHandler();
  });
}


void menutoogle(Event e) {
  if (!body.classes.contains('menu-opened')) {
    body..classes.add('menu-opened');
    clickOutsideMenuExit = querySelector('.content').onClick.listen(menutoogle);
  }
  else {
    body..classes.remove('menu-opened');
    clickOutsideMenuExit.cancel();
  }
}

