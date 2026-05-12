import 'package:flutter/material.dart';

/// User model for HouseCycle roommates.
class UserModel {
  final String name;
  final IconData icon;

  const UserModel({required this.name, required this.icon});

  static const List<UserModel> allUsers = [
    UserModel(name: 'Asfan', icon: Icons.person_rounded),
    UserModel(name: 'Ahmed', icon: Icons.badge_rounded),
    UserModel(name: 'Ayanuddin', icon: Icons.school_rounded),
    UserModel(name: 'Ayaan', icon: Icons.palette_rounded),
    UserModel(name: 'Amaan', icon: Icons.handyman_rounded),
    UserModel(name: 'Shaaz', icon: Icons.code_rounded),
    UserModel(name: 'Wasiq', icon: Icons.restaurant_rounded),
  ];

  static UserModel getUser(String name) =>
      allUsers.firstWhere((u) => u.name == name);
}
