import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.0-flash',
    apiKey: dotenv.env["API_KEY0"]!,
  );

  Future<String> analyzeImages(List<File> imageFiles) async {
    final List<Part> parts = [
      TextPart(
  '''You are a parking assistant AI.

From the following parking lot images, recommend only **one** optimal empty parking slot.

### Rules:
- Do **not** return explanations or reasoning.
- Prioritize slots that are far from moving vehicles.
- Output format: Only the slot name, like "Slot B7"
- it should start with "Slot" and then a number for example "Slot B7"
- Do **not** add punctuation or extra text.

Respond with just the slot name.'''
),
      for (File image in imageFiles)
        DataPart('image/jpeg', await image.readAsBytes()),
    ];

    final response = await _model.generateContent([Content.multi(parts)]);

    return response.text ?? 'No recommendation was generated.';
  }
}
