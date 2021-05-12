import 'package:flutter/material.dart';

import '../models.dart';
import 'base.dart';

/// Controls the font family name of the current / selected text.
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class FontFamilyDropdown extends StatefulWidget {
  FontFamilyDropdown({Key? key}) : super(key: key);

  @override
  _FontFamilyDropdownState createState() => _FontFamilyDropdownState();
}

class _FontFamilyDropdownState extends State<FontFamilyDropdown> {
  SafeFont? currentFont;

  void _onFontNameChanged(SafeFont? font) {
    setState(() {
      currentFont = font;
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    api.onFontFamilyChanged = _onFontNameChanged;
    final selectedTextStyle = TextStyle(fontSize: 12);
    return DropdownButton<SafeFont>(
      value: currentFont,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            currentFont = value;
          });
          api.setFont(value);
        }
      },
      selectedItemBuilder: (context) => SafeFont.values
          .map(
            (font) => Center(
              child: Container(
                width: 60,
                child: Text(
                  font.name,
                  style: selectedTextStyle,
                  overflow: TextOverflow.fade,
                  textAlign: TextAlign.right,
                  softWrap: false,
                ),
              ),
            ),
          )
          .toList(),
      items: SafeFont.values
          .map(
            (font) => DropdownMenuItem<SafeFont>(
              child: Text(font.name, style: TextStyle(fontFamily: font.name)),
              value: font,
            ),
          )
          .toList(),
    );
  }
}
