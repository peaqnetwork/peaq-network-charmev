import 'package:charmev/screens/provider_detail.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:charmev/screens/onboarding.dart';
import 'package:charmev/screens/home.dart';

var onboardingHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const OnboardingScreen();
});

var providerDetailHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const ProviderDetailScreen();
});

var homeHandler = Handler(
    handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
  return const HomeScreen();
});
