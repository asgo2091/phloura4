import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class TextScreen extends StatelessWidget {
  final String textOut;
  final String heading;

  const TextScreen({super.key, required this.textOut, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.yellow, title: Text(heading)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: HtmlWidget(textOut),
          ),
        ),
      ),
    );
  }
}
