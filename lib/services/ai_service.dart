import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  static const String _apiKey = 'AIzaSyDAZmx4v-HNBebzoLjDlAVxevBHvuZ-QBQ';
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static Future<List<Map<String, String>>> generateStudyPlan(
      String subject, int daysAvailable) async {
    final weeks = (daysAvailable / 7).ceil().clamp(1, 6);
    final prompt = '''
You are an academic study planner. Create a structured week-by-week study plan for a student preparing for a $subject exam with $daysAvailable days available.
Return ONLY a JSON array. Each item must have "week" and "title" keys.
Create $weeks weeks with 3-4 tasks per week. Be specific and practical.
Example format:
[
  {"week": "Week 1", "title": "Review core concepts and lecture notes"},
  {"week": "Week 1", "title": "Complete chapter 1 exercises"},
  {"week": "Week 2", "title": "Practice past exam questions"},
  {"week": "Week 3 - Final", "title": "Full mock exam practice"}
]
Return only the JSON array, no other text.
''';

    try {
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        final cleaned = text.trim()
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final List<dynamic> parsed = jsonDecode(cleaned);
        return parsed.map<Map<String, String>>((item) => {
              'week': item['week']?.toString() ?? '',
              'title': item['title']?.toString() ?? '',
            }).toList();
      }
    } catch (e) {
      // Fall through to default plan
    }
    return _defaultPlan(subject, weeks);
  }

  static List<Map<String, String>> _defaultPlan(String subject, int weeks) {
    final plan = <Map<String, String>>[];
    for (int w = 1; w <= weeks; w++) {
      final weekLabel = w == weeks ? 'Week $w - Final' : 'Week $w';
      plan.addAll([
        {'week': weekLabel, 'title': 'Review $subject chapter ${w * 2 - 1} notes'},
        {'week': weekLabel, 'title': 'Complete practice exercises for week $w'},
        if (w == weeks) {'week': weekLabel, 'title': 'Full mock exam practice'},
        if (w == weeks) {'week': weekLabel, 'title': 'Final revision and key concepts review'},
      ]);
    }
    return plan;
  }
}
