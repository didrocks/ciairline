import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:logging/logging.dart';

import 'package:route_hierarchical/client.dart';


class RouteHandler {

  final router = new Router();
  static RouteHandler _cache;
  StreamSubscription currentAnim;

  factory RouteHandler() {
    if (_cache == null)
      _cache = new RouteHandler._internal();
    return _cache;
  }

  RouteHandler._internal() {
    router.root
      ..addRoute(name: 'ticketDetail', path: '/tickets/:ticketID', enter: _showOneTicket)
      ..addRoute(name: 'allTickets', path: '/tickets', enter: _showTickets)
      ..addRoute(name: 'building', path: '/building', enter: _showBuilding)
      ..addRoute(name: 'home', path:'/home', defaultRoute: true, enter: _showHome);
    router.listen();
    this.adjustMainHeight();
  }

  _showHome(RouteEvent e) => _changePage('#page-home');
  _showBuilding(RouteEvent e) => _changePage('#page-building');
  _showTickets(RouteEvent e) => _changePage('#page-tickets');

  _showOneTicket(RouteEvent e) {
    // do nothing for now; e.parameters['ticketID']
  }

  void _changePage(String pageSelector) {
    HtmlElement newpage = querySelector(pageSelector);
    var previouspage = querySelector(".page-current");
    if (newpage == previouspage)
      return;

    var outClass = ['page-fade'];
    var inClass = ['page-moveFromRight', 'page-ontop'];
    var transitionClass = [];
    transitionClass.addAll(outClass);
    transitionClass.addAll(inClass);

    if (currentAnim != null) {
      /* reset states for fast clicker */
      currentAnim.cancel();
      for (Element page in querySelector(".content").children)
        page.classes.removeAll(transitionClass);
    }

    newpage.classes.add("page-current");
      newpage.classes.addAll(inClass);
      if (previouspage != null) {
        previouspage.classes.addAll(outClass);
        previouspage.classes.remove("page-current");
      }

      currentAnim = Window.animationEndEvent.forTarget(newpage).listen((_) {
        // we are just interested in the first event (and Future don't enable cancel)
        currentAnim.cancel();
        currentAnim = null;
        for (Element page in querySelector(".content").children)
          page.classes.removeAll(transitionClass);
        adjustMainHeight();
      });
  }

  /* reassign some heights as our objects are absolutely posititioned (this should be removed once we use flexbox) sound*/
  void adjustMainHeight() {
    /* as main only adds absolute positionned elements, adjust its height */
    int containerHeight = document.documentElement.clientHeight - querySelector('header').clientHeight;
    int currentHeight;
    Map<Element, String> elemToAssignHeight = {};

    Element elem = querySelector('.page-current');
    // minimum height is viewport height
    currentHeight = max(containerHeight, elem.clientHeight);
    elemToAssignHeight[elem] = '${currentHeight}px';

    // set height of the current page for main container
    elemToAssignHeight[querySelector('.main')] = '${currentHeight}px';

    // set height now to avoid too many recomputestyle
    elemToAssignHeight.forEach((elem, height) => elem.style.height = height);
  }

}
