import 'package:flutter/material.dart';

import '../editor.dart';
import '../editor_api.dart';
import 'base.dart';

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
