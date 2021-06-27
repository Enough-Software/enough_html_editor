import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../editor_api.dart';
import '../models.dart';
import 'base.dart';

/// Combines color pickers for text foreground and text background colors
class ColorControls extends StatelessWidget {
  static final List<Color> _defaultThemeColors = [
    Colors.black,
    Colors.white,
    Colors.grey.shade100,
    Colors.grey.shade200,
    Colors.grey.shade300,
    Colors.grey.shade400,
    Colors.grey.shade500,
    Colors.grey.shade600,
    Colors.grey.shade700,
    Colors.grey.shade800,
    Colors.grey.shade900,
    ...Colors.accents,
  ];
  final List<Color>? themeColors;
  final bool excludeDocumentLevelControls;
  ColorControls({
    Key? key,
    this.themeColors,
    this.excludeDocumentLevelControls = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = themeColors ?? _defaultThemeColors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // text foreground:
        ColorPickerControl(
          color: Colors.black,
          themeColors: colors,
          icon: Icon(Icons.text_format),
          getColor: (ColorSetting setting) => setting.textForeground,
          setColor: (color, api) => api.setColorTextForeground(color),
        ),
        // text background:
        ColorPickerControl(
          color: Colors.white,
          themeColors: colors,
          icon: Icon(Icons.brush),
          getColor: (ColorSetting setting) => setting.textBackground,
          setColor: (color, api) => api.setColorTextBackground(color),
        ),
        if (!excludeDocumentLevelControls) ...{
          // document foreground:
          ColorPickerControl(
            color: Colors.black,
            themeColors: colors,
            icon: Icon(Icons.text_fields),
            setColor: (color, api) => api.setColorDocumentForeground(color),
          ),
          // document background:
          ColorPickerControl(
            color: Colors.white,
            themeColors: colors,
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
        },
      ],
    );
  }
}

/// Simple picker widget for a single color
class ColorPickerControl extends StatefulWidget {
  final Color color;
  final Future Function(Color color, HtmlEditorApi api) setColor;
  final List<Color>? themeColors;
  final Widget Function(BuildContext context, Color selectecColor)? builder;
  final Widget? icon;
  final Color? Function(ColorSetting setting)? getColor;

  ColorPickerControl({
    Key? key,
    required this.color,
    this.themeColors,
    required this.setColor,
    this.getColor,
    this.builder,
    this.icon,
  })  : assert(builder != null || icon != null,
            'Please specify either an builder or an icon'),
        super(key: key);

  @override
  _ColorPickerControlState createState() => _ColorPickerControlState();
}

