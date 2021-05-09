import 'package:flutter/material.dart';

import '../editor.dart';
import '../editor_api.dart';
import 'base.dart';

/// Combines color pickers for text foreground and text background colors
class ColorControls extends StatelessWidget {
  static final List<Color> _grayscales = [
    Colors.grey.shade100,
    Colors.grey.shade200,
    Colors.grey.shade300,
    Colors.grey.shade400,
    Colors.grey.shade500,
    Colors.grey.shade600,
    Colors.grey.shade700,
    Colors.grey.shade800,
    Colors.grey.shade900
  ];
  final List<Color>? textForegroundColors;
  final List<Color>? textBackgroundColors;
  final List<Color>? documentForegroundColors;
  final List<Color>? documentBackgroundColors;
  ColorControls({
    Key? key,
    this.textForegroundColors,
    this.textBackgroundColors,
    this.documentForegroundColors,
    this.documentBackgroundColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // text foreground:
        ColorPicker(
          colors: textForegroundColors ??
              [Colors.black, Colors.white, ..._grayscales, ...Colors.accents],
          icon: Icon(Icons.text_format),
          getColor: (ColorSetting setting) => setting.textForeground,
          setColor: (color, api) => api.setColorTextForeground(color),
        ),
        // text background:
        ColorPicker(
          colors: textBackgroundColors ??
              [Colors.white, Colors.black, ..._grayscales, ...Colors.accents],
          icon: Icon(Icons.brush),
          getColor: (ColorSetting setting) => setting.textBackground,
          setColor: (color, api) => api.setColorTextBackground(color),
        ),
        // document foreground:
        ColorPicker(
          colors: documentForegroundColors ??
              [Colors.black, Colors.white, ..._grayscales, ...Colors.accents],
          icon: Icon(Icons.text_fields),
          setColor: (color, api) => api.setColorDocumentForeground(color),
        ),
        // document background:
        ColorPicker(
          colors: documentBackgroundColors ??
              [Colors.white, Colors.black, ..._grayscales, ...Colors.accents],
          builder: (context, color) => Container(
            width: 20,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(),
              color: color,
            ),
          ),
          setColor: (color, api) => api.setColorDocumentBackground(color),
        ),
      ],
    );
  }
}

/// Simple picker widget for a single color
class ColorPicker extends StatefulWidget {
  final List<Color> colors;
  final Widget Function(BuildContext context, Color selectecColor)? builder;
  final Widget? icon;
  final Color? Function(ColorSetting setting)? getColor;
  final Future Function(Color color, HtmlEditorApi api) setColor;

  ColorPicker({
    Key? key,
    required this.colors,
    required this.setColor,
    this.getColor,
    this.builder,
    this.icon,
  })  : assert(colors.isNotEmpty),
        assert(builder != null || icon != null,
            'Please specify either an builder or an icon'),
        super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  OverlayEntry? _overlayEntry;
  late Color currentColor;
  List<Color> lastColors = [];

  @override
  void initState() {
    super.initState();
    currentColor = widget.colors.first;
    lastColors.add(currentColor);
  }

  void _onColorChanged(ColorSetting colorSetting) {
    final color = widget.getColor!(colorSetting);
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
    final api = HtmlEditorApiWidget.of(context)!.editorApi;
    if (widget.getColor != null) {
      api.onColorChanged = _onColorChanged;
    }
    final builder = widget.builder;
    final iconWidget = builder != null
        ? builder(context, currentColor)
        : Column(
            children: [
              widget.icon!,
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: currentColor,
                ),
              ),
            ],
          );
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        removeOverlay();
        return Future.value(false);
      },
      child: IconButton(
        icon: iconWidget,
        onPressed: () {
          final entry = _buildThreadsOverlay(api);
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

  OverlayEntry _buildThreadsOverlay(HtmlEditorApi api) {
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
                              onPressed: () => setColor(color, api),
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
                              onTap: () => setColor(color, api),
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

  void setColor(Color color, HtmlEditorApi api) async {
    currentColor = color;
    lastColors.remove(color);
    lastColors.insert(0, color);
    if (lastColors.length >= 5) {
      lastColors.removeLast();
    }
    removeOverlay();
    setState(() {});
    await widget.setColor(color, api);
  }
}
