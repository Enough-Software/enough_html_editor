import 'package:flutter/material.dart';

import 'editor_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Standard format settings
class FormatSettings {
  final isBold;
  final isItalic;
  final isUnderline;
  final isStrikeThrough;
  FormatSettings(
      this.isBold, this.isItalic, this.isUnderline, this.isStrikeThrough);
}

/// Standard color settings
class ColorSetting {
  final Color? foreground;
  final Color? background;

  ColorSetting(this.foreground, this.background);
}

/// Standard align settings
enum ElementAlign { left, center, right, justify }

/// Abstracts a text selection menu item.
class TextSelectionMenuItem {
  /// The text label of the item
  final String label;

  /// The callback
  final dynamic Function(HtmlEditorApi api) action;

  /// Creates a new selection menu item with the specified [label] and [action].
  TextSelectionMenuItem({required this.label, required this.action});
}

/// Slim HTML Editor with API
class HtmlEditor extends StatefulWidget {
  /// Set the [initialContent] to populate the editor with some existing text
  final String initialContent;

  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  final bool adjustHeight;

  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  final int minHeight;

  /// Define the `onCreated(EditorApi)` callback to get notified when the API is ready.
  final void Function(HtmlEditorApi)? onCreated;

  /// Defines if blockquotes should be split when the user adds a new line - defaults to `true`.
  final bool splitBlockquotes;

  /// Defines if the default text selection menu items `𝗕` (bold), `𝑰` (italic), `U̲` (underlined),`T̶` (strikethrough) should be added - defaults to `true`.
  final bool addDefaultSelectionMenuItems;

  /// List of custom text selection / context menu items.
  final List<TextSelectionMenuItem>? textSelectionMenuItems;

