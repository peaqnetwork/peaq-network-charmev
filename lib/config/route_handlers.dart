import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:charmev/screens/onboarding.dart';

var onboardingHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const OnboardingScreen();
});
