class GeminiResponse {
  final String generatedText;

  GeminiResponse({required this.generatedText});

  factory GeminiResponse.fromJson(Map<String, dynamic> json) {
    return GeminiResponse(
      generatedText: json['candidates'][0]['content']['parts'][0]['text'],
    );
  }
}//comment