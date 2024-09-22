import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:my_news/constant.dart';
import 'package:my_news/model/article.dart';

class NewsProvider with ChangeNotifier {
  List<Article> _articles = [];
  List<Article> get articles => _articles;

  String _countryCode = 'us'; // Default country code
  String get countryCode => _countryCode;

  Future<void> fetchNews() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      print('Remote Config instance created');

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ));
      print('Remote Config settings set');

      bool fetchSuccess = await remoteConfig.fetchAndActivate();
      print('Fetch and activate result: $fetchSuccess');

      _countryCode = remoteConfig.getString('country_code');
      print('Country Code from Remote Config: "$_countryCode"');
      print('All Remote Config values: ${remoteConfig.getAll()}');

      if (_countryCode.isEmpty) {
        print('Using fallback country code: us');
        _countryCode = 'us';
      }

      final apiKey = Constants.NEWS_API_KEY;
      final url =
          'https://newsapi.org/v2/top-headlines?country=$_countryCode&apiKey=$apiKey';
      await fetchNewsFromUrl(url);
    } catch (e) {
      print('Error in fetchNews: $e');
      _articles = []; // Clear articles on error
      notifyListeners();
    }
  }

  Future<void> fetchNewsFromUrl(String url) async {
    print('Request URL: $url');

    final response = await http.get(Uri.parse(url));

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData['status'] == 'ok' && jsonData['articles'] != null) {
        _articles = (jsonData['articles'] as List)
            .map((articleJson) => Article.fromJson(articleJson))
            .toList();
        notifyListeners();
      } else {
        throw Exception('Invalid response format: ${jsonData['message']}');
      }
    } else {
      throw Exception(
          'Failed to load news. Status code: ${response.statusCode}');
    }
  }
}
