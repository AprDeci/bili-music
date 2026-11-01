import 'package:bilimusic/common/domain/collection_kind.dart';
import 'package:bilimusic/feature/favorites/ui/components/collection_kind_tag.dart';
import 'package:flutter/material.dart';

Future<CollectionKind?> showCollectionKindDialog({
  required BuildContext context,
  CollectionKind initialKind = CollectionKind.music,
  String title = '选择歌单类型',
}) {
  return showDialog<CollectionKind>(
    context: context,
    builder: (BuildContext context) =>
        _CollectionKindDialog(initialKind: initialKind, title: title),
  );
}

class _CollectionKindDialog extends StatefulWidget {
  const _CollectionKindDialog({required this.initialKind, required this.title});

  final CollectionKind initialKind;
  final String title;

  @override
  State<_CollectionKindDialog> createState() => _CollectionKindDialogState();
}

class _CollectionKindDialogState extends State<_CollectionKindDialog> {
  late CollectionKind _kind = widget.initialKind;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: SizedBox(
        width: 360,
        child: RadioGroup<CollectionKind>(
          groupValue: _kind,
          onChanged: (CollectionKind? kind) {
            if (kind != null) setState(() => _kind = kind);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final CollectionKind kind in CollectionKind.values)
                RadioListTile<CollectionKind>(
                  value: kind,
                  title: Row(
                    children: <Widget>[
                      CollectionKindIcon(kind: kind),
                      const SizedBox(width: 8),
                      Text(kind.label),
                    ],
                  ),
                  subtitle: Text(switch (kind) {
                    CollectionKind.music => '适合音乐。支持匹配歌曲信息、封面和歌词。',
                    CollectionKind.spoken =>
                      '适合播客、相声、有声书等长内容。保留原视频信息，不匹配歌曲信息和歌词，并记住收听进度。',
                  }),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_kind),
          child: const Text('确定'),
        ),
      ],
    );
  }
}
