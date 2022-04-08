import 'package:enough_html_editor/enough_html_editor.dart';
import 'package:enough_platform_widgets/enough_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

const _htmlContent =
    '''<p>Here is some text</p> with a <a href="https://github.com/Enough-Software/enough_html_editor">link</a>.
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
              </blockquote>
    ''';

/// Example app that shows how to use the enough_html_editor package
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => PlatformSnackApp(
        title: 'enough_html_editor Demo',
        materialTheme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        cupertinoTheme: const CupertinoThemeData(
          primaryColor: CupertinoColors.activeGreen,
          brightness: Brightness.light,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        home: const EditorPage(),
      );
}

/// Example how to use the simplified [PackagedHtmlEditor]
/// that combines the default controls and the editor.
class EditorPage extends StatefulWidget {
  /// Creates a new editor page
  const EditorPage({Key? key}) : super(key: key);

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('PackagedHtmlEditor'),
          trailingActions: [
            DensePlatformIconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                final text = await _editorApi!.getText();
                print('got text: [$text]');
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(htmlText: text),
                  ),
                );
              },
            ),
            DensePlatformIconButton(
              icon: const Icon(Icons.looks_two),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CustomScrollEditorPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                PlatformTextButton(
                  onPressed: () => _editorApi?.unfocus(context),
                  child: const Text('Unfocus'),
                ),
                PackagedHtmlEditor(
                  onCreated: (api) {
                    _editorApi = api;
                  },
                  initialContent: _htmlContent,
                ),
              ],
            ),
          ),
        ),
      );
}

/// Example how to use editor within a a CustomScrollView
class CustomScrollEditorPage extends StatefulWidget {
  /// Creates an CustomScrollView example page
  const CustomScrollEditorPage({Key? key}) : super(key: key);

  @override
  _CustomScrollEditorPageState createState() => _CustomScrollEditorPageState();
}

class _CustomScrollEditorPageState extends State<CustomScrollEditorPage> {
  HtmlEditorApi? _editorApi;

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            PlatformSliverAppBar(
              title: const Text('Sticky controls'),
              floating: false,
              pinned: true,
              stretch: true,
              actions: [
                DensePlatformIconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = await _editorApi!.getText();
                    print('got text: [$text]');
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ResultScreen(htmlText: text),
                      ),
                    );
                  },
                ),
                DensePlatformIconButton(
                  icon: const Icon(Icons.looks_one),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const EditorPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: DecoratedPlatformTextField(
                    decoration: InputDecoration(hintText: 'Subject')),
              ),
            ),
            if (_editorApi != null) ...{
              SliverHeaderHtmlEditorControls(editorApi: _editorApi),
            },
            SliverToBoxAdapter(
              child: HtmlEditor(
                onCreated: (api) {
                  setState(() {
                    _editorApi = api;
                  });
                },
                initialContent: _htmlContent,
              ),
            ),
          ],
        ),
      );
}

/// Displays the resulting HTML code
class ResultScreen extends StatelessWidget {
  /// Creates a new results screen
  const ResultScreen({Key? key, required this.htmlText}) : super(key: key);

  /// The HTML code
  final String htmlText;

  @override
  Widget build(BuildContext context) => PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Result'),
        ),
        body: SingleChildScrollView(
          child: SafeArea(child: SelectableText(htmlText)),
        ),
      );
}
