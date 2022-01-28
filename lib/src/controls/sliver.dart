import 'package:flutter/material.dart';

import '../editor.dart';
import '../editor_api.dart';
import 'base.dart';

/// HTML editor controls to be used within a sliver-based view.
///
/// e.g. a [CustomScrollView].
class SliverHeaderHtmlEditorControls extends StatelessWidget {
  /// Creates new sliver editor controls
  const SliverHeaderHtmlEditorControls({
    Key? key,
    this.editorKey,
    this.editorApi,
    this.prefix,
    this.suffix,
    this.excludeDocumentLevelControls = false,
  })  : assert(editorKey != null || editorApi != null,
            'either editorKey or editorApi is required.'),
        super(key: key);

  /// The global key for [HtmlEditorState]
  final GlobalKey<HtmlEditorState>? editorKey;

  /// The editor API
  final HtmlEditorApi? editorApi;

  /// Optional widget to be placed before other editor controls
  final Widget? prefix;

  /// Optional widget to be placed after other editor controls

  final Widget? suffix;

  /// Should document level controls like page background color be excluded?
  final bool excludeDocumentLevelControls;

  @override
  Widget build(BuildContext context) => SliverPersistentHeader(
        delegate: _SliverHeaderHtmlEditorControlsDelegate(
          editorKey: editorKey,
          editorApi: editorApi,
          prefix: prefix,
          suffix: suffix,
        ),
        pinned: true,
      );
}

class _SliverHeaderHtmlEditorControlsDelegate
    extends SliverPersistentHeaderDelegate {
  _SliverHeaderHtmlEditorControlsDelegate({
    this.editorKey,
    this.editorApi,
    this.prefix,
    this.suffix,
    this.height = 48,
  });
  final double height;
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Container(
        color: Theme.of(context).canvasColor,
        child: HtmlEditorControls(
          editorKey: editorKey,
          editorApi: editorApi,
          prefix: prefix,
          suffix: suffix,
        ),
      );

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
