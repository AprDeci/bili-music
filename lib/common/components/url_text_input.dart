import 'package:flutter/material.dart';

const List<String> _supportedSchemes = <String>['https', 'http'];

class ParsedHttpUrl {
  const ParsedHttpUrl({required this.scheme, required this.remainder});

  final String scheme;
  final String remainder;
}

class UrlTextInput extends StatefulWidget {
  const UrlTextInput({
    super.key,
    required this.labelText,
    required this.value,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final String labelText;
  final String value;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<UrlTextInput> createState() => _UrlTextInputState();
}

class _UrlTextInputState extends State<UrlTextInput> {
  late final TextEditingController _remainderController;
  late String _scheme;

  @override
  void initState() {
    super.initState();
    final ParsedHttpUrl parsed = parseHttpUrl(widget.value);
    _scheme = parsed.scheme;
    _remainderController = TextEditingController(text: parsed.remainder);
  }

  @override
  void didUpdateWidget(covariant UrlTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) {
      return;
    }

    final ParsedHttpUrl parsed = parseHttpUrl(widget.value);
    final String nextValue = parsed.remainder;
    if (_remainderController.text != nextValue) {
      _remainderController.value = TextEditingValue(
        text: nextValue,
        selection: TextSelection.collapsed(offset: nextValue.length),
      );
    }
    if (_scheme != parsed.scheme) {
      setState(() {
        _scheme = parsed.scheme;
      });
    }
  }

  @override
  void dispose() {
    _remainderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _remainderController,
      enabled: widget.enabled,
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: _SchemeDropdown(
          value: _scheme,
          enabled: widget.enabled,
          onChanged: (String value) {
            setState(() {
              _scheme = value;
            });
            _notifyChanged();
          },
        ),
      ),
      onChanged: (_) => _notifyChanged(),
      onSubmitted: (_) => widget.onSubmitted?.call(_composeValue()),
    );
  }

  void _notifyChanged() {
    widget.onChanged?.call(_composeValue());
  }

  String _composeValue() {
    return composeHttpUrl(
      scheme: _scheme,
      remainder: _remainderController.text,
    );
  }
}

class _SchemeDropdown extends StatelessWidget {
  const _SchemeDropdown({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String value;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          focusColor: Colors.transparent,
          onChanged: enabled
              ? (String? nextValue) {
                  if (nextValue == null) {
                    return;
                  }
                  onChanged(nextValue);
                }
              : null,
          items: _supportedSchemes
              .map((String scheme) {
                return DropdownMenuItem<String>(
                  value: scheme,
                  child: Text('$scheme://'),
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

ParsedHttpUrl parseHttpUrl(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return const ParsedHttpUrl(scheme: 'https', remainder: '');
  }

  final Uri? uri = Uri.tryParse(trimmed);
  final String scheme = uri?.scheme.toLowerCase() ?? '';
  if (_supportedSchemes.contains(scheme)) {
    final String prefix = '$scheme://';
    final String remainder = trimmed.startsWith(prefix)
        ? trimmed.substring(prefix.length)
        : trimmed.replaceFirst(RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'), '');
    return ParsedHttpUrl(scheme: scheme, remainder: remainder);
  }

  return ParsedHttpUrl(scheme: 'https', remainder: trimmed);
}

String composeHttpUrl({required String scheme, required String remainder}) {
  final String normalizedRemainder = remainder.trim();
  if (normalizedRemainder.isEmpty) {
    return '';
  }

  final String normalizedScheme = _supportedSchemes.contains(scheme)
      ? scheme
      : 'https';
  final String withoutScheme = normalizedRemainder.replaceFirst(
    RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://'),
    '',
  );
  return '$normalizedScheme://$withoutScheme';
}

String normalizeHttpUrl(String value) {
  return value.trim().replaceFirst(RegExp(r'/+$'), '');
}

bool isValidHttpUrl(String value) {
  final String normalized = normalizeHttpUrl(value);
  if (normalized.isEmpty) {
    return true;
  }

  final Uri? uri = Uri.tryParse(normalized);
  return uri != null &&
      _supportedSchemes.contains(uri.scheme.toLowerCase()) &&
      uri.host.isNotEmpty;
}
