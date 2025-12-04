class MealTypes {
  static const String breakfast = 'breakfast';
  static const String lunch = 'lunch';
  static const String dinner = 'dinner';

  static const List<String> values = [breakfast, lunch, dinner];

  static String translate(String type) {
    switch (type) {
      case breakfast: return 'Café da Manhã';
      case lunch: return 'Almoço';
      case dinner: return 'Jantar';
      default: return type;
    }
  }
}