/// User model for HouseCycle roommates.
class UserModel {
  final String name;
  final String emoji;

  const UserModel({required this.name, required this.emoji});

  static const List<UserModel> allUsers = [
    UserModel(name: 'Asfan', emoji: '🧑‍🦱'),
    UserModel(name: 'Ahmed', emoji: '👨‍💼'),
    UserModel(name: 'Ayanuddin', emoji: '👨‍🎓'),
    UserModel(name: 'Ayaan', emoji: '🧑‍🎨'),
    UserModel(name: 'Amaan', emoji: '👨‍🔧'),
    UserModel(name: 'Shaaz', emoji: '👨‍💻'),
    UserModel(name: 'Wasiq', emoji: '🧑‍🍳'),
  ];

  static UserModel getUser(String name) =>
      allUsers.firstWhere((u) => u.name == name);
}
