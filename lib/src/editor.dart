import 'package:flutter/material.dart';

import 'editor_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Standard format settings
class FormatSettings {
  final isBold;
  final isItalic;
  final isUnderline;
  FormatSettings(this.isBold, this.isItalic, this.isUnderline);
}

/// Standard align settings
enum ElementAlign { left, center, right, justify }

/// Slim HTML Editor with API
class HtmlEditor extends StatefulWidget {
  /// Set the [initialContent] to populate the editor with some existing text
  final String initialContent;

  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  final bool adjustHeight;

  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  final int minHeight;

  /// Define the `onCreated(EditorApi)` callback to get notified when the API is ready.
  final void Function(EditorApi)? onCreated;

  /// Defines if blockquotes should be split when the user adds a new line - defaults to `true`.
  final bool splitBlockquotes;

  /// Creates a new HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text
  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  /// Define the [onCreated] `onCreated(EditorApi)` callback to get notified when the API is ready.
  /// Set [splitBlockquotes] to `false` in case block quotes should not be split when the user adds a newline in one - this defaults to `true`.
  HtmlEditor({
    Key? key,
    this.initialContent = '',
    this.adjustHeight = true,
    this.minHeight = 100,
    this.onCreated,
    this.splitBlockquotes = true,
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
  var selectionTextAlign = undefined;
  var isLineBreakInput = false;
  var documentHeight;

  function onSelectionChange() {
    //console.log|("onSelectionChange");
    let {anchorNode, anchorOffset, focusNode, focusOffset} = document.getSelection();
    // traverse all parents to find <b>, <i> or <u> elements:
    var isBold = false;
    var isItalic = false;
    var isUnderline = false;
    var node = anchorNode;
    var textAlign = undefined;
    var nestedBlockqotes = 0;
    var rootBlockquote;
    while (node.parentNode != null && node.id != 'editor') {
      if (node.nodeName == 'B') {
          isBold = true;
      } else if (node.nodeName == 'I') {
          isItalic = true;
      } else if (node.nodeName == 'U') {
          isUnderline = true;
      } else if (node.nodeName == 'BLOCKQUOTE') {
          nestedBlockqotes++;
          rootBlockquote = node;
      }
      if (textAlign == undefined && node.style?.textAlign != undefined && node.style.textAlign != '') {
        textAlign = node.style.textAlign;
      }
      node = node.parentNode;
    }
    if (isBold != isSelectionBold || isItalic != isSelectionItalic || isUnderline != isSelectionUnderline) {
      isSelectionBold = isBold;
      isSelectionItalic = isItalic;
      isSelectionUnderline = isUnderline;
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
      window.flutter_inappwebview.callHandler('FormatSettings', message);
    }
    if (textAlign != selectionTextAlign) {
      selectionTextAlign = textAlign;
      window.flutter_inappwebview.callHandler('AlignSettings', textAlign);
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
    var height = document.body.scrollHeight;
    if (height != documentHeight) {
        documentHeight = height;
        window.flutter_inappwebview.callHandler('InternalUpdate', 'h' + height);
    }
  }

  function onFocus() {
    window.flutter_inappwebview.callHandler('InternalUpdate', 'onfocus');
  }

  function onLoaded() {
    documentHeight = document.body.scrollHeight;
    document.onselectionchange = onSelectionChange;
    document.getElementById('editor').oninput = onInput;
  }
</script>
</head>
<body onload="onLoaded();" >
<div id="editor" contenteditable="true" onfocus="onFocus();">
==content==
</div>
</body>
</html>
''';
  late String _initialPageContent;
  late InAppWebViewController _webViewController;
  double? _documentHeight;
  late EditorApi _api;

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
  EditorApi get api => _api;

  @override
  void initState() {
    super.initState();
    _api = EditorApi(this);
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
        final scrollWidth = await _webViewController.evaluateJavascript(
            source: 'document.body.scrollWidth') as int?;
        final size = MediaQuery.of(context).size;
        print(
            'scrollWidth=$scrollWidth available=${size.width} adjustHeight=${widget.adjustHeight}');
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
    if (_api.onFormatSettingsChanged != null && parameters.isNotEmpty) {
      final numericMessage = parameters.first as int?;
      if (numericMessage != null) {
        final isBold = (numericMessage & 1) == 1;
        final isItalic = (numericMessage & 2) == 2;
        final isUnderline = (numericMessage & 4) == 4;
        _api.onFormatSettingsChanged!(
            FormatSettings(isBold, isItalic, isUnderline));
      }
    }
  }

  void _onAlignSettingsReceived(List<dynamic> parameters) {
    // print('got align $parameters');
    if (_api.onAlignSettingsChanged != null && parameters.isNotEmpty) {
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
      _api.onAlignSettingsChanged!(align);
    }
  }

  void _onInternalUpdateReceived(List<dynamic> parameters) {
    // print('InternalUpdate got update: $parameters');
    if (parameters.isNotEmpty) {
      final message = parameters.first as String?;
      if (message != null && message.startsWith('h')) {
        final height = double.tryParse(message.substring(1));
        if (height != null) {
          setState(() {
            _documentHeight = height + 5;
          });
        }
      } else if (message == 'onfocus') {
        FocusScope.of(context).unfocus();
      }
    }
  }
}
