import 'package:bilimusic/feature/meting/domain/meting_search_item.dart';

class MetingSearchResponse {
  const MetingSearchResponse({required this.keyword, required this.results});

  final String keyword;
  final List<MetingSearchItem> results;
}
