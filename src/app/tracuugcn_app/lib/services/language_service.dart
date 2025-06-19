import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  
  Locale _locale = const Locale('vi', 'VN'); // Default to Vietnamese
  
  Locale get locale => _locale;
  
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? 'vi';
    _locale = Locale(languageCode, languageCode == 'vi' ? 'VN' : 'US');
    notifyListeners();
  }
  
  Future<void> setLanguage(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    notifyListeners();
  }
  
  bool get isVietnamese => _locale.languageCode == 'vi';
  bool get isEnglish => _locale.languageCode == 'en';
}
