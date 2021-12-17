import 'package:charmev/common/providers/application_provider.dart';
import 'package:charmev/theme.dart';
import 'package:flutter/material.dart';

/// Screen displayed while [CEVApplicationProvider] is initializing.
class CEVEntryScreen extends StatelessWidget {
  const CEVEntryScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      color: CEVTheme.bgColor,
    );
  }
}
