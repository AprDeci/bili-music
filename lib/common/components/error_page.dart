import 'package:flutter/material.dart';

class ErrorPageStatefulWidget extends StatefulWidget {
  const ErrorPageStatefulWidget({super.key, this.message});

  final String? message;

  @override
  State<ErrorPageStatefulWidget> createState() =>
      _ErrorPageStatefulWidgetState();
}

class _ErrorPageStatefulWidgetState extends State<ErrorPageStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(widget.message ?? 'Error')),
    );
  }
}
