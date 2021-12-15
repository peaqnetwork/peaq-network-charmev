import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

void initLogger({String? prefix}) {
  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((rec) {
    final color = _AnsiColor.fromLogLevel(rec.level);

    final separator = _colored("  ::  ", color);

    final logString =
        "${prefix != null ? '${_colored(prefix, _AnsiColor.cyan)}$separator' : ''}"
        "${_colored(rec.level.name, color)}$separator"
        "${DateFormat("HH:mm:ss").format(rec.time)}$separator"
        "${rec.loggerName}$separator"
        "${_colored(rec.message, color)}";

    print(logString);
  });
}

String _colored(String message, _AnsiColor color) {
  return "$color$message${_AnsiColor.reset}";
}

class _AnsiColor {
  const _AnsiColor._(this.value);

  const _AnsiColor.foreground(int colorCode) : value = "38;5;${colorCode}m";

  // const _AnsiColor.background(int colorCode) : value = "48;5;${colorCode}m";

  factory _AnsiColor.fromLogLevel(Level level) {
    if (level <= Level.FINE) {
      return green;
    } else if (level <= Level.INFO) {
      return blue;
    } else if (level <= Level.WARNING) {
      return yellow;
    } else if (level <= Level.SHOUT) {
      return red;
    } else {
      return reset;
    }
  }

  static const ansiEsc = '\x1B[';

  static const _AnsiColor reset = _AnsiColor._("0m");

  static const _AnsiColor red = _AnsiColor.foreground(31);
  static const _AnsiColor green = _AnsiColor.foreground(32);
  static const _AnsiColor yellow = _AnsiColor.foreground(33);
  static const _AnsiColor blue = _AnsiColor.foreground(34);
  static const _AnsiColor cyan = _AnsiColor.foreground(36);

  final String value;

  @override
  String toString() {
    return "$ansiEsc$value";
  }
}
