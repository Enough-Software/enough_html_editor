import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'editor.dart';
import 'editor_api.dart';

abstract class _BaseHtmlEditorControls extends StatefulWidget {
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  _BaseHtmlEditorControls({Key? key, this.editorApi, this.editorKey})
      : assert(editorApi != null || editorKey != null,
            'Please define either the editorApi or editorKey pararameter.'),
        super(key: key);

  static void initApi(_BaseHtmlEditorControls widget,
      void Function(HtmlEditorApi api) initWithApi) {
    final key = widget.editorKey;
    final api = widget.editorApi;
    if (key != null) {
      // in init state, the editorKey.currentState is still null,
      // so wait for after the first run
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        final stateApi = key.currentState!.api;
        initWithApi(stateApi);
      });
    } else if (api != null) {
      initWithApi(api);
    }
  }
}

// class HtmlEditorInheritedWidget extends InheritedWidget
class HtmlEditorApiWidget extends InheritedWidget {
  final HtmlEditorApi editorApi;
  HtmlEditorApiWidget(
      {Key? key, required this.editorApi, required Widget child})
      : super(key: key, child: child);

  static HtmlEditorApiWidget? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HtmlEditorApiWidget>();
  }

  @override
  bool updateShouldNotify(HtmlEditorApiWidget oldWidget) {
    return true;
  }
}

/// An example for editor controls.
///
/// With `enough_html_editor` you can create your very own editor controls.
class HtmlEditorControls extends _BaseHtmlEditorControls {
  final Widget? prefix;
  final Widget? suffix;
  final List<Color>? foregroundColors;
  final List<Color>? backgroundColors;

  HtmlEditorControls({
    Key? key,
    GlobalKey<HtmlEditorState>? editorKey,
    HtmlEditorApi? editorApi,
    this.prefix,
    this.suffix,
    this.foregroundColors,
    this.backgroundColors,
  }) : super(key: key, editorApi: editorApi, editorKey: editorKey);

  @override
  _HtmlEditorControlsState createState() => _HtmlEditorControlsState();
}

class _HtmlEditorControlsState extends State<HtmlEditorControls> {
  late HtmlEditorApi _editorApi;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _BaseHtmlEditorControls.initApi(widget, (api) {
      _editorApi = api;
      _isInitialized = true;
      if (widget.editorApi == null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefix = widget.prefix;
    final suffix = widget.suffix;
    final size = MediaQuery.of(context).size;
    if (!_isInitialized) {
      return CircularProgressIndicator();
    }
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
            AlignDropdown(),
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
            LinkButton(),
            if (suffix != null) ...{
              suffix,
            },
          ],
        ),
      ),
    );
  }
}

/// HTML editor controls to be used within a sliver-based view, e.g. a `CustomScrollView`.
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

/// Allows to enter and edit links
///
/// This widget depends on a [HtmlEditorApiWidget] in the widget tree.
class LinkButton extends StatefulWidget {
  LinkButton({Key? key}) : super(key: key);

  @override
  _LinkButtonState createState() => _LinkButtonState();
}

class _LinkButtonState extends State<LinkButton> {
  final _urlController = TextEditingController();
  final _textController = TextEditingController();
  bool _isInLink = false;

  @override
  void dispose() {
    _urlController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    final buttonColor = _isInLink ? Theme.of(context).accentColor : null;
    api.onLinkSettingsChanged = _onLinkSettingsChanged;
    return IconButton(
      icon: Icon(Icons.link),
      onPressed: () => _editLink(api),
      color: buttonColor,
    );
  }

  void _onLinkSettingsChanged(LinkSettings? linkSettings) {
    if (linkSettings != null) {
      _urlController.text = linkSettings.url;
      _textController.text = linkSettings.text;
    }
    setState(() {
      _isInLink = (linkSettings != null);
    });
  }

  Future _editLink(HtmlEditorApi api) async {
    var restoreSelectionRange = false;
    if (!_isInLink) {
      final selectedText = await api.storeSelectionRange() ?? '';
      restoreSelectionRange = selectedText.isNotEmpty;
      _textController.text = selectedText;
      final urlText = selectedText.contains('://') ? selectedText : '';
      _urlController.text = urlText;
    }
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: LinkEditor(
            urlController: _urlController,
            textController: _textController,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
    if (result == true && _urlController.text.trim().isNotEmpty) {
      // check link validity?
      var url = _urlController.text.trim();
      if (!url.contains(':')) {
        url = 'https://' + url;
      }
      var text = _textController.text.trim();
      if (text.isEmpty) {
        text = url;
      }
      if (_isInLink) {
        api.editCurrentLink(url, text);
      } else {
        if (restoreSelectionRange) {
          await api.restoreSelectionRange();
        }
        api.insertLink(url, text: text);
      }
    }
  }
}

class LinkEditor extends StatefulWidget {
  final TextEditingController urlController;
  final TextEditingController textController;
  LinkEditor(
      {Key? key, required this.urlController, required this.textController})
      : super(key: key);

  @override
  _LinkEditorState createState() => _LinkEditorState();
}

class _LinkEditorState extends State<LinkEditor> {
  late String _previewText;

  @override
  void initState() {
    super.initState();
    _previewText = widget.textController.text.isEmpty
        ? widget.urlController.text
        : widget.textController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.urlController,
          decoration: InputDecoration(
            icon: Icon(Icons.link),
            suffix: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => widget.urlController.text = '',
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.url,
          onChanged: (text) => _updatePreview(),
        ),
        TextField(
          controller: widget.textController,
          decoration: InputDecoration(
            icon: Icon(Icons.text_fields),
            suffix: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () => widget.textController.text = '',
            ),
          ),
          autofocus: true,
          keyboardType: TextInputType.text,
          onChanged: (text) => _updatePreview(),
        ),
        Divider(),
        TextButton(
          child: Text(_previewText),
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(url)));
          },
        ),
      ],
    );
  }

  String get url {
    var text = widget.urlController.text;
    if (!text.contains(':')) {
      text = 'https://' + text;
    }
    return text;
  }

  void _updatePreview() {
    setState(() {
      _previewText = widget.textController.text.isNotEmpty
          ? widget.textController.text
          : widget.urlController.text;
    });
  }
}

/// The mode for the ColorPicker widget
enum ColorPickerMode { foreground, background }

/// Simple color picker
class ColorPicker extends _BaseHtmlEditorControls {
  final List<Color> colors;
  final ColorPickerMode mode;

  ColorPicker(
      {Key? key,
      required this.colors,
      required this.mode,
      HtmlEditorApi? editorApi,
      GlobalKey<HtmlEditorState>? editorKey})
      : assert(colors.isNotEmpty),
        super(key: key, editorApi: editorApi, editorKey: editorKey);

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
    _BaseHtmlEditorControls.initApi(widget, (api) {
      _editorApi = api;
      api.onColorChanged = _onColorChanged;
    });
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
