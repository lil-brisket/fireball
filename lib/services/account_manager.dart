import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/player.dart';
import 'password_service.dart';

/// Manages multiple user accounts and their associated player data.
/// 
/// This singleton service provides:
/// - Account creation and management
/// - Account selection and switching
/// - Local storage of multiple accounts
/// - Account metadata tracking
/// 
/// Example:
/// ```dart
/// final accountManager = AccountManager.instance;
/// await accountManager.initialize();
/// final accounts = await accountManager.getAllAccounts();
/// ```
class AccountManager {
  static final AccountManager _instance = AccountManager._internal();
  factory AccountManager() => _instance;
  AccountManager._internal();

  static AccountManager get instance => _instance;

  static const String _accountsBoxName = 'accounts';
  static const String _currentAccountKey = 'current_account_id';
  
  late Box<Account> _accountsBox;
  late Box<String> _settingsBox;
  bool _isInitialized = false;

  /// The currently active account
  Account? _currentAccount;

  /// Gets the currently active account
  Account? get currentAccount => _currentAccount;

  /// Checks if the manager is initialized
  bool get isInitialized => _isInitialized;

  /// Initializes the account manager and loads saved data
  /// 
  /// This method should be called at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Adapters are now registered centrally in main.dart
      
      // Open the accounts box
      _accountsBox = await Hive.openBox<Account>(_accountsBoxName);
      _settingsBox = await Hive.openBox<String>('account_settings');
      
      print('DEBUG: AccountManager initialized - accounts: ${_accountsBox.length} items');
      print('DEBUG: Box path: ${_accountsBox.path}');
      print('DEBUG: Box isOpen: ${_accountsBox.isOpen}');
      
      // List all keys in the box for debugging
      print('DEBUG: Box keys: ${_accountsBox.keys.toList()}');
      
      // Load the current account if one exists
      await _loadCurrentAccount();
      
