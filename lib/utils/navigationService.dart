import 'package:flutter/material.dart';

/// Gives the plugin a way to push the reCaptcha page without a [BuildContext].
///
/// The host app must hand [navigationKey] to its `MaterialApp.navigatorKey`,
/// otherwise reCaptcha challenges cannot be solved and the underlying error is
/// surfaced to the caller instead.
class NavigationService {
  late GlobalKey<NavigatorState> navigationKey;

  static NavigationService instance = NavigationService();

  NavigationService() {
    navigationKey = GlobalKey<NavigatorState>();
  }

  /// Whether the host app wired [navigationKey] into its navigator.
  bool get hasNavigator => navigationKey.currentState != null;

  Future<dynamic> navigateToReplacement(
      String routeName, String argument) async {
    final navigator = navigationKey.currentState;
    if (navigator == null) return null;
    // The argument used to be dropped here, so the target route got null.
    return navigator.pushReplacementNamed(routeName, arguments: argument);
  }

  Future<dynamic> navigateTo(String routeName, String argument) async {
    final navigator = navigationKey.currentState;
    if (navigator == null) return null;

    // Don't stack a second copy of a route that is already on top.
    final context = navigationKey.currentContext;
    if (context != null && ModalRoute.of(context)?.settings.name == routeName) {
      return null;
    }
    return navigator.pushNamed(routeName, arguments: argument);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) async {
    final navigator = navigationKey.currentState;
    if (navigator == null) return null;
    return navigator.push(route);
  }

  void goback() {
    navigationKey.currentState?.pop();
  }
}
