/// Centralized route management for the Shinobi RPG app.
/// 
/// This class provides a centralized location for all route names
/// and navigation logic, making it easier to maintain and update
/// navigation throughout the app.
/// 
/// Example:
/// ```dart
/// Navigator.pushNamed(context, RouteManager.home);
/// ```
class RouteManager {
  // Private constructor to prevent instantiation
  RouteManager._();

  // Main app routes
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String starter = '/starter';
  
  // Main tab routes
  static const String home = '/home';
  static const String villageHub = '/village-hub';
  static const String map = '/map';
  static const String inventory = '/inventory';
  static const String profile = '/profile';
  
  // Village Hub sub-routes
  static const String bank = '/bank';
  static const String shop = '/shop';
  static const String trainingDojo = '/training-dojo';
  static const String battle = '/battle';
  static const String quests = '/quests';
  static const String missions = '/missions';
  
  // Other routes
  static const String settings = '/settings';
  static const String enemySelection = '/enemy-selection';
  
  /// Gets all main tab routes
  static List<String> get mainTabRoutes => [
    home,
    villageHub,
    map,
    inventory,
    profile,
  ];
  
  /// Gets all village hub sub-routes
  static List<String> get villageHubRoutes => [
    bank,
    shop,
    trainingDojo,
    battle,
    quests,
    missions,
  ];
  
  /// Checks if a route is a main tab route
  static bool isMainTabRoute(String route) {
    return mainTabRoutes.contains(route);
  }
  
  /// Checks if a route is a village hub sub-route
  static bool isVillageHubRoute(String route) {
    return villageHubRoutes.contains(route);
  }
  
  /// Gets the tab index for a given route
  static int getTabIndexForRoute(String route) {
    switch (route) {
      case home:
        return 0;
      case villageHub:
        return 1;
      case map:
        return 2;
      case inventory:
        return 3;
      case profile:
        return 4;
      default:
        return 0;
    }
  }
  
  /// Gets the route for a given tab index
  static String getRouteForTabIndex(int index) {
    switch (index) {
      case 0:
        return home;
      case 1:
        return villageHub;
      case 2:
        return map;
      case 3:
        return inventory;
      case 4:
        return profile;
      default:
        return home;
    }
  }
}
