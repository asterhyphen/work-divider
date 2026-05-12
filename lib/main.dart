import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meowdabattery/theme/app_theme.dart';
import 'package:meowdabattery/providers/app_provider.dart';
import 'package:meowdabattery/screens/user_select_screen.dart';
import 'package:meowdabattery/screens/home_screen.dart';
import 'package:meowdabattery/utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider()..init())],
      child: MaterialApp(
        title: 'HouseCycle',
        theme: AppTheme.darkTheme,
        home: const RootScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

/// Root screen that routes between user select and home screen.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, _) {
        if (appProvider.currentUser == null) {
          return const UserSelectScreen();
        }
        return const HomeScreen();
      },
    );
  }
}
