import 'package:flutter/material.dart';

import '../editor.dart';
import '../editor_api.dart';
import 'base.dart';

/// Combines color pickers for text foreground and text background colors
class ColorControls extends StatelessWidget {
  final List<Color> textForegroundColors;
  final List<Color> textBackgroundColors;
  ColorControls({
    Key? key,
    required this.textForegroundColors,
    required this.textBackgroundColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ColorPicker(
          colors: textForegroundColors,
          builder: (context, color) => Column(
            children: [
              Icon(Icons.text_format),
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: color,
                ),
              ),
            ],
          ),
          getColor: (ColorSetting setting) => setting.textForeground,
          setColor: (color, api) => api.setColorTextForeground(color),
        ),
        ColorPicker(
          colors: textBackgroundColors,
          builder: (context, color) => Column(
            children: [
              Icon(Icons.brush),
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: color,
                ),
              ),
            ],
          ),
          getColor: (ColorSetting setting) => setting.textBackground,
          setColor: (color, api) => api.setColorTextBackground(color),
        ),
      ],
    );
  }
}

/// Simple picker widget for a single color
class ColorPicker extends StatefulWidget {
  final List<Color> colors;
  final Widget Function(BuildContext context, Color selectecColor) builder;
  final Color? Function(ColorSetting setting) getColor;
  final Future Function(Color color, HtmlEditorApi api) setColor;

  ColorPicker({
    Key? key,
    required this.colors,
    required this.builder,
    required this.getColor,
    required this.setColor,
  })   : assert(colors.isNotEmpty),
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

  // Widget _buildIndicator() {
  //   final builder = widget.builder;
  //   if (builder != null) {
  //     return builder(context, currentColor);
  //   }
  //   if (widget.mode == ColorPickerMode.textForeground) {
  //     return Text(
  //       'T',
  //       style: TextStyle(
  //           color: currentColor, fontWeight: FontWeight.bold, fontSize: 22),
  //     );
  //   } else {
  //     return Container(
  //       width: 16,
  //       height: 16,
  //       decoration: BoxDecoration(border: Border.all(), color: currentColor),
  //     );
  //   }
  // }

  void _onColorChanged(ColorSetting colorSetting) {
    final color = widget.getColor(colorSetting);
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
    api.onColorChanged = _onColorChanged;
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        removeOverlay();
        return Future.value(false);
      },
      child: IconButton(
        icon: widget.builder(context, currentColor),
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
