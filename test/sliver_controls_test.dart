import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'SliverHeaderHtmlEditorControls lays out without SliverGeometry error',
    (tester) async {
      final api = HtmlEditorApi(HtmlEditorState());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverHeaderHtmlEditorControls(editorApi: api),
                const SliverToBoxAdapter(child: SizedBox(height: 400)),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
