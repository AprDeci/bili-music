import 'package:bilimusic/feature/meting/domain/meting_server.dart';
import 'package:bilimusic/feature/meting/domain/meting_source_rule.dart';
import 'package:flutter/material.dart';

/// 弹出「关键词/歌手 → 音源」规则编辑器，取消时返回 null。
Future<MetingSourceRule?> showMetingSourceRuleDialog({
  required BuildContext context,
  required String initialKeyword,
  required MetingServer initialServer,
}) {
  return showDialog<MetingSourceRule>(
    context: context,
    builder: (BuildContext context) => _MetingSourceRuleDialog(
      initialKeyword: initialKeyword,
      initialServer: initialServer,
    ),
  );
}

class _MetingSourceRuleDialog extends StatefulWidget {
  const _MetingSourceRuleDialog({
    required this.initialKeyword,
    required this.initialServer,
  });

  final String initialKeyword;
  final MetingServer initialServer;

  @override
  State<_MetingSourceRuleDialog> createState() =>
      _MetingSourceRuleDialogState();
}

class _MetingSourceRuleDialogState extends State<_MetingSourceRuleDialog> {
  late final TextEditingController _controller;
  late MetingServer _server;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword);
    _server = widget.initialServer;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String keyword = _controller.text.trim();

    return AlertDialog(
      title: const Text('记住音源规则'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '关键词或歌手',
              hintText: '例如：周杰伦',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: <Widget>[
              for (final MetingServer server in MetingServer.values)
                ChoiceChip(
                  label: Text(server.label),
                  selected: server == _server,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() {
                        _server = server;
                      });
                    }
                  },
                ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: keyword.isEmpty
              ? null
              : () => Navigator.of(
                  context,
                ).pop(MetingSourceRule(keyword: keyword, server: _server)),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
