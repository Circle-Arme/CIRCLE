import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/data/models/user_profile_model.dart';

class SharedPrefs {
  static SharedPreferences? _prefs;

  /// 📦 التهيئة
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// ✅ الوصول إلى SharedPreferences
  static Future<SharedPreferences> prefs() async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------------------------------------
  // 🌐 اللغة
  // ---------------------------------------------
  static Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('language', languageCode);
  }

  static Future<String?> getLanguage() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('language');
  }

  // ---------------------------------------------
  // 🎨 الثيم
  // ---------------------------------------------
  static Future<void> saveTheme(ThemeMode themeMode) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('theme', themeMode.toString());
  }

  static Future<ThemeMode?> getTheme() async {
    final prefs = await SharedPrefs.prefs();
    final themeString = prefs.getString('theme');
    if (themeString == null) return null;
    if (themeString == ThemeMode.light.toString()) return ThemeMode.light;
    if (themeString == ThemeMode.dark.toString()) return ThemeMode.dark;
    return ThemeMode.system;
  }

  // ---------------------------------------------
  // 🔐 التوكنات
  // ---------------------------------------------
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('access_token', token);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('access_token');
  }

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('refresh_token', token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('refresh_token');
  }

  static Future<void> clearAuthTokens() async {
    final prefs = await SharedPrefs.prefs();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_type'); // إزالة userType عند تسجيل الخروج
  }

  // ---------------------------------------------
  // 👤 بيانات المستخدم
  // ---------------------------------------------
  static Future<void> saveUserProfile(UserProfileModel profile) async {
    final prefs = await SharedPrefs.prefs();
    prefs.setString('user_profile', jsonEncode(profile.toJson()));
  }

  static Future<UserProfileModel?> getUserProfile() async {
    final prefs = await SharedPrefs.prefs();
    final jsonString = prefs.getString('user_profile');
    if (jsonString != null) {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserProfileModel.fromJson(json);
    }
    return null;
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPrefs.prefs();
    await prefs.remove('user_profile');
  }

  // ---------------------------------------------
  // 🔒 نوع المستخدم (userType)
  // ---------------------------------------------
  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('user_type', userType);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('user_type');
  }

  // ---------------------------------------------
  // ✅ لحفظ هل ظهرت الرسالة أم لا
  // ---------------------------------------------
  static Future<void> setProfilePromptSeen(bool value) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setBool('hasSeenProfilePrompt', value);
  }

  static Future<bool> hasSeenProfilePrompt() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getBool('hasSeenProfilePrompt') ?? false;
  }

  // ---------------------------------------------
  // 🗺️ حفظ المجال المختار
  // ---------------------------------------------
  static Future<void> saveLastSelectedAreaId(String areaId) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('last_area_id', areaId);
  }

  static Future<String?> getLastSelectedAreaId() async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('last_area_id');
  }

  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // ---------------------------------------------
  // 🔖 حفظ مستوى المستخدم داخل مجتمع معيّن
  // ---------------------------------------------
  static Future<void> saveCommunityLevel(int communityId, String level) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.setString('community_level_$communityId', level);
  }

  static Future<String?> getCommunityLevel(int communityId) async {
    final prefs = await SharedPrefs.prefs();
    return prefs.getString('community_level_$communityId');
  }
  static Future<void> removeCommunityLevel(int communityId) async {
    final prefs = await SharedPrefs.prefs();
    await prefs.remove('community_level_$communityId');
  }
}
