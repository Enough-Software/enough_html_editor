import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import 'base.dart';

/// Controls the font family name of the current / selected text.
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class FontFamilyDropdown extends StatefulWidget {
  /// Creates a new font family selector
  const FontFamilyDropdown({Key? key}) : super(key: key);

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
    final api = HtmlEditorApiWidget.of(context)!.editorApi
      ..onFontFamilyChanged = _onFontNameChanged;
    const selectedTextStyle = TextStyle(fontSize: 12);
    return PlatformDropdownButton<SafeFont>(
      value: currentFont,
      onTap: api.storeSelectionRange,
      onChanged: (value) async {
        await api.restoreSelectionRange();
        if (value != null) {
          setState(() {
            currentFont = value;
          });
          await api.setFont(value);
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
