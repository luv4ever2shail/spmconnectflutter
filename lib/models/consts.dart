import 'package:flutter/material.dart';

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;

  static TextSelection setCursorAtTheEnd(TextEditingController textController) {
    /// Flutter currently reset the cursor. Always place the cursor at the end.
    TextSelection cursorPos = textController.selection;
    cursorPos = TextSelection.fromPosition(
      TextPosition(offset: textController.text.length),
    );
    textController.selection = cursorPos;

    return cursorPos;
  }
}
