import 'dart:convert';
import 'package:http/http.dart' as http;

class GroqService {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final String apiKey;

  GroqService(this.apiKey);

  Future<String> chat({
    required List<Map<String, String>> messages,
    String? systemPrompt,
  }) async {
    final allMessages = <Map<String, String>>[];

    if (systemPrompt != null) {
      allMessages.add({'role': 'system', 'content': systemPrompt});
    }
    allMessages.addAll(messages);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': allMessages,
        'max_tokens': 1024,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(
          error['error']?['message'] ?? 'Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['choices'][0]['message']['content'] as String;
  }

  Future<String> generateRecipe({
    required String drinkName,
    required String drinkType,
    String? additionalNotes,
  }) async {
    final prompt = '''Create a detailed recipe for a $drinkType called "$drinkName".
${additionalNotes != null ? 'Additional notes: $additionalNotes' : ''}

Please provide:
1. A brief description (1-2 sentences)
2. Ingredients list with measurements
3. Step-by-step preparation instructions
4. Serving suggestion

Format your response clearly with sections.''';

    return chat(
      messages: [
        {'role': 'user', 'content': prompt}
      ],
      systemPrompt:
          'You are an expert mixologist and bartender with years of experience creating cocktails and mocktails. Provide detailed, professional recipes.',
    );
  }

  Future<String> customerChatResponse({
    required List<Map<String, String>> conversationHistory,
    required String latestMessage,
  }) async {
    final messages = List<Map<String, String>>.from(conversationHistory);
    messages.add({'role': 'user', 'content': latestMessage});

    return chat(
      messages: messages,
      systemPrompt:
          '''You are an AI bartender assistant for a premium bar. Your role is to:
- Help customers discover cocktails and mocktails they might enjoy
- Suggest drinks based on their preferences, mood, or occasion
- Describe flavor profiles, ingredients, and what makes each drink special
- Answer questions about any drink on the menu
- Be friendly, knowledgeable, and enthusiastic about beverages
- If a customer wants to request a specific or custom drink, encourage them to use the Request tab

Keep responses concise and engaging. You are the friendly face of the bar!''',
    );
  }

  Future<String> suggestDrinkName({
    required String recipeContent,
    required String drinkType,
  }) async {
    return chat(
      messages: [
        {
          'role': 'user',
          'content':
              'Based on this $drinkType recipe, suggest ONE short, creative and catchy drink name. Respond with ONLY the name — no explanation, no quotes, no punctuation at the end:\n\n$recipeContent',
        }
      ],
      systemPrompt:
          'You are a creative mixologist. Suggest memorable, evocative drink names. Keep it under 5 words.',
    );
  }

  Future<String> bartenderAssistResponse({
    required List<Map<String, String>> conversationHistory,
    required String latestMessage,
  }) async {
    final messages = List<Map<String, String>>.from(conversationHistory);
    messages.add({'role': 'user', 'content': latestMessage});

    return chat(
      messages: messages,
      systemPrompt:
          '''You are an AI assistant for professional bartenders. Your role is to:
- Generate creative cocktail and mocktail recipes
- Suggest ingredient substitutions
- Help with drink presentation and garnish ideas
- Provide guidance on flavor pairing and balance
- Help curate menus for different occasions
- Suggest trending drinks or classic variations

When creating recipes, be specific about quantities, techniques, and presentation.
Format recipes clearly with: Description, Ingredients (with measurements), Method, and Garnish.''',
    );
  }
}
