import 'package:flutter/material.dart';
import 'package:charmev/common/widgets/service_container.dart';

/// Contains all app services
/// which can be accessed from anywhere in the app
///
// / The [CEVServiceProvider] can be accessed throughout the app with
/// `CEVServiceProvider.of(context)`, often inside of build methods in widgets.
///
/// Example:
/// ```
/// final serviceProvider = CEVServiceProvider.of(context);
///
/// DBService dbService = serviceProvider.data.dbService;
/// ```
class CEVServiceProvider extends InheritedWidget {
  const CEVServiceProvider({
    required Widget child,
    required this.data,
    Key? key,
  }) : super(child: child, key: key);

  final CEVServiceContainerState data;

  static CEVServiceProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CEVServiceProvider>();
  }

  @override
  bool updateShouldNotify(CEVServiceProvider oldWidget) {
    // service provider shouldn't rebuild
    return false;
  }
}
