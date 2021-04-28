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
  final List<Color>? foregroundColors;
  final List<Color>? backgroundColors;

  HtmlEditorControls({
    Key? key,
    this.editorKey,
    this.editorApi,
    this.prefix,
    this.suffix,
    this.foregroundColors,
    this.backgroundColors,
  })  : assert(editorKey != null || editorApi != null),
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
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: 50,
      child: ListView(
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
                  child: Icon(Icons.format_align_left),
                  value: ElementAlign.left),
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
          ColorPicker(
            colors: widget.foregroundColors ??
                [Colors.black, Colors.white, ...Colors.accents],
            mode: ColorPickerMode.foreground,
            editorApi: widget.editorApi,
            editorKey: widget.editorKey,
          ),
          ColorPicker(
            colors: widget.backgroundColors ??
                [Colors.white, Colors.black, ...Colors.accents],
            mode: ColorPickerMode.background,
            editorApi: widget.editorApi,
            editorKey: widget.editorKey,
          ),
          if (suffix != null) ...{
            suffix,
          },
        ],
      ),
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

/// The mode for the ColorPicker widget
enum ColorPickerMode { foreground, background }

/// Simple color picker
class ColorPicker extends StatefulWidget {
  final List<Color> colors;
  final HtmlEditorApi? editorApi;
  final GlobalKey<HtmlEditorState>? editorKey;
  final ColorPickerMode mode;

  ColorPicker(
      {Key? key,
      required this.colors,
      required this.mode,
      this.editorApi,
      this.editorKey})
      : assert(colors.isNotEmpty),
        assert(editorApi != null || editorKey != null),
        super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  OverlayEntry? _overlayEntry;
  late Color currentColor;
  List<Color> lastColors = [];
  late HtmlEditorApi _editorApi;

