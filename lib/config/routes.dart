import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:charmev/config/route_handlers.dart';

class CEVRoutes {
  static const onboarding = "/on-boarding";
  static const providerDetail = "/provider-detail";
  static const chargingSession = "/charging-session";
  static const home = "/home";
  static const account = "/account";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return;
    });

    // Add onboarding screen route handler
    router.define(onboarding, handler: onboardingHandler);
    // Add provider detail screen route handler
    router.define(providerDetail, handler: providerDetailHandler);
    // Add home screen route handler
    router.define(home, handler: homeHandler);
    // Add charging session screen route handler
    router.define(chargingSession, handler: chargingSessionHandler);
    // Add account screen route handler
    router.define(account, handler: accountHandler);
  }
}
