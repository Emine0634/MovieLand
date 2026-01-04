// lib/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // ---------------------------
  // ARKA PLAN
  // ---------------------------
  static const Color mainBackgroundColor = Color(0xFF050505); // siyah

  // ---------------------------
  // METİN RENKLERİ
  // ---------------------------
  static const Color textColor = Color(0xFFFFFFFF);   // beyaz
  static const Color subtitleColor = Color(0xFFDDDBCB); // bej-gri açıklamalar
  static const Color titleColor = Color(0xFFFFFFFF);   // parlak beyaz başlık

  // ---------------------------
  // INPUT ALANLARI
  // ---------------------------
  static const Color textFieldFillColor = Color(0xFF1B1B1B);
  static const Color textFieldBorderColor = Color(0xFF2A2A2A);

  // ---------------------------
  // BUTONLAR
  // ---------------------------
  static const Color logInButtonColor = Color(0xFF1B9AAA); // turkuaz vurgu rengi
  static const Color buttonTextColor = Color(0xFFFFFFFF);

  // ---------------------------
  // VURGU RENKLERİ
  // ---------------------------
  static const Color accentColor = Color(0xFF1B9AAA);    // turkuaz
  static const Color highlightColor = Color(0xFFF5F1E3); // açık krem

  // ---------------------------
  // NAV BAR
  // ---------------------------
  static const Color bottomNavColor = Color(0xFF050505); // siyah
  static const Color primaryDarkColor = Color(0xFF0E0E0E);
}

// ----------------------------------------
// TMDB GENRE IDS (Kesin Eşleşme için düzenlendi)
// ----------------------------------------
// TMDB API Kategori ID'leri
const Map<String, int> TMDB_GENRES = {
  // Login ekranında kullanılan 9 kategori ID'si
  'Action': 28,
  'Drama': 18,
  'Comedy': 35,
  'Horror': 27,
  'Sci-Fi': 878,
  'Fantasy': 14,
  'Romance': 10749,
  'Thriller': 53,
  'Animation': 16,

};