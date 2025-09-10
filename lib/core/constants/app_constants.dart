/// Application-wide constants for the Shinobi RPG game
/// 
/// This file contains all the constants used throughout the app
/// to ensure consistency and easy maintenance.

class AppConstants {
  // App Information
  static const String appName = 'Shinobi RPG';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A Naruto-inspired text-based MMORPG';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 48.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Game Constants
  static const int maxPlayerLevel = 100;
  static const int maxStatValue = 250000; // 250k for core stats
  static const int maxCombatStatValue = 500000; // 500k for combat stats
  static const int baseHp = 100;
  static const int baseChakra = 50;
  static const int jutsuMasteryNormal = 10;
  static const int jutsuMasteryBloodline = 15;

  // Routes (for consistent navigation)
  static const String routeLanding = '/landing';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeMainMenu = '/main_menu';
  static const String routeVillageHub = '/village-hub';
  static const String routeMap = '/map';
  static const String routeInventory = '/inventory';
  static const String routeProfile = '/profile';
  static const String routeBattle = '/battle';
  static const String routeShop = '/shop';
  static const String routeBank = '/bank';
  static const String routeTraining = '/training';
  static const String routeQuests = '/quests';
  static const String routeMissions = '/missions';

  // Error Messages
  static const String errorGeneric = 'An unexpected error occurred. Please try again.';
  static const String errorNetwork = 'Network error. Please check your connection.';
  static const String errorLogin = 'Invalid username or password.';
  static const String errorAccountExists = 'An account already exists. Only one account is allowed.';
  static const String errorPlayerNotFound = 'Player data not found.';
  static const String errorInsufficientFunds = 'Insufficient funds for this action.';
  static const String errorInvalidInput = 'Please check your input and try again.';

  // Success Messages
  static const String successLogin = 'Login successful!';
  static const String successRegister = 'Account created successfully!';
  static const String successSave = 'Progress saved successfully!';
  static const String successPurchase = 'Purchase completed successfully!';
  static const String successMissionComplete = 'Mission completed!';

  // Loading Messages
  static const String loadingAccount = 'Loading account...';
  static const String loadingPlayer = 'Loading player data...';
  static const String loadingBattle = 'Preparing for battle...';
  static const String savingProgress = 'Saving progress...';

  // Emoji Constants (for consistent theming)
  static const String emojiNinja = '🥷';
  static const String emojiVillage = '🏘️';
  static const String emojiMap = '🗺️';
  static const String emojiBattle = '⚔️';
  static const String emojiShop = '🏪';
  static const String emojiBank = '🏦';
  static const String emojiQuest = '📜';
  static const String emojiMission = '🎯';
  static const String emojiTraining = '💪';
  static const String emojiInventory = '🎒';
  static const String emojiProfile = '👤';
  static const String emojiMoney = '💰';
  static const String emojiExp = '✨';
  static const String emojiHp = '❤️';
  static const String emojiChakra = '💙';

  // Prevent instantiation
  const AppConstants._();
}