  @override
  void initState() {
    super.initState();
    currentColor = widget.colors.first;
    lastColors.add(currentColor);
    final key = widget.editorKey;
    final api = widget.editorApi;
    if (key != null) {
      // in init state, the editorKey.currentState is still null,
      // so wait for after the first run
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final stateApi = key.currentState!.api;
        _editorApi = stateApi;
        stateApi.onColorChanged = _onColorChanged;
      });
    } else if (api != null) {
      _editorApi = api;
      api.onColorChanged = _onColorChanged;
    } else {
      throw StateError('no api or live key defined');
    }
  }

  Color? _getColor(ColorSetting colorSetting) {
    return (widget.mode == ColorPickerMode.foreground)
        ? colorSetting.foreground
        : colorSetting.background;
  }

  Widget _buildIndicator() {
    if (widget.mode == ColorPickerMode.foreground) {
      return Text(
        'T',
        style: TextStyle(
            color: currentColor, fontWeight: FontWeight.bold, fontSize: 22),
      );
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(border: Border.all(), color: currentColor),
      );
    }
  }

  void _onColorChanged(ColorSetting colorSetting) {
    final color = _getColor(colorSetting);
    if (color == currentColor ||
        (color == null && currentColor == widget.colors.first)) {
      // ignore
    }
    final col = color ?? widget.colors.first;
    if (!widget.colors.any((existing) => (existing.value == col.value))) {
      widget.colors.add(col);
      lastColors.insert(0, col);
      if (lastColors.length >= 5) {
        lastColors.removeLast();
      }
    }
    setState(() {
      currentColor = col;
    });
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      removeOverlay();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        removeOverlay();
        return Future.value(false);
      },
      child: IconButton(
        icon: _buildIndicator(),
        onPressed: () {
          final entry = _buildThreadsOverlay();
          _overlayEntry = entry;
          final state = Overlay.of(context);
          if (state != null) {
            state.insert(entry);
          }
        },
      ),
    );
  }

  void removeOverlay() {
    final entry = _overlayEntry;
    if (entry != null) {
      entry.remove();
      _overlayEntry = null;
    }
  }

  Widget _buildColorPreview(Color color, {Widget? child}) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(),
      ),
      child: child,
    );
  }

  OverlayEntry _buildThreadsOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final renderSize = renderBox.size;
    final size = MediaQuery.of(context).size;
    final left = 16.0;
    final top = offset.dy + renderSize.height + 5.0;
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance!.window.viewInsets,
        WidgetsBinding.instance!.window.devicePixelRatio);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          removeOverlay();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: left,
              top: top,
              width: size.width - 32,
              bottom: viewInsets.bottom,
              child: SingleChildScrollView(
                child: Material(
                  elevation: 4.0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time),
                          for (final color in lastColors) ...{
                            IconButton(
                              icon: _buildColorPreview(color),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setColor(color),
                            ),
                          },
                        ],
                      ),
                      GridView.count(
                        crossAxisCount: 6,
                        primary: false,
                        shrinkWrap: true,
                        children: [
                          for (final color in widget.colors) ...{
                            ListTile(
                              title: _buildColorPreview(
                                color,
                                child: (color == currentColor)
                                    ? Icon(Icons.check)
                                    : null,
                              ),
                              visualDensity: VisualDensity.compact,
                              onTap: () => setColor(color),
                            ),
                          },
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setColor(Color color) async {
    currentColor = color;
    lastColors.remove(color);
    lastColors.insert(0, color);
    if (lastColors.length >= 5) {
      lastColors.removeLast();
    }
    removeOverlay();
    setState(() {});
    if (widget.mode == ColorPickerMode.foreground) {
      await _editorApi.setForegroundColor(color);
    } else {
      await _editorApi.setBackgroundColor(color);
    }
  }
}

/// A combination of controls and editor for a simpler usage.
///
/// Like for the editor you can either use the `onCreated(EditorApi)` callback or a global key to get access to the state,
/// in this case the [PackagedHtmlEditorState]. With either the state or the [EditorApi] you can access the edited text with
/// ```dart
/// String edited = await editorApi.getText();
/// ```
/// Alternatively call `editorApi.getFullHtml()` to retrieve a full HTML document.
class PackagedHtmlEditor extends StatefulWidget {
  /// The initial input text
  final String initialContent;

  /// Defines if blockquotes should be split when the user adds a new line - defaults to `true`.
  final bool splitBlockquotes;

  /// Defines if the default text selection menu items `𝗕` (bold), `𝑰` (italic), `U̲` (underlined),`T̶` (strikethrough) should be added - defaults to `true`.
  final bool addDefaultSelectionMenuItems;

  /// List of custom text selection / context menu items.
  final List<TextSelectionMenuItem>? textSelectionMenuItems;

  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  final bool adjustHeight;

  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  final int minHeight;

  /// Define the `onCreated(EditorApi)` callback to get notified when the API is ready and to retrieve the end result.
  final void Function(HtmlEditorApi)? onCreated;

  /// Creates a new packaged HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text
  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  /// Define the [onCreated] `onCreated(EditorApi)` callback to get notified when the API is ready.
  /// Set [splitBlockquotes] to `false` in case block quotes should not be split when the user adds a newline in one - this defaults to `true`.
  /// Set [addDefaultSelectionMenuItems] to `false` when you do not want to have the default text selection items enabled.
  /// You can define your own custom context / text selection menu entries using [textSelectionMenuItems].
  PackagedHtmlEditor({
    Key? key,
    this.initialContent = '',
    this.adjustHeight = true,
    this.minHeight = 100,
    this.onCreated,
    this.splitBlockquotes = true,
    this.addDefaultSelectionMenuItems = true,
    this.textSelectionMenuItems,
  }) : super(key: key);

  @override
  PackagedHtmlEditorState createState() => PackagedHtmlEditorState();
}

/// The state for the [PackagedHtmlEditor] widget.
///
/// Only useful in combination with a global key.
class PackagedHtmlEditorState extends State<PackagedHtmlEditor> {
  /// The editor API, can be null until editor is initialized.
  HtmlEditorApi? editorApi;

  /// Retrieves the current text
  Future<String> getText() => editorApi?.getText() ?? Future.value('');

  /// Creates a full document from the text
  Future<String> getFullHtml() => editorApi?.getFullHtml() ?? Future.value('');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (editorApi == null) ...{
          CircularProgressIndicator(),
        } else ...{
          HtmlEditorControls(
            editorApi: editorApi,
          ),
        },
        HtmlEditor(
          initialContent: widget.initialContent,
          minHeight: widget.minHeight,
          addDefaultSelectionMenuItems: widget.addDefaultSelectionMenuItems,
          adjustHeight: widget.adjustHeight,
          splitBlockquotes: widget.splitBlockquotes,
          textSelectionMenuItems: widget.textSelectionMenuItems,
          onCreated: _onCreated,
        ),
      ],
    );
  }

  void _onCreated(HtmlEditorApi api) {
    setState(() {
      editorApi = api;
    });
    final callback = widget.onCreated;
    if (callback != null) {
      callback(api);
    }
  }
}