  /// Creates a new HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text
  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  /// Define the [onCreated] `onCreated(EditorApi)` callback to get notified when the API is ready.
  /// Set [splitBlockquotes] to `false` in case block quotes should not be split when the user adds a newline in one - this defaults to `true`.
  /// Set [addDefaultSelectionMenuItems] to `false` when you do not want to have the default text selection items enabled.
  /// You can define your own custom context / text selection menu entries using [textSelectionMenuItems].
  HtmlEditor({
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
  HtmlEditorState createState() => HtmlEditorState();
}

/// You can access the API by accessing the HtmlEditor's state.
/// The editor state can be accessed directly when using a GlobalKey<HtmlEditorState>.
class HtmlEditorState extends State<HtmlEditor> {
  static const String _templateStart = '''
<!DOCTYPE html>
<html>
<head>
<style>==styles==
</style>
<script>
  var isSelectionBold = false;
  var isSelectionItalic = false;
  var isSelectionUnderline = false;
  var isSelectionStrikeThrough = false;
  var selectionTextAlign = undefined;
  var selectionForegroundColor = undefined;
  var selectionBackgroundColor = undefined;
  var isLineBreakInput = false;
  var documentHeight;

  function onSelectionChange() {
    //console.log|("onSelectionChange");
    let {anchorNode, anchorOffset, focusNode, focusOffset} = document.getSelection();
    // traverse all parents to find <b>, <i> or <u> elements:
    var isBold = false;
    var isItalic = false;
    var isUnderline = false;
    var isStrikeThrough = false;
    var node = anchorNode;
    var textAlign = undefined;
    var nestedBlockqotes = 0;
    var rootBlockquote;
    var foregroundColor = undefined;
    var backgroundColor = undefined;
    while (node.parentNode != null && node.id != 'editor') {
      if (node.nodeName == 'B') {
          isBold = true;
      } else if (node.nodeName === 'I') {
          isItalic = true;
      } else if (node.nodeName === 'U') {
          isUnderline = true;
      } else if (node.nodeName === 'STRIKE') {
          isStrikeThrough = true;
      } else if (node.nodeName === 'BLOCKQUOTE') {
          nestedBlockqotes++;
          rootBlockquote = node;
      } else if (node.nodeName === 'SPAN' && node.style != undefined) {
        // check for color, bold, etc in style:
        if (node.style.fontWeight === 'bold') {
          isBold = true;
        }
        if (node.style.fontStyle === 'italic') {
          isItalic = true;
        }
        if (node.style.textDecorationLine === 'underline') {
          isUnderline = true;
        }
        if (node.style.textDecorationLine === 'line-through') {
          isStrikeThrough = true;
        }
        if (foregroundColor == undefined && node.style.color != undefined) {
          foregroundColor = node.style.color;
        }
        if (backgroundColor == undefined && node.style.backgroundColor != undefined) {
          backgroundColor = node.style.backgroundColor;
        }
      }
      if (textAlign == undefined && node.style?.textAlign != undefined && node.style.textAlign != '') {
        textAlign = node.style.textAlign;
      }
      node = node.parentNode;
    }
    if (isBold != isSelectionBold || isItalic != isSelectionItalic || isUnderline != isSelectionUnderline || isStrikeThrough != isSelectionStrikeThrough) {
      isSelectionBold = isBold;
      isSelectionItalic = isItalic;
      isSelectionUnderline = isUnderline;
      isSelectionStrikeThrough = isStrikeThrough;
      var message = 0;
      if (isBold) {
          message += 1;
      }
      if (isItalic) {
          message += 2;
      }
      if (isUnderline) {
          message += 4;
      }
      if (isStrikeThrough) {
        message += 8;
      }
      window.flutter_inappwebview.callHandler('FormatSettings', message);
    }
    if (textAlign != selectionTextAlign) {
      selectionTextAlign = textAlign;
      window.flutter_inappwebview.callHandler('AlignSettings', textAlign);
    }
    if (foregroundColor != selectionForegroundColor || backgroundColor != selectionBackgroundColor) {
      selectionForegroundColor = foregroundColor;
      selectionBackgroundColor = backgroundColor;
      window.flutter_inappwebview.callHandler('ColorSettings', foregroundColor, backgroundColor);
    }
''';
  static const String _templateBlockquote = '''
    if (isLineBreakInput && nestedBlockqotes > 0 && anchorOffset == focusOffset) {
      let rootNode = rootBlockquote.parentNode;
      var cloneNode = null;
      var requiresCloning = false;
      var node = anchorNode;
      while (node != rootBlockquote) {
        let sibling = node.previousSibling;
        if (sibling != null) {
          var parentNode = node.parentNode;
          var currentSibling = sibling;
          while (currentSibling.previousSibling != null) {
            currentSibling = currentSibling.previousSibling;
          }
          var cloneParentNode = document.createElement(parentNode.nodeName);
          do {
            var nextSibling = currentSibling.nextSibling;
            parentNode.removeChild(currentSibling);
            cloneParentNode.appendChild(currentSibling);
            if (currentSibling == sibling) {
                break;
            }
            currentSibling = nextSibling;
          } while (true);
          if (cloneNode != null) {
            cloneParentNode.appendChild(cloneNode);
          }
          requiresCloning = true;
          cloneNode = cloneParentNode;
        } else if (requiresCloning) {
          var cloneParentNode = document.createElement(node.nodeName);
          cloneParentNode.appendChild(cloneNode);
          cloneNode = cloneParentNode;
        }
        node = node.parentNode;
      }
      if (cloneNode != null) {
        rootNode.insertBefore(cloneNode, rootBlockquote);
      }
      let textNode = document.createElement("P");
      let textNodeContent = document.createTextNode('_');
      textNode.appendChild(textNodeContent);
      rootNode.insertBefore(textNode, rootBlockquote);
      let range = new Range();
      range.setStart(textNodeContent, 0);
      range.setEnd(textNodeContent, 1);
      let selection = getSelection();
      selection.removeAllRanges();
      selection.addRange(range);
    } 
''';
  static const String _templateContinuation = '''
    isLineBreakInput = false;
  }

  function onInput(inputEvent) {
    isLineBreakInput = ((inputEvent.inputType == 'insertParagraph') || ((inputEvent.inputType == 'insertText') && (inputEvent.data == null)));
    // if (isLineBreakInput) {
    //   document.execCommand('insertLineBreak');
    //   inputEvent.preventDefault();
    // }
    var height = document.body.scrollHeight;
    if (height != documentHeight) {
      documentHeight = height;
      window.flutter_inappwebview.callHandler('InternalUpdate', 'h' + height);
    }
  }

  function onFocus() {
    window.flutter_inappwebview.callHandler('InternalUpdate', 'onfocus');
  }

  function onKeyDown(event) {
    //console.log('keydown', event.key, event);
    if (event.keyCode === 13 || event.key === 'Enter') {
      document.execCommand('insertLineBreak');
      event.preventDefault();
    }
  }

  function onLoaded() {
    documentHeight = document.body.scrollHeight;
    document.onselectionchange = onSelectionChange;
    var editor = document.getElementById('editor');
    editor.oninput = onInput;
    editor.onkeydown = onKeyDown;
    document.execCommand("styleWithCSS", false, true);
  }
</script>
</head>
<body onload="onLoaded();">
<div id="editor" contenteditable="true" onfocus="onFocus();">
==content==
</div>
</body>
</html>
''';
  late String _initialPageContent;
  late InAppWebViewController _webViewController;
  double? _documentHeight;
  late HtmlEditorApi _api;

  /// Allows to replace the existing styles.
  String styles = '''
blockquote {
  font: normal helvetica, sans-serif;
  margin-top: 10px;
  margin-bottom: 10px;
  margin-left: 20px;
  padding-left: 15px;
  border-left: 3px solid #ccc;
}
#editor {
  min-height: ==minHeight==px;
}
  ''';

  /// Access to the API of the editor.
  ///
  /// Instead of accessing the API via the `HtmlEditorState` you can also directly get in in the `HtmlEditor.onCreated(...)` callback.
  HtmlEditorApi get api => _api;

  @override
  void initState() {
    super.initState();
    _api = HtmlEditorApi(this);
    final stylesWithMinHeight =
        styles.replaceFirst('==minHeight==', '${widget.minHeight}');
    final html =
        _templateStart.replaceFirst('==styles==', stylesWithMinHeight) +
            (widget.splitBlockquotes ? _templateBlockquote : '') +
            _templateContinuation.replaceFirst(
                '==content==', widget.initialContent);
    _initialPageContent = html;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adjustHeight) {
      final size = MediaQuery.of(context).size;
      return SizedBox(
        height: _documentHeight ?? size.height,
        width: size.width,
        child: _buildEditor(),
      );
    } else {
      return _buildEditor();
    }
  }

  Widget _buildEditor() {
    return FocusScope(
      canRequestFocus: true,
      child: _buildWebView(),
    );
  }

  Widget _buildWebView() {
    final theme = Theme.of(context);
    final isDark = (theme.brightness == Brightness.dark);
    final textSelectionMenuItems = widget.textSelectionMenuItems;

    return InAppWebView(
      key: ValueKey(_initialPageContent),
      initialData: InAppWebViewInitialData(data: _initialPageContent),
      onWebViewCreated: _onWebViewCreated,
      onLoadStop: (controller, url) async {
        if (widget.adjustHeight) {
          final scrollHeight = await _webViewController.evaluateJavascript(
              source: 'document.body.scrollHeight') as int?;
          if ((scrollHeight != null) &&
              mounted &&
              (scrollHeight + 20 > widget.minHeight)) {
            setState(() {
              _documentHeight = scrollHeight + 20.0;
            });
          }
        }
        // final scrollWidth = await _webViewController.evaluateJavascript(
        //     source: 'document.body.scrollWidth') as int?;
        // final size = MediaQuery.of(context).size;
        // print(
        //     'scrollWidth=$scrollWidth available=${size.width} adjustHeight=${widget.adjustHeight}');
      },
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          verticalScrollBarEnabled: false,
          transparentBackground: isDark,
        ),
        android: AndroidInAppWebViewOptions(
          useWideViewPort: false,
          loadWithOverviewMode: true,
          useHybridComposition: true,
          forceDark: isDark
              ? AndroidForceDark.FORCE_DARK_ON
              : AndroidForceDark.FORCE_DARK_OFF,
        ),
      ),
      // deny browsing while editing:
      shouldOverrideUrlLoading: (controller, action) =>
          Future.value(NavigationActionPolicy.CANCEL),
      onConsoleMessage: (controller, consoleMessage) {
        print(consoleMessage);
      },
      contextMenu: ContextMenu(
        menuItems: [
          if (widget.addDefaultSelectionMenuItems) ...{
            ContextMenuItem(
              androidId: 1,
              iosId: '1',
              title: '𝗕',
              action: () => _api.formatBold(),
            ),
            ContextMenuItem(
              androidId: 2,
              iosId: '2',
              title: '𝑰',
              action: () => _api.formatItalic(),
            ),
            ContextMenuItem(
              androidId: 3,
              iosId: '3',
              title: 'U̲',
              action: () => _api.formatUnderline(),
            ),
            ContextMenuItem(
              androidId: 4,
              iosId: '4',
              title: '̶T̶',
              action: () => _api.formatStrikeThrough(),
            ),
          },
          if (textSelectionMenuItems != null) ...{
            for (final item in textSelectionMenuItems) ...{
              ContextMenuItem(
                androidId: 100 + textSelectionMenuItems.indexOf(item),
                iosId: item.label,
                title: item.label,
                action: () => item.action(_api),
              ),
            },
          },
        ],
      ),
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) {
    _webViewController = controller;
    _api.webViewController = controller;
    controller.addJavaScriptHandler(
        handlerName: 'FormatSettings', callback: _onFormatSettingsReceived);
    controller.addJavaScriptHandler(
        handlerName: 'AlignSettings', callback: _onAlignSettingsReceived);
    controller.addJavaScriptHandler(
        handlerName: 'ColorSettings', callback: _onColorSettingsReceived);
    controller.addJavaScriptHandler(
        handlerName: 'InternalUpdate', callback: _onInternalUpdateReceived);

    if (widget.onCreated != null) {
      widget.onCreated!(_api);
    }
    if (_api.onReady != null) {
      _api.onReady!();
    }
  }

