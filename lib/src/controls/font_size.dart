import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';

import '../models.dart';
import 'base.dart';

/// Controls the font size of the selected / current text.
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class FontSizeDropdown extends StatefulWidget {
  /// Creates a new font size selector
  const FontSizeDropdown({Key? key}) : super(key: key);

  @override
  _FontSizeDropdownState createState() => _FontSizeDropdownState();
}

class _FontSizeDropdownState extends State<FontSizeDropdown> {
  FontSize currentSize = FontSize.medium;

  void _onFontSizeChanged(FontSize fontSize) {
    setState(() {
      currentSize = fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi
      ..onFontSizeChanged = _onFontSizeChanged;
    const selectedTextStyle = TextStyle(fontSize: 12);
    return PlatformDropdownButton<FontSize>(
      value: currentSize,
      onTap: api.storeSelectionRange,
      onChanged: (value) async {
        await api.restoreSelectionRange();
        if (value != null) {
          setState(() {
            currentSize = value;
          });
          await api.setFontSize(value);
        }
      },
      selectedItemBuilder: (context) => const [
        Center(child: Text('7', style: selectedTextStyle)),
        Center(child: Text('10', style: selectedTextStyle)),
        Center(child: Text('12', style: selectedTextStyle)),
        Center(child: Text('14', style: selectedTextStyle)),
        Center(child: Text('18', style: selectedTextStyle)),
        Center(child: Text('24', style: selectedTextStyle)),
        Center(child: Text('32', style: selectedTextStyle)),
      ],
      items: const [
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
