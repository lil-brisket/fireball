import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/landing_screen.dart';
import 'services/player_data_manager.dart';
import 'services/account_manager.dart';
import 'services/theme_manager.dart';
import 'models/account.dart';
import 'models/player.dart';
import 'models/item.dart';
import 'models/jutsu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive with custom path for persistence
    await Hive.initFlutter();
    print('DEBUG: Hive initialized');
    
    // Register all Hive adapters in one place to avoid conflicts
    print('DEBUG: Registering Hive adapters...');
    Hive.registerAdapter(ItemTypeAdapter());
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(InventoryEntryAdapter());
    Hive.registerAdapter(JutsuTypeAdapter());
    Hive.registerAdapter(JutsuAdapter());
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(AccountAdapter());
    print('DEBUG: All adapters registered');
    
    // Initialize services in order
    print('DEBUG: Initializing AccountManager...');
    await AccountManager.instance.initialize();
    print('DEBUG: AccountManager initialized');
    
    print('DEBUG: Initializing PlayerDataManager...');
    await PlayerDataManager.instance.initialize();
    print('DEBUG: PlayerDataManager initialized');
    
    print('DEBUG: Initializing ThemeManager...');
    await ThemeManager.instance.initialize();
    print('DEBUG: ThemeManager initialized');
    
    print('DEBUG: All services initialized, starting app...');
    runApp(const ShinobiRPGApp());
  } catch (e, stackTrace) {
    print('ERROR: Failed to initialize app: $e');
    print('STACK TRACE: $stackTrace');
    // Run app anyway to show error screen
    runApp(const ShinobiRPGApp());
  }
}

class ShinobiRPGApp extends StatefulWidget {
  const ShinobiRPGApp({super.key});

  @override
  State<ShinobiRPGApp> createState() => _ShinobiRPGAppState();
}

class _ShinobiRPGAppState extends State<ShinobiRPGApp> {
  @override
  Widget build(BuildContext context) {
    final themeManager = ThemeManager.instance;
    
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeManager.themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Shinobi RPG',
          theme: themeManager.lightTheme,
          darkTheme: themeManager.darkTheme,
          themeMode: themeMode,
          home: const LandingScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}


