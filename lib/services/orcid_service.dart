import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔹 ORCID Work Data Model (SERVICE LAYER)
class WorkItem {
  final String title;
  final String type;
  final String year;
  final String source;

  WorkItem({
    required this.title,
    required this.type,
    required this.year,
    required this.source,
  });
}

class OrcidService {
  static const String _baseUrl = 'https://pub.orcid.org/v3.0';

  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.orcid+json',
  };

  /// 🔹 WORK TITLES (UNCHANGED & SAFE)
  static Future<List<String>> fetchWorkTitles(String orcidId) async {
    try {
      final uri = Uri.parse('$_baseUrl/$orcidId/works');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List groups = data['group'] ?? [];

      List<String> titles = [];

      for (final group in groups) {
        final List summaries = group['work-summary'] ?? [];
        for (final summary in summaries) {
          final title = summary?['title']?['title']?['value'];
          if (title != null && title.toString().trim().isNotEmpty) {
            titles.add(title.toString());
            break; // one title per group
          }
        }
      }

      return titles;
    } catch (_) {
      return [];
    }
  }

  /// 🔹 GROUPED WORK FETCH (USED BY VIEW DETAILS)
  static Future<Map<String, List<WorkItem>>> fetchGroupedWorks(
      String orcidId) async {
    final uri = Uri.parse('$_baseUrl/$orcidId/works');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode != 200) return {};

    final data = json.decode(response.body);
    final List groups = data['group'] ?? [];

    final Map<String, List<WorkItem>> grouped = {};

    for (final group in groups) {
      final List summaries = group['work-summary'] ?? [];
      if (summaries.isEmpty) continue;

      final summary = summaries.first; // ✅ one per group

      final String type = summary['type'] ?? 'unknown';
      final String title =
          summary['title']?['title']?['value'] ?? 'Untitled';
      final String year =
          summary['publication-date']?['year']?['value'] ?? '-';
      final String source =
          summary['journal-title']?['value'] ?? '—';

      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(
        WorkItem(
          title: title,
          type: type,
          year: year,
          source: source,
        ),
      );
    }

    return grouped;
  }

  /// 🔥 COUNTS (REAL TOTAL = GROUP COUNT)
  static Future<Map<String, dynamic>> fetchWorkCounts(
      String orcidId) async {
    try {
      final uri = Uri.parse('$_baseUrl/$orcidId/works');
      final response = await http.get(uri, headers: _headers);

      if (response.statusCode != 200) {
        return _emptyCounts();
      }

      final data = json.decode(response.body);
      final List groups = data['group'] ?? [];

      int total = groups.length; // ✅ REAL WORK COUNT
      int bookChapter = 0;
      int conference = 0;
      int patent = 0;
      int book = 0;

      for (final group in groups) {
        final List summaries = group['work-summary'] ?? [];

        for (final summary in summaries) {
          final String? type = summary['type'];

          switch (type) {
            case 'book-chapter':
              bookChapter++;
              break;
            case 'conference-paper':
              conference++;
              break;
            case 'patent':
              patent++;
              break;
            case 'book':
              book++;
              break;
            default:
              break;
          }
        }
      }

      return {
        'total': total,
        'bookChapter': bookChapter,
        'conference': conference,
        'patent': patent,
        'book': book,
      };
    } catch (_) {
      return _emptyCounts();
    }
  }

  static Map<String, dynamic> _emptyCounts() => {
        'total': 0,
        'bookChapter': 0,
        'conference': 0,
        'patent': 0,
        'book': 0,
      };
}
