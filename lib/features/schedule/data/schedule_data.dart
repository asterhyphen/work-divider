// All hardcoded schedule data for HouseCycle.
// Ahmed is the hardcoded admin. Outside 2 follows the weekly schedule.
// Main Bathroom rotates ONLY: Amaan, Ahmed, Shaaz, Ayanuddin
// Other Bathroom rotates ONLY: Wasiq, Asfan, Ayaan

class ScheduleData {
  static const int anchorWeek = 2;
  static final DateTime anchorMonday = DateTime(2026, 5, 18);
  static const String adminUser = 'Ahmed';

  static const List<String> allUsers = [
    'Asfan',
    'Ahmed',
    'Ayanuddin',
    'Ayaan',
    'Amaan',
    'Shaaz',
    'Wasiq',
  ];

  static const List<String> taskNames = [
    'Main Bathroom',
    'Other Bathroom',
    'Big Hall',
    'Side Hall',
    'Kitchen',
    'Outside 1',
    'Outside 2',
  ];

  static const Map<String, String> passwords = {
    'Asfan': 'asfan@house',
    'Ahmed': 'aster@herheart',
    'Ayanuddin': 'ayanuddin@house',
    'Ayaan': 'ayaan@house',
    'Amaan': 'amaan@house',
    'Shaaz': 'shaaz@house',
    'Wasiq': 'wasiq@house',
  };

  static const Map<String, String> completionMessages = {
    'Main Bathroom': 'Bathroom survived another war.',
    'Other Bathroom': 'Fresh and clean. Victory!',
    'Big Hall': 'Hall shining like moonlight.',
    'Side Hall': 'Side hall? More like SHINE hall.',
    'Kitchen': 'Kitchen conquered.',
    'Outside 1': 'The great outdoors cleaned.',
    'Outside 2': 'Leading AND cleaning. Respect.',
  };

  /// Each week: the `leader` field is the Outside 2 assignment.
  static const List<Map<String, String>> weeklySchedules = [
    // Week 1
    {
      'leader': 'Ayaan',
      'Main Bathroom': 'Amaan',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Ahmed',
      'Side Hall': 'Shaaz',
      'Kitchen': 'Ayanuddin',
      'Outside 1': 'Asfan',
    },
    // Week 2
    {
      'leader': 'Wasiq',
      'Main Bathroom': 'Ahmed',
      'Other Bathroom': 'Asfan',
      'Big Hall': 'Shaaz',
      'Side Hall': 'Ayanuddin',
      'Kitchen': 'Amaan',
      'Outside 1': 'Ayaan',
    },
    // Week 3
    {
      'leader': 'Asfan',
      'Main Bathroom': 'Shaaz',
      'Other Bathroom': 'Ayaan',
      'Big Hall': 'Ayanuddin',
      'Side Hall': 'Amaan',
      'Kitchen': 'Ahmed',
      'Outside 1': 'Wasiq',
    },
    // Week 4
    {
      'leader': 'Ayanuddin',
      'Main Bathroom': 'Ayanuddin',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Amaan',
      'Side Hall': 'Ahmed',
      'Kitchen': 'Shaaz',
      'Outside 1': 'Asfan',
    },
    // Week 5
    {
      'leader': 'Ahmed',
      'Main Bathroom': 'Amaan',
      'Other Bathroom': 'Asfan',
      'Big Hall': 'Ahmed',
      'Side Hall': 'Shaaz',
      'Kitchen': 'Ayanuddin',
      'Outside 1': 'Ayaan',
    },
    // Week 6
    {
      'leader': 'Shaaz',
      'Main Bathroom': 'Ahmed',
      'Other Bathroom': 'Ayaan',
      'Big Hall': 'Shaaz',
      'Side Hall': 'Ayanuddin',
      'Kitchen': 'Amaan',
      'Outside 1': 'Wasiq',
    },
    // Week 7
    {
      'leader': 'Amaan',
      'Main Bathroom': 'Shaaz',
      'Other Bathroom': 'Wasiq',
      'Big Hall': 'Ayanuddin',
      'Side Hall': 'Amaan',
      'Kitchen': 'Ahmed',
      'Outside 1': 'Asfan',
    },
  ];
}
