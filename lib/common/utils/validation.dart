import 'package:charmev/config/env.dart';
import 'package:validators/validators.dart';

class CEVValidation {
  String? did(String value) {
    String error = Env.invalidProviderDid;
    String pk = value.split(":")[2];
    if (isNull(value.trim())) {
      return error;
    } else if (value.trim().length != 57) {
      return error;
    } else if (pk.trim().length != 48) {
      return error;
    }

    return "";
  }
}

CEVValidation validation = CEVValidation();
