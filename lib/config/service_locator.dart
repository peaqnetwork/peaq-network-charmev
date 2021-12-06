import 'package:get_it/get_it.dart';
import 'package:charmev/config/navigator.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => CEVNavigator());
}
