// 亮主题配置
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const bgColor = Color(0xFFF6F8FA);
const buttonColor = Color(0xFFb1e7e1);
const kShrinePink50 = Color(0xFFFEEAE6);
const kShrinePink100 = Color(0xFFFEDBD0);
const kShrinePink300 = Color(0xFFFBB8AC);
const kShrinePink400 = Color(0xFFEAA4A4);

const kShrineBrown900 = Color(0xFF442B2D);

const kShrineErrorRed = Color(0xFFC5032B);

const kShrineSurfaceWhite = Color(0xFFFFFBFA);
const kShrineBackgroundWhite = Colors.white;

final ThemeData kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  return ThemeData(
      fontFamily:
          Platform.isWindows ? "HarmonyOSSans" : null, // "HarmonyOSSans",
      fontFamilyFallback: Platform.isWindows ? ["HarmonyOSSans_SC"] : [],
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromRGBO(227, 179, 166, 1), //kShrinePink400,
        onPrimary: kShrineBrown900,
        secondary: kShrineBrown900,
        onSecondary: kShrineSurfaceWhite,
        tertiary: kShrinePink50,
        onTertiary: kShrineBrown900,
        error: kShrineErrorRed,
        surface: Color.fromRGBO(250, 249, 249, 1),
        onSurface: Colors.grey,
        onError: kShrineSurfaceWhite,
      ),
      dividerTheme: DividerThemeData(
        color: kShrinePink50,
      ),
      dividerColor: kShrinePink50,
      iconTheme: IconThemeData(
        color: kShrineBrown900,
      ),
      textTheme: TextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: kShrinePink50.withValues(
            alpha: 0.2), //Color.fromRGBO(244, 244, 244, 0.1),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        selectionColor: Color(0xFFb1e7e1), // 选中文本的背景颜色
        selectionHandleColor: Color(0xFFb1e7e1), // 光标颜色
        cursorColor: Color(0xFFb1e7e1),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: Color(0xFFb1e7e1),
      ));
}
// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   primarySwatch: Colors.blue,
//   // 可以添加更多主题配置，如文本样式、按钮样式等
//   inputDecorationTheme: InputDecorationTheme(
//     fillColor: Color.fromRGBO(244, 244, 244, 0.1),
//   ),
// );

// // 暗主题配置
// final ThemeData darkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: Color.fromRGBO(11, 18, 17, 1),
//   inputDecorationTheme: InputDecorationTheme(
//     fillColor: Color.fromRGBO(244, 244, 244, 0.1),
//   ),
// );
