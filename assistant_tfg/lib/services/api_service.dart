import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_consts.dart';
import '../models/chat_model.dart';

class ApiService {
  // Send Message using ChatGPT API
  static Future<List<ChatModel>> sendMessageGPT({
    required String message,
  }) async {
    try {
      var response = await http.post(
        Uri.parse("$baseURL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": 'gpt-3.5-turbo',
            "messages": [
              {
                "role": "user",
                "content":
                    "Actua como un asistente virtual llamado Jarvis (capaz de oir a través del microfono del dispositivo), no hace falta que te presentes a no ser que te salude o te pregunte, a continuación verás mi promp: $message",
              }
            ]
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

/*
  // Send Message fct
  static Future<List<ChatModel>> sendMessage({
    required String message,
  }) async {
    try {
      var response = await http.post(
        Uri.parse("$baseURL/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": 'gpt-3.5-turbo',
            "prompt": message,
            "max_tokens": 300,
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);

      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse["choices"][index]["text"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }
*/
  static Future<String> sendAudioMessage({required String audioPath}) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.openai.com/v1/audio/transcriptions'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $apiKey',
      });

      request.fields['model'] = 'whisper-1';
      request.files.add(await http.MultipartFile.fromPath('file', audioPath));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      Map jsonResponse = json.decode(responseData);

      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }

      return jsonResponse['text'] ?? '';
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  static Future<String> getRecognisedText(String imagePath, bool byHand) async {
    final bytes = File(imagePath).readAsBytesSync();
    String type = "TEXT_DETECTION";
    if (byHand) {
      type = "DOCUMENT_TEXT_DETECTION";
    }
    String img64 = base64Encode(bytes);
    var url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyD1WNbjRNO-dd93vUgrs_HlJJNtnbbzm7g');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "requests": [
            {
              "image": {"content": img64},
              "features": [
                {"type": type}
              ]
            }
          ]
        },
      ),
    );
    var result = jsonDecode(response.body);

    if (result['error'] != null && result['error']['message'] != null) {
      throw Exception(result['error']['message']);
    }

    if (result['responses'] != null && result['responses'].isNotEmpty) {
      if (result['responses'][0]['textAnnotations'] != null &&
          result['responses'][0]['textAnnotations'].isNotEmpty) {
        return result['responses'][0]['textAnnotations'][0]['description'];
      } else {
        throw Exception('textAnnotations is empty or null');
      }
    } else {
      throw Exception('responses is empty or null');
    }
  }

  static Future<String> getLabelFromImage(String imagePath) async {
    final bytes = File(imagePath).readAsBytesSync();

    String img64 = base64Encode(bytes);
    var url = Uri.parse(
        'https://vision.googleapis.com/v1/images:annotate?key=AIzaSyD1WNbjRNO-dd93vUgrs_HlJJNtnbbzm7g');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(
        {
          "requests": [
            {
              "image": {"content": img64},
              "features": [
                {"type": "LABEL_DETECTION"}
              ]
            }
          ]
        },
      ),
    );
    var result = jsonDecode(response.body);

    if (result['responses'] != null && result['responses'].isNotEmpty) {
      if (result['responses'][0]['labelAnnotations'] != null &&
          result['responses'][0]['labelAnnotations'].isNotEmpty) {
        return result['responses'][0]['labelAnnotations'][0]['description'];
      } else {
        throw Exception('labelAnnotations is empty or null');
      }
    } else {
      throw Exception('responses is empty or null');
    }
  }
}
