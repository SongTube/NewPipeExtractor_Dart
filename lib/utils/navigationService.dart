import 'package:flutter/material.dart';

class NavigationService {
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  Future<dynamic> navigateToReplacement(String _rn, String argument) async {
    var result = await navigationKey.currentState!.pushReplacementNamed(_rn);
    return result;
  }

  Future<dynamic> navigateTo(String _rn, String argument) async {
    var result;
    String? currentRoute = ModalRoute.of(navigationKey.currentContext!)!.settings.name;
    if (currentRoute != 'reCaptcha') {
      result = await navigationKey.currentState!.pushNamed(_rn, arguments: argument);
    }
    return result;
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute _rn) async {
    var result = await navigationKey.currentState!.push(_rn);
    return result;
  }

  goback() {
    return navigationKey.currentState!.pop();
  }
}