class _ColorPickerControlState extends State<ColorPickerControl> {
  OverlayEntry? _overlayEntry;
  late Color _currentColor;
  List<Color> _lastColors = [];
  Color? _pickedColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.color;
    _lastColors.add(_currentColor);
  }

  void _onColorChanged(ColorSetting colorSetting) {
    final color = widget.getColor!(colorSetting);
    if (color == _currentColor ||
        (color == null && _currentColor == widget.color)) {
      // ignore
    }
    final col = color ?? widget.color;
    final themeColors = widget.themeColors;
    if (themeColors != null) {
      if (!themeColors.any((existing) => (existing.value == col.value))) {
        themeColors.insert(0, col);
      }
    }
    _lastColors.insert(0, col);
    if (_lastColors.length >= 5) {
      _lastColors.removeLast();
    }
    setState(() {
      _currentColor = col;
    });
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _removeOverlay();
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
        ? builder(context, _currentColor)
        : Column(
            children: [
              widget.icon!,
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  border: Border.all(),
                  color: _currentColor,
                ),
              ),
            ],
          );
    return WillPopScope(
      onWillPop: () {
        if (_overlayEntry == null) {
          return Future.value(true);
        }
        _removeOverlay();
        return Future.value(false);
      },
      child: DensePlatformIconButton(
        icon: iconWidget,
        onPressed: () {
          _showColorSelectionSheet(api);
          // if (_overlayEntry != null) {
          //   _removeOverlay();
          // }
          // final entry = _buildOverlay(api);
          // _overlayEntry = entry;
          // final state = Overlay.of(context);
          // if (state != null && state.mounted) {
          //   print('color: insert overlay');
          //   state.insert(entry);
          // }
        },
      ),
    );
  }

  void _showColorSelectionSheet(HtmlEditorApi api) async {
    final width = MediaQuery.of(context).size.width - 32.0;
    final themeColors = widget.themeColors;
    final color = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Material(
              elevation: 4.0,
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time),
                      for (final color in _lastColors) ...{
                        DensePlatformIconButton(
                          icon: _buildColorPreview(color),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            setState(() {
                              _currentColor = color;
                              _pickedColor = color;
                            });
                          },
                        ),
                      },
                    ],
                  ),
                  if (themeColors != null) ...{
                    SizedBox(
                      width: width,
                      height: 20,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: themeColors
                            .map((c) => InkWell(
                                  child: _buildColorPreview(c),
                                  onTap: () {
                                    setState(() {
                                      _currentColor = c;
                                      _pickedColor = c;
                                    });
                                  },
                                ))
                            .toList(),
                        scrollDirection: Axis.horizontal,
                      ),
                    ),
                  },
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ColorPicker(
                          pickerColor: _currentColor,
                          onColorChanged: (color) => _pickedColor = color,
                          colorPickerWidth: width * 0.6,
                          enableAlpha: false,
                          paletteType: PaletteType.hsv,
                          showLabel: false,
                        ),
                      ),
                      Column(
                        children: [
                          DensePlatformIconButton(
                            icon: Icon(CommonPlatformIcons.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          DensePlatformIconButton(
                            icon: Icon(CommonPlatformIcons.ok),
                            onPressed: () {
                              Navigator.of(context).pop(_pickedColor);
                              // final col = _pickedColor;
                              // if (col != null) {
                              //   _setColor(col, api);
                              // }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (color != null) {
      _setColor(color, api);
    }
  }

  void _removeOverlay() {
    final entry = _overlayEntry;
    if (entry != null) {
      entry.remove();
      _overlayEntry = null;
      print('color: removed overlay');
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

  OverlayEntry _buildOverlay(HtmlEditorApi api) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final renderSize = renderBox.size;
    final size = MediaQuery.of(context).size;
    final left = 16.0;
    var top = offset.dy + renderSize.height + 5.0;
    if (top > 100) {
      top = 100;
    }
    final width = size.width - 32;
    final viewInsets = EdgeInsets.fromWindowPadding(
        WidgetsBinding.instance!.window.viewInsets,
        WidgetsBinding.instance!.window.devicePixelRatio);
    // final height = viewInsets.bottom - top;
    final themeColors = widget.themeColors;
    print(
        'color: buildOverlay at $left, $top, w=$width, bottom=${viewInsets.bottom}');
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {
          _removeOverlay();
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: left,
              top: top,
              width: width,
              bottom: viewInsets.bottom,
              child: SingleChildScrollView(
                child: Material(
                  elevation: 4.0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time),
                          for (final color in _lastColors) ...{
                            DensePlatformIconButton(
                              icon: _buildColorPreview(color),
                              visualDensity: VisualDensity.compact,
                              onPressed: () => _setColor(color, api),
                            ),
                          },
                        ],
                      ),
                      if (themeColors != null) ...{
                        SizedBox(
                          width: width,
                          height: 20,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            children: themeColors
                                .map((c) => InkWell(
                                      child: _buildColorPreview(c),
                                      onTap: () => _setColor(c, api),
                                    ))
                                .toList(),
                            scrollDirection: Axis.horizontal,
                          ),
                        ),
                      },
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ColorPicker(
                              pickerColor: _currentColor,
                              onColorChanged: (color) => _pickedColor = color,
                              colorPickerWidth: width * 0.6,
                              enableAlpha: false,
                              paletteType: PaletteType.hsv,
                              showLabel: false,
                            ),
                          ),
                          Column(
                            children: [
                              DensePlatformIconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  _removeOverlay();
                                },
                              ),
                              DensePlatformIconButton(
                                icon: Icon(Icons.done),
                                onPressed: () {
                                  final col = _pickedColor;
                                  if (col != null) {
                                    _setColor(col, api);
                                  }
                                },
                              ),
                            ],
                          ),
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

  void _setColor(Color color, HtmlEditorApi api) async {
    _currentColor = color;
    _lastColors.remove(color);
    _lastColors.insert(0, color);
    if (_lastColors.length >= 5) {
      _lastColors.removeLast();
    }
    // _removeOverlay();
    setState(() {});
    await widget.setColor(color, api);
    final themeColors = widget.themeColors;
    if (themeColors != null) {
      if (!themeColors.any((existing) => (existing.value == color.value))) {
        themeColors.insert(0, color);
      }
    }
  }
}
