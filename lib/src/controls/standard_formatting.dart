import 'package:flutter/material.dart';

import '../editor.dart';
import 'base.dart';

/// Controls the base format settings bold, italic, underlined and strike through
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class BaseFormatButtons extends StatefulWidget {
  BaseFormatButtons({Key? key}) : super(key: key);

  @override
  _BaseFormatButtonsState createState() => _BaseFormatButtonsState();
}

class _BaseFormatButtonsState extends State<BaseFormatButtons> {
  final isSelected = [false, false, false, false];

  void _onFormatSettingsChanged(FormatSettings formatSettings) {
    setState(() {
      isSelected[0] = formatSettings.isBold;
      isSelected[1] = formatSettings.isItalic;
      isSelected[2] = formatSettings.isUnderline;
      isSelected[3] = formatSettings.isStrikeThrough;
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    api.onFormatSettingsChanged = _onFormatSettingsChanged;

    return ToggleButtons(
      children: [
        Icon(Icons.format_bold),
        Icon(Icons.format_italic),
        Icon(Icons.format_underlined),
        Icon(Icons.format_strikethrough),
      ],
      onPressed: (int index) {
        switch (index) {
          case 0:
            api.formatBold();
            break;
          case 1:
            api.formatItalic();
            break;
          case 2:
            api.formatUnderline();
            break;
          case 3:
            api.formatStrikeThrough();
            break;
        }
        setState(() {
          isSelected[index] = !isSelected[index];
        });
      },
      isSelected: isSelected,
    );
  }
}
