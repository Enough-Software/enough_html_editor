import 'package:flutter/material.dart';

import '../../enough_html_editor.dart';
import '../editor_api.dart';
import 'controls.dart';

/// Use the `HtmlEditorApiWidget` to provide the `HtmlEditorApi` to widgets further down the widget tree.
///
/// Example:
/// ```dart
///  @override
///  Widget build(BuildContext context) {
///     return HtmlEditorApiWidget(
///      editorApi: _editorApi,
///      child: YourCustomWidgetHere(),
///     );
///   }
/// ```
/// Now in any other widgets below you can access the API in this way:
/// ```dart
///  final api = HtmlEditorApiWidget.of(context)!.editorApi;
/// ```
class HtmlEditorApiWidget extends InheritedWidget {
  final HtmlEditorApi editorApi;

  /// Creates a new HtmlEditorApiWidget with the specified [editorApi] and [child]
  HtmlEditorApiWidget(
      {Key? key, required this.editorApi, required Widget child})
      : super(key: key, child: child);

  /// Retrieves the widget instance from the given [context].
  static HtmlEditorApiWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HtmlEditorApiWidget>();
  }

  @override
  bool updateShouldNotify(HtmlEditorApiWidget oldWidget) {
    return true;
  }
}

/// Predefined editor controls.
///
/// With `enough_html_editor` you can create your very own editor controls.
class HtmlEditorControls extends StatefulWidget {
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;
  final List<Color>? textForegroundColors;
  final List<Color>? textBackgroundColors;
  final List<Color>? documentForegroundColors;
  final List<Color>? documentBackgroundColors;
  final bool excludeDocumentLevelControls;

  /// Creates a new `HtmlEditorControls`.
  ///
  /// You have to specify either the [editorApi] or the [editorKey].
  /// Optionally specify your own [prefix] and [suffix] widgets. These widgets can access the `HtmlEditorApi` by calling `HtmlEditorApiWidget.of(context)`, e.g. `final api = HtmlEditorApiWidget.of(context)!.editorApi;`
  /// Optionally specify the [textForegroundColors], [textBackgroundColors], [documentForegroundColors] and [documentBackgroundColors]. By default these are deducted from the material accent colors + black & white.
  /// Set [excludeDocumentLevelControls] to `true` in case controls that affect the whole document like the page background color should be excluded.
  HtmlEditorControls({
    Key? key,
    this.editorApi,
    this.editorKey,
    this.prefix,
    this.suffix,
    this.textForegroundColors,
    this.textBackgroundColors,
    this.documentForegroundColors,
    this.documentBackgroundColors,
    this.excludeDocumentLevelControls = false,
  })  : assert(editorApi != null || editorKey != null,
            'Please define either the editorApi or editorKey pararameter.'),
        super(key: key);

  @override
  _HtmlEditorControlsState createState() => _HtmlEditorControlsState();
}

class _HtmlEditorControlsState extends State<HtmlEditorControls> {
  late HtmlEditorApi _editorApi;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return CircularProgressIndicator();
    }
    final prefix = widget.prefix;
    final suffix = widget.suffix;
    final size = MediaQuery.of(context).size;
    return HtmlEditorApiWidget(
      editorApi: _editorApi,
      child: SizedBox(
        width: size.width,
        height: 50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            if (prefix != null) ...{
              prefix,
            },
            BaseFormatButtons(),
            IconButton(
              icon: Icon(Icons.format_list_bulleted),
              onPressed: () => _editorApi.insertUnorderedList(),
            ),
            IconButton(
              icon: Icon(Icons.format_list_numbered),
              onPressed: () => _editorApi.insertOrderedList(),
            ),
            FontSizeDropdown(),
            AlignDropdown(),
            ColorControls(
              excludeDocumentLevelControls: widget.excludeDocumentLevelControls,
              textForegroundColors: widget.textForegroundColors ??
                  [Colors.black, Colors.white, ...Colors.accents],
              textBackgroundColors: widget.textBackgroundColors ??
                  [Colors.white, Colors.black, ...Colors.accents],
            ),
            LinkButton(),
            if (suffix != null) ...{
              suffix,
            },
          ],
        ),
      ),
    );
  }

  void _initApi() {
    final key = widget.editorKey;
    final api = widget.editorApi;
    if (key != null) {
      // in init state, the editorKey.currentState is still null,
      // so wait for after the first run
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final stateApi = key.currentState!.api;
        _editorApi = stateApi;
        _isInitialized = true;
        setState(() {});
      });
    } else if (api != null) {
      _editorApi = api;
      _isInitialized = true;
    }
  }
}
