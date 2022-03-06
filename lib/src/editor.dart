import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'editor_api.dart';
import 'models.dart';

/// Slim HTML Editor with API
class HtmlEditor extends StatefulWidget {
  /// Creates a new HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text.
  ///
  /// Set [adjustHeight] to let the editor set its height automatically -
  /// by default this is `true`.
  ///
  /// Specify the [minHeight] to set a different height than the
  /// default `100` pixel.
  ///
  /// Define the [onCreated] `onCreated(EditorApi)` callback to get notified
  /// when the API is ready.
  const HtmlEditor({
    Key? key,
    this.initialContent = '',
    this.adjustHeight = true,
    this.minHeight = 100,
    this.onCreated,
    this.splitBlockquotes = true,
    // this.addDefaultSelectionMenuItems = true,
    // this.textSelectionMenuItems,
  }) : super(key: key);

  /// Set the [initialContent] to populate the editor with some existing text
  final String initialContent;

  /// Set [adjustHeight] to let the editor set its height automatically
  ///  - by default this is `true`.
  final bool adjustHeight;

  /// Specify the [minHeight] to set a different height
  /// than the default `100` pixel.
  final int minHeight;

  /// Define the `onCreated(HtmlEditorApi)` callback to get notified
  /// when the API is ready.
  final void Function(HtmlEditorApi)? onCreated;

  /// Defines if blockquotes should be split when the user adds a new line
  /// - defaults to `true`.
  final bool splitBlockquotes;

  // /// Defines if the default text selection menu items `𝗕` (bold), `𝑰` (italic), `U̲` (underlined),`T̶` (strikethrough) should be added - defaults to `true`.
  // final bool addDefaultSelectionMenuItems;

  // /// List of custom text selection / context menu items.
  // final List<TextSelectionMenuItem>? textSelectionMenuItems;

  @override
  HtmlEditorState createState() => HtmlEditorState();
}

