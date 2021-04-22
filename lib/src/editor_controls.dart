import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'editor.dart';
import 'editor_api.dart';

/// An example for editor controls.
///
/// With `enough_html_editor` you can create your very own editor controls.
class HtmlEditorControls extends StatefulWidget {
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;

  HtmlEditorControls(
      {Key? key, this.editorKey, this.editorApi, this.prefix, this.suffix})
      : assert(editorKey != null || editorApi != null),
        super(key: key);

  @override
  _HtmlEditorControlsState createState() => _HtmlEditorControlsState();
}

class _HtmlEditorControlsState extends State<HtmlEditorControls> {
  final isSelected = [false, false, false, false];
  ElementAlign? _currentAlignFormat = ElementAlign.left;
  late HtmlEditorApi _editorApi;

  @override
  void initState() {
    super.initState();
    final key = widget.editorKey;
    final api = widget.editorApi;
    if (key != null) {
      // in init state, the editorKey.currentState is still null,
      // so wait for after the first run
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final stateApi = key.currentState!.api;
        _editorApi = stateApi;
        stateApi.onFormatSettingsChanged = _onFormatSettingsChanged;
        stateApi.onAlignSettingsChanged = _onAlignSettingsChanged;
      });
    } else if (api != null) {
      _editorApi = api;
      api.onFormatSettingsChanged = _onFormatSettingsChanged;
      api.onAlignSettingsChanged = _onAlignSettingsChanged;
    } else {
      throw StateError('no api or live key defined');
    }
  }

  void _onFormatSettingsChanged(FormatSettings formatSettings) {
    setState(() {
      isSelected[0] = formatSettings.isBold;
      isSelected[1] = formatSettings.isItalic;
      isSelected[2] = formatSettings.isUnderline;
      isSelected[3] = formatSettings.isStrikeThrough;
    });
  }

  void _onAlignSettingsChanged(ElementAlign align) {
    setState(() {
      _currentAlignFormat = align;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.prefix;
    final suffix = widget.suffix;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        if (prefix != null) ...{
          prefix,
        },
        ToggleButtons(
          children: [
            Icon(Icons.format_bold),
            Icon(Icons.format_italic),
            Icon(Icons.format_underlined),
            Icon(Icons.format_strikethrough),
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
              case 3:
                _editorApi.formatStrikeThrough();
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
            align ??= ElementAlign.left;
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
        if (suffix != null) ...{
          suffix,
        },
      ],
    );
  }
}

class SliverHeaderHtmlEditorControls extends StatelessWidget {
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;

  SliverHeaderHtmlEditorControls(
      {Key? key, this.editorKey, this.editorApi, this.prefix, this.suffix})
      : assert(editorKey != null || editorApi != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: _SliverHeaderHtmlEditorControlsDelegate(
        editorKey: editorKey,
        editorApi: editorApi,
        prefix: prefix,
        suffix: suffix,
      ),
      pinned: true,
    );
  }
}

class _SliverHeaderHtmlEditorControlsDelegate
    extends SliverPersistentHeaderDelegate {
  final double height;
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;

  _SliverHeaderHtmlEditorControlsDelegate(
      {this.editorKey,
      this.editorApi,
      this.prefix,
      this.suffix,
      this.height = 48});

  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).canvasColor,
      child: HtmlEditorControls(
        editorKey: editorKey,
        editorApi: editorApi,
        prefix: prefix,
        suffix: suffix,
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
