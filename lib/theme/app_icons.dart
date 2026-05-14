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
    Icons.pets_rounded,
    Icons.pets_outlined,
    Icons.pets_sharp,
    Icons.emoji_nature_rounded,
    Icons.face_rounded,
    Icons.mood_rounded,
    Icons.favorite_rounded,
  ];

  static IconData task(String name) => tasks[name] ?? Icons.task_alt_rounded;

  static IconData user(int index) => users[index % users.length];
}
