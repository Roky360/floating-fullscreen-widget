import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static final fontFamily = GoogleFonts.chakraPetch();

  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    useMaterial3: true,

    primaryColor: Colors.teal,

    textTheme: GoogleFonts.chakraPetchTextTheme(),
  );
}
