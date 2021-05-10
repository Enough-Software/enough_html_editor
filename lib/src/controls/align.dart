import 'package:flutter/material.dart';

import '../editor_api.dart';
import '../models.dart';
import 'base.dart';

/// Controls the align format settings left, right, center and justify
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class AlignDropdown extends StatefulWidget {
  AlignDropdown({Key? key}) : super(key: key);

  @override
  _AlignDropdownState createState() => _AlignDropdownState();
}

class _AlignDropdownState extends State<AlignDropdown> {
  ElementAlign _currentAlignFormat = ElementAlign.left;

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    api.onAlignSettingsChanged = _onAlignSettingsChanged;

    return DropdownButton<ElementAlign>(
      items: [
        DropdownMenuItem<ElementAlign>(
            child: Icon(Icons.format_align_left), value: ElementAlign.left),
        DropdownMenuItem<ElementAlign>(
            child: Icon(Icons.format_align_center), value: ElementAlign.center),
        DropdownMenuItem<ElementAlign>(
            child: Icon(Icons.format_align_right), value: ElementAlign.right),
        DropdownMenuItem<ElementAlign>(
            child: Icon(Icons.format_align_justify),
            value: ElementAlign.justify),
      ],
      onChanged: (value) {
        final align = value ?? ElementAlign.left;
        switch (align) {
          case ElementAlign.left:
            api.formatAlignLeft();
            break;
          case ElementAlign.center:
            api.formatAlignCenter();
            break;
          case ElementAlign.right:
            api.formatAlignRight();
            break;
          case ElementAlign.justify:
            api.formatAlignJustify();
            break;
        }
        setState(() {
          _currentAlignFormat = align;
        });
      },
      selectedItemBuilder: (context) => [
        Icon(Icons.format_align_left),
        Icon(Icons.format_align_center),
        Icon(Icons.format_align_right),
        Icon(Icons.format_align_justify),
      ],
      value: _currentAlignFormat,
    );
  }

  void _onAlignSettingsChanged(ElementAlign align) {
    setState(() {
      _currentAlignFormat = align;
    });
  }
}
