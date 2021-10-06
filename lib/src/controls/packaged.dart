import 'package:flutter/material.dart';

import '../editor.dart';
import '../editor_api.dart';
import '../models.dart';
import 'base.dart';

/// A combination of controls and editor for a simpler usage.
///
/// Like for the editor you can either use the `onCreated(EditorApi)` callback or a global key to get access to the state,
/// in this case the [PackagedHtmlEditorState]. With either the state or the [HtmlEditorApi] you can access the edited text with
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

  /// Set `excludeDocumentLevelControls` to `true` in case document level controls such as the page background color should be excluded.
  final bool excludeDocumentLevelControls;

  /// Creates a new packaged HTML editor
  ///
  /// Set the [initialContent] to populate the editor with some existing text
  /// Set [adjustHeight] to let the editor set its height automatically - by default this is `true`.
  /// Specify the [minHeight] to set a different height than the default `100` pixel.
  /// Define the [onCreated] `onCreated(EditorApi)` callback to get notified when the API is ready.
  /// Set [splitBlockquotes] to `false` in case block quotes should not be split when the user adds a newline in one - this defaults to `true`.
  /// Set [addDefaultSelectionMenuItems] to `false` when you do not want to have the default text selection items enabled.
  /// You can define your own custom context / text selection menu entries using [textSelectionMenuItems].
  /// Set [excludeDocumentLevelControls] to `true` in case controls that affect the whole document like the page background color should be excluded.
  PackagedHtmlEditor({
    Key? key,
    this.initialContent = '',
    this.adjustHeight = true,
    this.minHeight = 100,
    this.onCreated,
    this.splitBlockquotes = true,
    this.addDefaultSelectionMenuItems = true,
    this.textSelectionMenuItems,
    this.excludeDocumentLevelControls = false,
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
            excludeDocumentLevelControls: widget.excludeDocumentLevelControls,
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
