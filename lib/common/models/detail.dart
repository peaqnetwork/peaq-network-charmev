import 'package:flutter/material.dart';
import 'package:charmev/theme.dart';

class Detail {
  Detail(this.id, this.value, {this.color = CEVTheme.greyColor});

  String id;
  String value;
  Color color;
}
