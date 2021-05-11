import 'package:flutter/material.dart';

import '../models.dart';
import 'base.dart';

/// Controls the font size of the selected / current text.
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class FontSizeDropdown extends StatefulWidget {
  FontSizeDropdown({Key? key}) : super(key: key);

  @override
  _FontSizeDropdownState createState() => _FontSizeDropdownState();
}

class _FontSizeDropdownState extends State<FontSizeDropdown> {
  var currentSize = FontSize.medium;

  void _onFontSizeChanged(FontSize fontSize) {
    setState(() {
      currentSize = fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    api.onFontSizeChanged = _onFontSizeChanged;
    final selectedTextStyle = TextStyle(fontSize: 12);
    return DropdownButton<FontSize>(
      value: currentSize,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            currentSize = value;
          });
          api.setFontSize(value);
        }
      },
      selectedItemBuilder: (context) => [
        Center(child: Text('7', style: selectedTextStyle)),
        Center(child: Text('10', style: selectedTextStyle)),
        Center(child: Text('12', style: selectedTextStyle)),
        Center(child: Text('14', style: selectedTextStyle)),
        Center(child: Text('18', style: selectedTextStyle)),
        Center(child: Text('24', style: selectedTextStyle)),
        Center(child: Text('32', style: selectedTextStyle)),
      ],
      items: [
        DropdownMenuItem<FontSize>(
          child: Text('7', style: TextStyle(fontSize: 10)),
          value: FontSize.xSmall,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('10', style: TextStyle(fontSize: 12)),
          value: FontSize.small,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('12', style: TextStyle(fontSize: 14)),
          value: FontSize.medium,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('14', style: TextStyle(fontSize: 16)),
          value: FontSize.large,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('18', style: TextStyle(fontSize: 18)),
          value: FontSize.xLarge,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('24', style: TextStyle(fontSize: 20)),
          value: FontSize.xxLarge,
        ),
        DropdownMenuItem<FontSize>(
          child: Text('32', style: TextStyle(fontSize: 24)),
          value: FontSize.xxxLarge,
        ),
      ],
    );
  }
}
