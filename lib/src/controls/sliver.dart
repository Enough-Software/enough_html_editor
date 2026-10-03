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
  }) : assert(
         editorKey != null || editorApi != null,
         'either editorKey or editorApi is required.',
       ),
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
      excludeDocumentLevelControls: excludeDocumentLevelControls,
      // The controls are laid out with a fixed height of
      // [HtmlEditorControls.defaultHeight]. The persistent header has to
      // use the same extent, otherwise its layoutExtent exceeds its
      // paintExtent and triggers a SliverGeometry assertion.
      height: HtmlEditorControls.defaultHeight,
    ),
    pinned: true,
  );
}

class _SliverHeaderHtmlEditorControlsDelegate
    extends SliverPersistentHeaderDelegate {
  _SliverHeaderHtmlEditorControlsDelegate({
    required this.height,
    this.editorKey,
    this.editorApi,
    this.prefix,
    this.suffix,
    this.excludeDocumentLevelControls = false,
  });
  final double height;
  final GlobalKey<HtmlEditorState>? editorKey;
  final HtmlEditorApi? editorApi;
  final Widget? prefix;
  final Widget? suffix;
  final bool excludeDocumentLevelControls;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(
    color: Theme.of(context).canvasColor,
    // Make sure the header child always fills the persistent header's
    // main-axis extent. Otherwise `layoutExtent` can exceed `paintExtent`
    // when the controls report a smaller height (for example while they are
    // still showing a progress indicator).
    child: SizedBox(
      height: height,
      child: HtmlEditorControls(
        editorKey: editorKey,
        editorApi: editorApi,
        prefix: prefix,
        suffix: suffix,
        excludeDocumentLevelControls: excludeDocumentLevelControls,
      ),
    ),
  );

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    final old = oldDelegate as _SliverHeaderHtmlEditorControlsDelegate;
    return editorKey != old.editorKey ||
        editorApi != old.editorApi ||
        prefix != old.prefix ||
        suffix != old.suffix ||
        excludeDocumentLevelControls != old.excludeDocumentLevelControls ||
        height != old.height;
  }
}