      _isInitialized = true;
    } catch (e) {
      print('ERROR: Failed to initialize AccountManager: $e');
      rethrow;
    }
  }

  /// Loads the current account from storage
  Future<void> _loadCurrentAccount() async {
    final currentAccountId = _settingsBox.get(_currentAccountKey);
    if (currentAccountId != null) {
      _currentAccount = _accountsBox.get(currentAccountId);
    }
  }

  /// Creates a new account with a new player
  /// 
  /// [username] - The username for the account
  /// [password] - The password for the account (will be hashed)
  /// [email] - The email for the account
  /// [gender] - The gender for the account
  /// [avatar] - Optional avatar URL
  /// [playerName] - The name for the player character
  /// Returns the created account
  Future<Account> createAccount({
    required String username,
    required String password,
    required String email,
    required String gender,
    String? avatar,
    required String playerName,
  }) async {
    if (!_isInitialized) {
      throw StateError('AccountManager not initialized. Call initialize() first.');
    }

    // Validate password
    final passwordValidation = PasswordService.validatePassword(password);
    if (!passwordValidation.isValid) {
      throw ArgumentError(passwordValidation.message);
    }

    // Check if username already exists
    if (await isUsernameTaken(username)) {
      throw ArgumentError('Username "$username" is already taken');
    }

    // Generate unique account ID
    final accountId = _generateAccountId();
    
    // Create new player
    final player = Player(
      id: '${accountId}_player',
      name: playerName,
    );

    // Hash the password
    final hashedPassword = PasswordService.hashPassword(password);

    // Create new account
    final account = Account(
      id: accountId,
      username: username,
      password: hashedPassword,
      email: email,
      gender: gender,
      avatar: avatar,
      player: player,
    );

    // Save account to storage
    print('DEBUG: About to save account - ID: $accountId, Username: ${account.username}');
    print('DEBUG: Box isOpen before save: ${_accountsBox.isOpen}');
    
    await _accountsBox.put(accountId, account);
    await _accountsBox.flush(); // Ensure data is written to disk
    
    print('DEBUG: Account saved - ID: $accountId, Username: ${account.username}');
    print('DEBUG: Box length after save: ${_accountsBox.length}');
    print('DEBUG: Box keys after save: ${_accountsBox.keys.toList()}');
    print('DEBUG: Box isOpen after save: ${_accountsBox.isOpen}');
    
    // Verify the account was saved
    final savedAccount = _accountsBox.get(accountId);
    print('DEBUG: Account verification - Found: ${savedAccount != null}, Username: ${savedAccount?.username}');
    
    // Try to get all accounts immediately after save
    final allAccounts = _accountsBox.values.toList();
    print('DEBUG: All accounts immediately after save: ${allAccounts.length}');
    for (final acc in allAccounts) {
      print('DEBUG: Found account - ${acc.username} (${acc.id})');
    }
    
    return account;
  }

  /// Checks if a username is already taken
  /// 
  /// [username] - The username to check
  /// Returns true if the username is taken, false otherwise
  Future<bool> isUsernameTaken(String username) async {
    if (!_isInitialized) return false;

    final accounts = _accountsBox.values;
    return accounts.any((account) => account.username.toLowerCase() == username.toLowerCase());
  }

  /// Validates login credentials
  /// 
  /// [username] - The username to validate
  /// [password] - The password to validate
  /// Returns the account if credentials are valid, null otherwise
  Future<Account?> validateCredentials(String username, String password) async {
    if (!_isInitialized) {
      throw StateError('AccountManager not initialized. Call initialize() first.');
    }

    final accounts = _accountsBox.values.toList();
    try {
      final account = accounts.firstWhere(
        (account) => account.username.toLowerCase() == username.toLowerCase(),
      );

      if (PasswordService.verifyPassword(password, account.password)) {
        return account;
      }
    } catch (e) {
      // Account not found
    }

    return null;
  }

  /// Gets all accounts
  /// 
  /// Returns a list of all accounts sorted by last login (most recent first)
  Future<List<Account>> getAllAccounts() async {
    if (!_isInitialized) return [];

    final accounts = _accountsBox.values.toList();
    print('DEBUG: Found ${accounts.length} accounts in database');
    for (final account in accounts) {
      print('DEBUG: Account - ID: ${account.id}, Username: ${account.username}');
    }
    accounts.sort((a, b) => (b.lastLoginAt ?? DateTime.now()).compareTo(a.lastLoginAt ?? DateTime.now()));
    return accounts;
  }

  /// Forces a refresh of the database connection
  /// 
  /// This method can be used to troubleshoot database issues
  Future<void> refreshDatabase() async {
    if (!_isInitialized) return;
    
    print('DEBUG: Refreshing database connection...');
    // Don't close and reopen the box - just check if it's open
    if (!_accountsBox.isOpen) {
      _accountsBox = await Hive.openBox<Account>(_accountsBoxName);
    }
    print('DEBUG: Database refreshed - accounts: ${_accountsBox.length} items');
    print('DEBUG: Box isOpen: ${_accountsBox.isOpen}');
    print('DEBUG: Box keys: ${_accountsBox.keys.toList()}');
    
    // List all accounts for debugging
    final accounts = _accountsBox.values.toList();
    for (final account in accounts) {
      print('DEBUG: Found account - ID: ${account.id}, Username: ${account.username}, Created: ${account.createdAt?.toIso8601String() ?? 'null'}');
    }
  }

  /// Clears all accounts from storage (for testing purposes)
  /// 
  /// WARNING: This will permanently delete all account data
  Future<void> clearAllAccounts() async {
    if (!_isInitialized) return;
    
    print('DEBUG: Clearing all accounts...');
    await _accountsBox.clear();
    await _settingsBox.clear();
    await _accountsBox.flush();
    _currentAccount = null;
    print('DEBUG: All accounts cleared');
  }


  /// Gets an account by ID
  /// 
  /// [accountId] - The account ID to retrieve
  /// Returns the account or null if not found
  Future<Account?> getAccountById(String accountId) async {
    if (!_isInitialized) return null;
    return _accountsBox.get(accountId);
  }

  /// Gets an account by username
  /// 
  /// [username] - The username to search for
  /// Returns the account or null if not found
  Future<Account?> getAccountByUsername(String username) async {
    if (!_isInitialized) return null;

    final accounts = _accountsBox.values;
    try {
      return accounts.firstWhere(
        (account) => account.username.toLowerCase() == username.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Switches to a different account
  /// 
  /// [accountId] - The ID of the account to switch to
  /// Returns true if successful, false otherwise
  Future<bool> switchToAccount(String accountId) async {
    if (!_isInitialized) return false;

    final account = await getAccountById(accountId);
    if (account == null) return false;

    // Update last login time
    final updatedAccount = account.updateLastLogin();
    await _accountsBox.put(accountId, updatedAccount);
    await _accountsBox.flush(); // Ensure data is written to disk

    // Set as current account
    _currentAccount = updatedAccount;
    await _settingsBox.put(_currentAccountKey, accountId);
    await _settingsBox.flush(); // Ensure data is written to disk

    return true;
  }

  /// Updates the current account's player data
  /// 
  /// [player] - The updated player data
  /// Returns true if successful, false otherwise
  Future<bool> updateCurrentAccountPlayer(Player player) async {
    if (!_isInitialized || _currentAccount == null) return false;

    final updatedAccount = _currentAccount!.updatePlayer(player);
    await _accountsBox.put(_currentAccount!.id, updatedAccount);
    _currentAccount = updatedAccount;

    return true;
  }

  /// Updates an account's metadata
  /// 
  /// [account] - The updated account data
  /// Returns true if successful, false otherwise
  Future<bool> updateAccount(Account account) async {
    if (!_isInitialized) return false;

    await _accountsBox.put(account.id, account);
    
    // Update current account if it's the same one
    if (_currentAccount?.id == account.id) {
      _currentAccount = account;
    }

    return true;
  }

  /// Clears the current account (logout)
  /// 
  /// Returns true if successful, false otherwise
  Future<bool> clearCurrentAccount() async {
    if (!_isInitialized) return false;

    _currentAccount = null;
    await _settingsBox.delete(_currentAccountKey);
    print('DEBUG: Current account cleared');
    return true;
  }

  /// Deletes an account
  /// 
  /// [accountId] - The ID of the account to delete
  /// Returns true if successful, false otherwise
  Future<bool> deleteAccount(String accountId) async {
    if (!_isInitialized) return false;

    // Don't allow deleting the current account
    if (_currentAccount?.id == accountId) {
      return false;
    }

    await _accountsBox.delete(accountId);
    return true;
  }

  /// Gets account statistics
  /// 
  /// Returns a map with account statistics
  Future<Map<String, dynamic>> getAccountStats() async {
    if (!_isInitialized) return {};

    final accounts = await getAllAccounts();
    final totalAccounts = accounts.length;
    final activeAccounts = accounts.where((a) => a.isActive).length;
    final totalPlayTime = accounts.fold<Duration>(
      Duration.zero,
      (total, account) => total + DateTime.now().difference(account.createdAt ?? DateTime.now()),
    );

    return {
      'totalAccounts': totalAccounts,
      'activeAccounts': activeAccounts,
      'totalPlayTime': totalPlayTime,
      'averageAccountAge': totalAccounts > 0 ? totalPlayTime.inDays / totalAccounts : 0,
    };
  }

  /// Generates a unique account ID
  /// 
  /// Returns a unique account ID string
  String _generateAccountId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'account_${timestamp}_$random';
  }


  /// Exports account data for backup
  /// 
  /// Returns a map containing all account data
  Future<Map<String, dynamic>> exportAccountData() async {
    if (!_isInitialized) return {};

    final accounts = await getAllAccounts();
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'totalAccounts': accounts.length,
      'accounts': accounts.map((account) => {
        'id': account.id,
        'username': account.username,
        'email': account.email,
        'gender': account.gender,
        'avatar': account.avatar,
        'createdAt': account.createdAt?.toIso8601String() ?? 'null',
        'lastLoginAt': account.lastLoginAt?.toIso8601String() ?? 'null',
        'isActive': account.isActive,
        'player': {
          'id': account.player.id,
          'name': account.player.name,
          'level': account.player.level,
          'xp': account.player.xp,
          'maxHp': account.player.maxHp,
          'currentHp': account.player.currentHp,
          'maxChakra': account.player.maxChakra,
          'currentChakra': account.player.currentChakra,
          'strength': account.player.strength,
          'defense': account.player.defense,
        },
      }).toList(),
    };
  }

  /// Cleans up resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await _accountsBox.close();
      await _settingsBox.close();
      _currentAccount = null;
      _isInitialized = false;
    }
  }
}