  void _onFormatSettingsReceived(List<dynamic> parameters) {
    // print('got format $parameters');
    final callback = _api.onFormatSettingsChanged;
    if (callback != null && parameters.isNotEmpty) {
      final numericMessage = parameters.first as int?;
      if (numericMessage != null) {
        final isBold = (numericMessage & 1) == 1;
        final isItalic = (numericMessage & 2) == 2;
        final isUnderline = (numericMessage & 4) == 4;
        final isStrikeThrough = (numericMessage & 8) == 8;
        callback(
            FormatSettings(isBold, isItalic, isUnderline, isStrikeThrough));
      }
    }
  }

  void _onAlignSettingsReceived(List<dynamic> parameters) {
    // print('got align $parameters');
    final callback = _api.onAlignSettingsChanged;
    if (callback != null && parameters.isNotEmpty) {
      ElementAlign align;
      switch (parameters.first) {
        case 'left':
          align = ElementAlign.left;
          break;
        case 'center':
          align = ElementAlign.center;
          break;
        case 'right':
          align = ElementAlign.right;
          break;
        case 'justify':
          align = ElementAlign.justify;
          break;
        default:
          align = ElementAlign.left;
          break;
      }
      callback(align);
    }
  }

  void _onColorSettingsReceived(List<dynamic> parameters) {
    // print('got colors  $parameters');
    final callback = _api.onColorChanged;
    if (callback != null && parameters.length == 2) {
      final foreground = _parseColor(parameters[0]);
      final background = _parseColor(parameters[1]);
      callback(ColorSetting(foreground, background));
    }
  }

