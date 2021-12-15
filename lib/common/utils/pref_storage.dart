import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:charmev/common/providers/application_provider.dart';
import 'package:logging/logging.dart';

class CEVSharedPref {
  static final Logger _log = Logger("CEVSharedPref");

  SharedPreferences? prefs;
  CEVApplicationProvider? appProvider;

  Future<void> init() async {
    _log.fine("initializing Shared prefs");
    prefs = await SharedPreferences.getInstance();
  }

  // / Gets the int value for the [key] if it exists.
  ///
  // / Limits the value if [minLimit] and [maxLimit] are not `null`.
  int getInt(String key, int defaultValue, [int? minLimit, int? maxLimit]) {
    try {
      final int value = prefs?.getInt(key) ?? defaultValue;

      if (minLimit != null && maxLimit != null) {
        return value.clamp(minLimit, maxLimit);
      }

      return value;
    } catch (e) {
      return defaultValue;
    }
  }
}
