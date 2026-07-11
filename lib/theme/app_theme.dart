import 'package:flutter/material.dart';

class CoverColorOption {
  final String name;
  final String value;
  const CoverColorOption(this.name, this.value);
}

// 1. 수첩 표지 색상 리스트 (종이 질감)
const List<CoverColorOption> PATTERN_OPTIONS = [
  CoverColorOption('흰 수첩 🤍', '#FFFFFF'),
  CoverColorOption('딸기 솜사탕 🌸', '#FFF0F2'),
  CoverColorOption('바나나 크림 🍌', '#FFFDF0'),
  CoverColorOption('민트 초코 🌿', '#F0FFF7'),
  CoverColorOption('갱지 느낌 🤎', '#F4F2EE'),
];

// 2. 대표 스티커 이모지 리스트
const List<String> EMOJI_OPTIONS = [
  '✈️', '🌴', '🍵', '🌊', '🏕️', '🎡', '🍣', '🌸', '☕', '🏡', '🗺️', '📸'
];

// 3. 노트 및 스프링 수치 상수 모음 (디자이너 조정용)
class AppThemeConstants {
  static const double notebookLineSpacing = 36.0;   // 줄선 공책 줄 간격
  static const double binderLoopHeight = 14.0;      // 스프링 고리 높이
  static const double binderLoopWidth = 8.0;        // 스프링 고리 두께
  static const int binderLoopCount = 9;             // 스프링 고리 개수
}

// 4. 구글 폰트 호출을 어비 마이센체(UhBeeMysen)로 연동해 주는 모조 어댑터 클래스
class GoogleFonts {
  static TextStyle gaegu({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: 'UhBeeMysen',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }
}
