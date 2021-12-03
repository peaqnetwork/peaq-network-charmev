import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:charmev/config/route_handlers.dart';

class CEVRoutes {
  static const onboarding = "/on-boarding";

  static void configureRoutes(FluroRouter router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return;
    });

    // Add onboarding route handler
    router.define(onboarding, handler: onboardingHandler);
  }
}
