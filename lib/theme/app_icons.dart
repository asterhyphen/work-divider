import 'package:flutter/material.dart';

/// Central icon mapping for app-specific concepts.
class AppIcons {
  const AppIcons._();

  static const Map<String, IconData> tasks = {
    'Main Bathroom': Icons.bathtub_rounded,
    'Other Bathroom': Icons.shower_rounded,
    'Big Hall': Icons.meeting_room_rounded,
    'Side Hall': Icons.door_front_door_rounded,
    'Kitchen': Icons.soup_kitchen_rounded,
    'Outside 1': Icons.yard_rounded,
    'Outside 2': Icons.workspace_premium_rounded,
  };

  static const List<IconData> users = [
    Icons.person_rounded,
    Icons.badge_rounded,
    Icons.school_rounded,
    Icons.palette_rounded,
    Icons.handyman_rounded,
    Icons.code_rounded,
    Icons.restaurant_rounded,
  ];

  static IconData task(String name) => tasks[name] ?? Icons.task_alt_rounded;

  static IconData user(int index) => users[index % users.length];
}
