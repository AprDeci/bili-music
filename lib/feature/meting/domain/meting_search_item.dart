import 'package:bilimusic/feature/meting/domain/meting_server.dart';

class MetingSearchItem {
  const MetingSearchItem({
    required this.id,
    required this.title,
    required this.author,
    required this.server,
    this.picId,
  });

  final String id;
  final String title;
  final String author;
  final MetingServer server;
  final String? picId;
}