  Color? _parseColor(String? colorValue) {
    Color? color;
    if (colorValue != null) {
      final startsWithRgb = colorValue.startsWith('rgb(');
      if ((startsWithRgb || colorValue.startsWith('rgba(')) &&
          colorValue.endsWith(')')) {
        try {
          final values = colorValue
              .substring(startsWithRgb ? 'rgb('.length : 'rgba('.length,
                  colorValue.length - 1)
              .split(',')
              .map((text) => int.parse(text.trim()))
              .toList();
          color = startsWithRgb
              ? Color.fromARGB(0xff, values[0], values[1], values[2])
              : Color.fromARGB(values[3], values[0], values[1], values[2]);
        } catch (e, s) {
          print('Error: unable to parse color value $colorValue: $e $s');
        }
      }
    }
    return color;
  }

  void _onInternalUpdateReceived(List<dynamic> parameters) {
    // print('InternalUpdate got update: $parameters');
    if (parameters.isNotEmpty) {
      final message = parameters.first as String?;
      if (message != null && message.startsWith('h')) {
        if (widget.adjustHeight) {
          final height = double.tryParse(message.substring(1));
          if (height != null) {
            setState(() {
              _documentHeight = height + 5;
            });
          }
        }
      } else if (message == 'onfocus') {
        FocusScope.of(context).unfocus();
      }
    }
  }

  /// Notifies the editor about a change of the document that can influence the height.
  ///
  /// The height will be measured and applied if [HtmlEditor.adjustHeight] is set to true.
  Future<void> onDocumentChanged() async {
    if (widget.adjustHeight) {
      final scrollHeight = await _webViewController.evaluateJavascript(
          source: 'document.body.scrollHeight') as int?;
      if (scrollHeight != null) {
        setState(() {
          _documentHeight = scrollHeight + 5;
        });
      }
    }
  }
}
