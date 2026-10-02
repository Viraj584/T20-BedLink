import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/test_report.dart';
import 'report_analysis_service.dart';

class OpenRouterService {
  final http.Client _client;
  final ReportAnalysisService _fallbackService;

  OpenRouterService({
    http.Client? client,
    ReportAnalysisService? fallbackService,
  })  : _client = client ?? http.Client(),
        _fallbackService = fallbackService ?? ReportAnalysisService();

  /// Sends digital test report content to OpenRouter API for deep LLM vision/text analysis.
  /// Falls back seamlessly to the local rule engine if API key is missing or request fails.
  Future<ReportAnalysisResult> analyzeDigitalReport({
    required String reportTitle,
    required String rawText,
    String? base64Image,
    String? apiKey,
    String model = 'google/gemini-2.5-flash-lite',
  }) async {
    final cleanApiKey = apiKey?.trim() ?? '';

    // If no API key provided, use instant local engine
    if (cleanApiKey.isEmpty) {
      debugPrint('No OpenRouter API key provided. Using local AI engine fallback.');
      return _fallbackService.analyzeReport(reportTitle, rawText);
    }

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      final systemPrompt = '''
You are a compassionate, highly accurate AI Medical Report Analyzer for BedLink.
Analyze the following digital medical test report (image scan or text document) and provide a patient-friendly summary.
Explain complex medical jargon into simple, plain English suitable for non-medical patients.

MUST return strictly valid JSON matching this exact format:
{
  "severity": "normal" | "attention" | "critical",
  "headline": "Short friendly summary headline",
  "simpleExplanation": "Clear, non-technical plain English paragraph explaining what the test values mean.",
  "keyFindings": ["Bullet point 1 with emoji", "Bullet point 2 with emoji"],
  "recommendationType": "none" | "clinic" | "hospital",
  "recommendationReason": "Reason for recommendation",
  "recommendedSpecialty": "Dermatology (Skin)" | "Blood Tests & Pathology" | "Gynecology & Maternity" | "Dental Care" | "Pediatrics (Child)" | "Orthopedics (Bone)" | "Ophthalmology (Eye)" | "General Physician" | null
}
''';

      final List<Map<String, dynamic>> userMessageParts = [
        {
          'type': 'text',
          'text': 'Report Title: $reportTitle\n\nReport Text Content:\n$rawText',
        }
      ];

      if (base64Image != null && base64Image.isNotEmpty) {
        final dataUri = base64Image.startsWith('data:')
            ? base64Image
            : 'data:image/jpeg;base64,$base64Image';
        userMessageParts.add({
          'type': 'image_url',
          'image_url': {'url': dataUri},
        });
      }

      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanApiKey',
          'HTTP-Referer': 'https://bedlink.app',
          'X-Title': 'BedLink AI Analyzer',
        },
        body: jsonEncode({
          'model': model == 'google/gemini-2.0-flash-lite-001' ? 'google/gemini-2.5-flash-lite' : model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessageParts},
          ],
          'temperature': 0.2,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? rawContent = data['choices']?[0]?['message']?['content'];
        if (rawContent != null && rawContent.isNotEmpty) {
          String cleanContent = rawContent.trim();
          if (cleanContent.startsWith('```json')) {
            cleanContent = cleanContent.substring(7);
          } else if (cleanContent.startsWith('```')) {
            cleanContent = cleanContent.substring(3);
          }
          if (cleanContent.endsWith('```')) {
            cleanContent = cleanContent.substring(0, cleanContent.length - 3);
          }
          cleanContent = cleanContent.trim();

          final jsonMap = jsonDecode(cleanContent);
          return ReportAnalysisResult.fromJson(jsonMap);
        }
      } else {
        debugPrint('OpenRouter API returned HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('OpenRouter API request error ($e). Falling back to local engine.');
    }

    // Fallback if API fails or fails to parse
    return _fallbackService.analyzeReport(reportTitle, rawText);
  }
}