/// You can access the API by accessing the HtmlEditor's state.
///
/// The editor state can be accessed directly when using a
/// [GlobalKey]<[HtmlEditorState]>.
class HtmlEditorState extends State<HtmlEditor> {
  static const String _templateStart = '''
<!DOCTYPE html>
<html>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1">
<head>
<style>
  #editor {
      outline: 0px solid transparent;
  }
==styles==
</style>
<script>
  var isSelectionBold = false;
  var isSelectionItalic = false;
  var isSelectionUnderline = false;
  var isSelectionStrikeThrough = false;
  var selectionTextAlign = undefined;
  var selectionForegroundColor = undefined;
  var selectionBackgroundColor = undefined;
  var selectionFontSize = undefined;
  var selectionFontFamily = undefined;
  var isSelectionInLink = false;
  var isLineBreakInput = false;
  var documentHeight;
  var selectionRange = undefined;
  var isInList = false;

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
    var linkUrl = undefined;
    var linkText = undefined;
    var fontSize = undefined;
    var fontFamily = undefined;
    var isChildOfList = false;
    // var boundingRectFound = false;

    while (node.parentNode != null && node.id != 'editor') {
      // if (!boundingRectFound && node.getBoundingClientRect) {
      //   var boundingRect = node.getBoundingClientRect();
      //   if (boundingRect) {
      //     console.log('bounding rect found for', node, boundingRect);
      //     boundingRectFound = true;
      //     window.OffsetTracker.postMessage(JSON.stringify(boundingRect));
      //   }
      // }
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
      } else if (node.nodeName === 'UL' || node.nodeName === 'OL') {
        isChildOfList = true;
      } else if (node.nodeName === 'SPAN' && node.style != undefined) {
        // check for color, bold, etc in style:
        if (node.style.fontWeight === 'bold') {
          isBold = true;
        }
        if (node.style.fontStyle === 'italic') {
          isItalic = true;
        }
        if (fontSize == undefined && node.style.fontSize != undefined) {
          fontSize = node.style.fontSize;
        }
        if (fontFamily == undefined && node.style.fontFamily != undefined) {
          fontFamily = node.style.fontFamily;
        }
        var textDecorationLine = node.style.textDecorationLine;
        if (textDecorationLine === '') {
          textDecorationLine = node.style.textDecoration;
        }
        if (textDecorationLine != undefined) {
          if (textDecorationLine === 'underline') {
            isUnderline = true;
          } else if (textDecorationLine === 'line-through') {
            isStrikeThrough = true;
          } else {
            if (!isUnderline) {
              isUnderline = textDecorationLine.includes('underline');
            }
            if (!isStrikeThrough) {
              isStrikeThrough = textDecorationLine.includes('line-through');
            }
          }
        }
        if (foregroundColor == undefined && node.style.color != undefined) {
          foregroundColor = node.style.color;
        }
        if (backgroundColor == undefined && node.style.backgroundColor != undefined) {
          backgroundColor = node.style.backgroundColor;
        }
      } else if (node.nodeName === 'A' && linkUrl == undefined) {
        linkUrl = node.href;
        linkText = node.textContent;
      }
      if (textAlign == undefined && node.style != undefined && node.style.textAlign != undefined && node.style.textAlign != '') {
        textAlign = node.style.textAlign;
      }
      node = node.parentNode;
    }
    isInList = isChildOfList;
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
      window.FormatSettings.postMessage(message);
    }
    if (textAlign != selectionTextAlign) {
      selectionTextAlign = textAlign;
      window.AlignSettings.postMessage(textAlign);
    }
    if (foregroundColor != selectionForegroundColor || backgroundColor != selectionBackgroundColor) {
      selectionForegroundColor = foregroundColor;
      selectionBackgroundColor = backgroundColor;
      window.ColorSettings.postMessage(foregroundColor + 'x' + backgroundColor);
    }
    if (linkUrl != undefined || isSelectionInLink === true) {
        if (linkUrl != undefined) {
          isSelectionInLink = true;
          window.LinkSettings.postMessage(linkUrl + '<_>' + linkText);
        } else {
          isSelectionInLink = false;
          window.LinkSettings.postMessage('');
        }
    }
    if (fontSize != selectionFontSize) {
      selectionFontSize = fontSize;
      window.FontSizeSettings.postMessage(fontSize);
    }
    if (fontFamily != selectionFontFamily) {
      selectionFontFamily = fontFamily;
      window.FontFamilySettings.postMessage(fontFamily);
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
    var height = document.body.scrollHeight;
    if (height != documentHeight) {
      documentHeight = height;
      window.InternalUpdate.postMessage('h' + height);
    }
  }

  function onFocus() {
    window.InternalUpdate.postMessage('onfocus');
  }

  function onKeyDown(event) {
    //console.log('keydown', event.key, event);
    if (!isInList && (event.keyCode === 13 || event.key === 'Enter')) {
      document.execCommand('insertLineBreak');
      event.preventDefault();
    }
  }

  function editLink(href, text) {
    let selection = document.getSelection();
    var node = selection.anchorNode;
    while (node != undefined && node.nodeName != 'A') {
      node = node.parentNode;
    }
    if (node != undefined && node.nodeName === 'A') {
      node.href = href;
      node.textContent = text;
    }
  }

  function selectNode() {
    let selection = document.getSelection();
    let range = new Range();
    range.setStartBefore(selection.anchorNode);
    range.setEndAfter(selection.anchorNode);
    selection.removeAllRanges();
    selection.addRange(range);
  }

  function storeSelectionRange() {
    selectionRange = document.getSelection().getRangeAt(0);
    return selectionRange.toString();
  }

  function restoreSelectionRange() {
    if (selectionRange != undefined) {
      let selection = document.getSelection();
      selection.removeAllRanges();
      selection.addRange(selectionRange);
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
  late WebViewController _webViewController;
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
  /// Instead of accessing the API via the [HtmlEditorState]
  /// you can also directly get in in the [HtmlEditor.onCreated] callback.
  HtmlEditorApi get api => _api;

  @override
  void initState() {
    super.initState();
    _api = HtmlEditorApi(this);
    _initialPageContent = generateHtmlDocument(widget.initialContent);
  }

  /// Generates the editor document html from the specified [content].
  String generateHtmlDocument(String content) {
    final buffer = StringBuffer();
    final stylesWithMinHeight =
        styles.replaceFirst('==minHeight==', '${widget.minHeight}');
    buffer
        .write(_templateStart.replaceFirst('==styles==', stylesWithMinHeight));
    if (widget.splitBlockquotes) {
      buffer.write(_templateBlockquote);
    }
    buffer.write(_templateContinuation.replaceFirst('==content==', content));
    final html = buffer.toString();

    return html;
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

  Widget _buildEditor() => WebView(
        key: ValueKey(_initialPageContent),
        onWebViewCreated: _onWebViewCreated,
        onPageFinished: (url) async {
          if (widget.adjustHeight) {
            final scrollHeightText = await _webViewController
                .runJavascriptReturningResult('document.body.scrollHeight');
            final scrollHeight = double.tryParse(scrollHeightText);
            if (scrollHeight != null &&
                mounted &&
                (scrollHeight + 15.0 > widget.minHeight)) {
              setState(() {
                _documentHeight = scrollHeight + 15.0;
              });
            }
          }
        },
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels: {
          JavascriptChannel(
            name: 'FormatSettings',
            onMessageReceived: _onFormatSettingsReceived,
          ),
          JavascriptChannel(
            name: 'FontSizeSettings',
            onMessageReceived: _onFontSizeSettingsReceived,
          ),
          JavascriptChannel(
            name: 'FontFamilySettings',
            onMessageReceived: _onFontFamilySettingsReceived,
          ),
          JavascriptChannel(
            name: 'AlignSettings',
            onMessageReceived: _onAlignSettingsReceived,
          ),
          JavascriptChannel(
            name: 'ColorSettings',
            onMessageReceived: _onColorSettingsReceived,
          ),
          JavascriptChannel(
            name: 'LinkSettings',
            onMessageReceived: _onLinkSettingsReceived,
          ),
          JavascriptChannel(
            name: 'InternalUpdate',
            onMessageReceived: _onInternalUpdateReceived,
          ),
          // JavascriptChannel(
          //   name: 'OffsetTracker',
          //   onMessageReceived: (msg) {
          //     print('OffsetTracker: [${msg.message}]');
          //   },
          // ),
        },

        // deny browsing while editing:
        navigationDelegate: (navigation) =>
            // this is required for iOS / WKWebKit:
            navigation.isForMainFrame && navigation.url == 'about:blank'
                ? NavigationDecision.navigate
                // for all other requests: block
                : NavigationDecision.prevent,
        zoomEnabled: false,

        // contextMenu: ContextMenu(
        //   menuItems: [
        //     if (widget.addDefaultSelectionMenuItems) ...{
        //       ContextMenuItem(
        //         androidId: 1,
        //         iosId: '1',
        //         title: '𝗕',
        //         action: () => _api.formatBold(),
        //       ),
        //       ContextMenuItem(
        //         androidId: 2,
        //         iosId: '2',
        //         title: '𝑰',
        //         action: () => _api.formatItalic(),
        //       ),
        //       ContextMenuItem(
        //         androidId: 3,
        //         iosId: '3',
        //         title: 'U̲',
        //         action: () => _api.formatUnderline(),
        //       ),
        //       ContextMenuItem(
        //         androidId: 4,
        //         iosId: '4',
        //         title: '̶T̶',
        //         action: () => _api.formatStrikeThrough(),
        //       ),
        //     },
        //     if (textSelectionMenuItems != null) ...{
        //       for (final item in textSelectionMenuItems) ...{
        //         ContextMenuItem(
        //           androidId: 100 + textSelectionMenuItems.indexOf(item),
        //           iosId: item.label,
        //           title: item.label,
        //           action: () => item.action(_api),
        //         ),
        //       },
        //     },
        //   ],
        // ),
      );

  void _onWebViewCreated(WebViewController controller) {
    _webViewController = controller;
    controller.loadHtmlString(_initialPageContent);
    _api.webViewController = controller;
    final onCreated = widget.onCreated;
    if (onCreated != null) {
      onCreated(_api);
    }
    final onReady = _api.onReady;
    if (onReady != null) {
      onReady();
    }
  }

  void _onFormatSettingsReceived(JavascriptMessage message) {
    // print('got format ${message.message}');
    final callback = _api.onFormatSettingsChanged;
    if (callback != null && message.message.isNotEmpty) {
      final numericMessage = int.tryParse(message.message);
      if (numericMessage != null) {
        callback(
          FormatSettings(
            isBold: (numericMessage & 1) == 1,
            isItalic: (numericMessage & 2) == 2,
            isUnderline: (numericMessage & 4) == 4,
            isStrikeThrough: (numericMessage & 8) == 8,
          ),
        );
      }
    }
  }

  void _onFontSizeSettingsReceived(JavascriptMessage message) {
    // print('got size ${message.message}');
    final callback = _api.onFontSizeChanged;
    if (callback != null) {
      FontSize? size;
      switch (message.message) {
        case 'x-small':
          size = FontSize.xSmall;
          break;
        case 'small':
          size = FontSize.small;
          break;
        case 'medium':
          size = FontSize.medium;
          break;
        case 'large':
          size = FontSize.large;
          break;
        case 'x-large':
          size = FontSize.xLarge;
          break;
        case 'xx-large':
          size = FontSize.xxLarge;
          break;
        case 'xxx-large':
          size = FontSize.xxxLarge;
          break;
        case 'undefined':
          size = FontSize.medium;
          break;
      }
      if (size != null) {
        callback(size);
      }
    }
  }

  static Map<String, SafeFont>? _fontsByName;
  void _onFontFamilySettingsReceived(JavascriptMessage message) {
    // print('got size ${message.message}');
    final callback = _api.onFontFamilyChanged;
    if (callback != null && message.message.isNotEmpty) {
      var map = _fontsByName;
      if (map == null) {
        map = <String, SafeFont>{};
        for (final font in SafeFont.values) {
          map[font.name] = font;
        }
        _fontsByName = map;
      }
      final font = map[message.message];
      callback(font);
    }
  }

  void _onAlignSettingsReceived(JavascriptMessage message) {
    // print('got align ${message.message}');
    final callback = _api.onAlignSettingsChanged;
    if (callback != null && message.message.isNotEmpty) {
      ElementAlign align;
      switch (message.message) {
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

  void _onColorSettingsReceived(JavascriptMessage message) {
    // print('got colors  ${message.message}');
    final callback = _api.onColorChanged;
    final parameters = message.message.split('x');
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

  void _onLinkSettingsReceived(JavascriptMessage message) {
    // print('got link ${message.message}');
    final callback = _api.onLinkSettingsChanged;
    final parameters = message.message.split('<_>');
    if (callback != null) {
      if (parameters.length == 2) {
        final url = parameters[0];
        final text = parameters[1];
        callback(LinkSettings(url, text));
      } else {
        callback(null);
      }
    }
  }

  void _onInternalUpdateReceived(JavascriptMessage message) {
    // print('InternalUpdate got update: ${message.message}');
    if (message.message.startsWith('h')) {
      if (widget.adjustHeight) {
        final height = double.tryParse(message.message.substring(1));
        if (height != null) {
          setState(() {
            _documentHeight = height + 15.0;
          });
        }
      }
    } else if (message.message == 'onfocus') {
      FocusScope.of(context).unfocus();
    }
  }

  /// Notifies the editor about a change of the document
  /// that can influence the height.
  ///
  /// The height will be measured and applied if [HtmlEditor.adjustHeight]
  /// is set to true.
  Future<void> onDocumentChanged() async {
    if (widget.adjustHeight) {
      final scrollHeightText = await _webViewController
          .runJavascriptReturningResult('document.body.scrollHeight');
      final scrollHeight = double.tryParse(scrollHeightText);
      if (scrollHeight != null &&
          mounted &&
          (scrollHeight + 15.0 > widget.minHeight)) {
        setState(() {
          _documentHeight = scrollHeight + 15.0;
        });
      }
    }
  }
}
