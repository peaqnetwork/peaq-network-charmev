import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CEVTheme {
  //Colors for theme
  static const Color primaryColor = Color(0xff706CFF);
  static const Color accentColor = Color(0xffA6A3FF);
  static const Color textColor = Colors.white;
  static const Color textFadeColor = Colors.grey;
  static const Color greyColor = Colors.grey;
  static const Color dialogBgColor = Color(0xff3A3F42);
  static const Color bgColor = Color(0xff131416);
  static const Color appBarBgColor = Color(0xff212427);

  static String customFont = "SourceSanPro";

  static TextStyle get formFieldTextStyle {
    return TextStyle(
        fontFamily: customFont,
        color: textColor,
        letterSpacing: 1,
        height: 1.5,
        fontWeight: FontWeight.w400,
        fontSize: 18.0);
  }

  static TextStyle get formFieldLabelStyle {
    return const TextStyle(
        color: greyColor, fontSize: 18, fontWeight: FontWeight.normal);
  }

  static TextTheme get _textTheme {
    final complimentaryColor = textColor;

    return Typography.englishLike2018.apply(fontFamily: customFont).copyWith(
          // display
          headline1: TextStyle(
            fontSize: 64,
            letterSpacing: 6,
            fontFamily: customFont,
            fontWeight: FontWeight.w300,
            color: complimentaryColor,
          ),
          headline2: TextStyle(
            fontSize: 48,
            letterSpacing: 2,
            fontFamily: customFont,
            fontWeight: FontWeight.bold,
            color: complimentaryColor,
          ),
          headline3: TextStyle(
            fontSize: 25,
            letterSpacing: 2,
            fontFamily: customFont,
            color: complimentaryColor,
          ),
          headline4: TextStyle(
            fontSize: 18,
            letterSpacing: 2,
            fontFamily: customFont,
            fontWeight: FontWeight.w300,
            color: complimentaryColor,
          ),

          // headline6
          headline6: TextStyle(
            fontFamily: customFont,
            letterSpacing: 2,
            fontWeight: FontWeight.w300,
            color: complimentaryColor,
          ),

          subtitle1: TextStyle(
            letterSpacing: 1,
            fontFamily: customFont,
            fontWeight: FontWeight.w300,
            color: complimentaryColor.withOpacity(0.9),
          ),

          subtitle2: TextStyle(
            height: 0.9,
            letterSpacing: 1,
            fontFamily: customFont,
            fontWeight: FontWeight.w300,
            color: complimentaryColor,
          ),

          // body
          bodyText2: TextStyle(
            fontSize: 12,
            fontFamily: customFont,
          ),

          bodyText1: TextStyle(
            fontSize: 14,
            fontFamily: customFont,
            color: complimentaryColor.withOpacity(0.7),
          ),

          button: TextStyle(
            fontSize: 16,
            letterSpacing: 1.2,
            fontFamily: customFont,
            color: textColor,
          ),
        );
  }

  static ThemeData theme = ThemeData(
    primaryColor: primaryColor,
    colorScheme: const ColorScheme(
        primary: accentColor,
        primaryVariant: primaryColor,
        secondary: accentColor,
        secondaryVariant: accentColor,
        surface: Colors.white,
        background: Colors.transparent,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.redAccent,
        brightness: Brightness.dark),
    textTheme: _textTheme,
    dividerColor: accentColor,
    textSelectionTheme: TextSelectionThemeData(cursorColor: accentColor),
    appBarTheme: const AppBarTheme(
      elevation: 0,
    ),
    buttonTheme: const ButtonThemeData(
      minWidth: 10,
    ),
  );
}
