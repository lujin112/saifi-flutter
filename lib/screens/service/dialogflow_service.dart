import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:uuid/uuid.dart';

class DialogflowService {
  final String projectId = "saifibot-sxso";

  // كل مستخدم له session خاص
  final String sessionId = const Uuid().v4();

  Future<AutoRefreshingAuthClient> _getClient() async {
    // تحميل service account من assets
    final jsonString = await rootBundle.loadString('assets/saifibot.json');
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonMap);

    // السكوبات المطلوبة
    final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

    return await clientViaServiceAccount(accountCredentials, scopes);
  }

  Future<String> sendMessage(String text, {String lang = "ar"}) async {
    final client = await _getClient();

    final url = Uri.parse(
      "https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent",
    );

    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "queryInput": {
          "text": {
            "text": text,
            "languageCode": lang,
          }
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["queryResult"]["fulfillmentText"] ?? "مافي رد";
    } else {
      return "خطأ من Dialogflow: ${response.body}";
    }
  }
}
