// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_html_editor_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('text retrieval smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(EditorPage), findsOneWidget);

    final expectedHtml = '''<p>Here is some text</p>
        <p>Here is <b>bold</b> text</p>
        <p>Here is <i>some italic sic</i> text</p>
        <p>Here is <i><b>bold and italic</b></i> text</p>
        <p style="text-align: center;">Here is <u><i><b>bold and italic and underline</b></i></u> text</p>
        <ul><li>one list element</li><li>another point</li></ul>
        <blockquote>Here is a quote<br/>
        that spans several lines<br/>
        <blockquote>
            Another second level blockqote 
        </blockquote>
        </blockquote>''';

    // Verify that our editor is there.
    expect(find.byType(HtmlEditor), findsOneWidget);

    final editor = tester.firstWidget(find.byType(HtmlEditor)) as HtmlEditor;
    expect(editor, isNotNull);
    while ((editor.key as GlobalKey<HtmlEditorState>).currentState == null) {
      print('waiting for state');
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final state = (editor.key as GlobalKey<HtmlEditorState>).currentState;
    final completer = Completer<bool>();
    print('waiting for editor to be ready...');
    state.api.onReady = () async {
      final html = await state.api.getText();
      expect(html, expectedHtml);
      completer.complete(true);
    };
    final completed = await completer.future;
    expect(completed, isTrue);
  });
}
