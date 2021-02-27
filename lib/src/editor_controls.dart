import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'editor.dart';
import 'editor_api.dart';

class HtmlEditorControls extends StatefulWidget {
  final GlobalKey<HtmlEditorState> editorKey;
  final EditorApi editorApi;

  HtmlEditorControls({Key key, this.editorKey, this.editorApi})
      : super(key: key);

  @override
  _HtmlEditorControlsState createState() => _HtmlEditorControlsState();
}

class _HtmlEditorControlsState extends State<HtmlEditorControls> {
  final isSelected = [false, false, false];
  var _currentAlignFormat = ElementAlign.left;
  EditorApi _editorApi;

  @override
  void initState() {
    super.initState();
    if (widget.editorKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _editorApi = widget.editorKey.currentState.api;
        // in init state, the editorKey.currentState is still null,
        // so wait for after the first run
        widget.editorKey.currentState.api.onFormatSettingsChanged =
            _onFormatSettingsChanged;
        widget.editorKey.currentState.api.onAlignSettingsChanged =
            _onAlignSettingsChanged;
      });
    } else if (widget.editorApi != null) {
      _editorApi = widget.editorApi;
      widget.editorApi.onFormatSettingsChanged = _onFormatSettingsChanged;
      widget.editorApi.onAlignSettingsChanged = _onAlignSettingsChanged;
    }
  }

  void _onFormatSettingsChanged(FormatSettings formatSettings) {
    setState(() {
      isSelected[0] = formatSettings.isBold;
      isSelected[1] = formatSettings.isItalic;
      isSelected[2] = formatSettings.isUnderline;
    });
  }

  void _onAlignSettingsChanged(ElementAlign align) {
    setState(() {
      _currentAlignFormat = align ?? ElementAlign.left;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ToggleButtons(
          children: [
            Icon(Icons.format_bold),
            Icon(Icons.format_italic),
            Icon(Icons.format_underlined),
          ],
          onPressed: (int index) {
            switch (index) {
              case 0:
                _editorApi.formatBold();
                break;
              case 1:
                _editorApi.formatItalic();
                break;
              case 2:
                _editorApi.formatUnderline();
                break;
            }
            setState(() {
              isSelected[index] = !isSelected[index];
            });
          },
          isSelected: isSelected,
        ),
        IconButton(
          icon: Icon(Icons.format_list_bulleted),
          onPressed: () => _editorApi.insertUnorderedList(),
        ),
        IconButton(
          icon: Icon(Icons.format_list_numbered),
          onPressed: () => _editorApi.insertOrderedList(),
        ),
        DropdownButton<ElementAlign>(
          items: [
            DropdownMenuItem<ElementAlign>(
                child: Icon(Icons.format_align_left), value: ElementAlign.left),
            DropdownMenuItem<ElementAlign>(
                child: Icon(Icons.format_align_center),
                value: ElementAlign.center),
            DropdownMenuItem<ElementAlign>(
                child: Icon(Icons.format_align_right),
                value: ElementAlign.right),
            DropdownMenuItem<ElementAlign>(
                child: Icon(Icons.format_align_justify),
                value: ElementAlign.justify),
          ],
          onChanged: (align) {
            switch (align) {
              case ElementAlign.left:
                _editorApi.formatAlignLeft();
                break;
              case ElementAlign.center:
                _editorApi.formatAlignCenter();
                break;
              case ElementAlign.right:
                _editorApi.formatAlignRight();
                break;
              case ElementAlign.justify:
                _editorApi.formatAlignJustify();
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
        ),
      ],
    );
  }
}

class SliverHeaderHtmlEditorControls extends StatelessWidget {
  final GlobalKey<HtmlEditorState> editorKey;
  final EditorApi editorApi;

  SliverHeaderHtmlEditorControls({Key key, this.editorKey, this.editorApi})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverHeaderHtmlEditorControlsDelegate(
        editorKey: editorKey,
        editorApi: editorApi,
      ),
      pinned: true,
    );
  }
}

class _SliverHeaderHtmlEditorControlsDelegate
    extends SliverPersistentHeaderDelegate {
  final double height;
  final GlobalKey<HtmlEditorState> editorKey;
  final EditorApi editorApi;

  _SliverHeaderHtmlEditorControlsDelegate(
      {this.editorKey, this.editorApi, this.height = 48});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: HtmlEditorControls(editorKey: editorKey, editorApi: editorApi),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
