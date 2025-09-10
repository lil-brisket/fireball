import 'package:flutter/material.dart';
import '../services/account_manager.dart';
import '../services/player_data_manager.dart';
import '../models/account.dart';
import '../core/widgets/base_screen.dart';
import 'register_screen.dart';
import 'main_menu_screen.dart';
import 'landing_screen.dart';

/// Screen for logging into the single existing account.
/// 
/// This screen allows users to:
/// - View the existing account information
/// - Log into the account to continue playing
/// - Navigate back to registration if no account exists
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Account? _account;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Form controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Loads the single existing account
  Future<void> _loadAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      // Refresh database connection to ensure we have latest data
      await accountManager.refreshDatabase();
      
      final accounts = await accountManager.getAllAccounts();
      
      if (accounts.isNotEmpty) {
        // Account exists, pre-fill username
        setState(() {
          _account = accounts.first;
          _usernameController.text = accounts.first.username;
        });
      } else {
        // No account exists, just clear the account
        setState(() {
          _account = null;
        });
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load account: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// Handles login to the single account
  Future<void> _loginToAccount() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Ensure database connection is fresh before validating credentials
      await accountManager.refreshDatabase();

      // Validate credentials
      final account = await accountManager.validateCredentials(username, password);
      
      if (account == null) {
        setState(() {
          _errorMessage = 'Invalid username or password. Please check your credentials.';
          _isLoggingIn = false;
        });
        return;
      }

      final playerDataManager = PlayerDataManager.instance;

      // Ensure PlayerDataManager is initialized
      if (!playerDataManager.isInitialized) {
        await playerDataManager.initialize();
      }

      // Switch to the account
      await accountManager.switchToAccount(account.id);
      print('DEBUG: Login - Switched to account: ${account.id}');

      // Update the player data manager with the account's player
      await playerDataManager.updatePlayer(account.player, autoSave: false);
      print('DEBUG: Login - Updated PlayerDataManager with player: ${account.player.name}');
      print('DEBUG: Login - PlayerDataManager currentPlayer: ${playerDataManager.currentPlayer?.name}');

      // Navigate to the main menu screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainMenuScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to login: ${e.toString()}';
        _isLoggingIn = false;
      });
    }
  }

  /// Navigates to the register screen
  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  /// Debug method to check account information
  Future<void> _debugAccountInfo() async {
    try {
      final accountManager = AccountManager.instance;
      final accounts = await accountManager.getAllAccounts();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Account Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total accounts: ${accounts.length}'),
              const SizedBox(height: 8),
              if (accounts.isNotEmpty) ...[
                const Text('Accounts:'),
                const SizedBox(height: 4),
                ...accounts.map((account) => Text('• ${account.username} (${account.id})')),
              ] else
                const Text('No accounts found'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Error'),
          content: Text('Error: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  /// Formats the last login time
  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Header
                    _buildHeader(),
                    
                    const SizedBox(height: 40),
                    
                    // Error message
                    if (_errorMessage != null) _buildErrorMessage(),
                    
                    // Login form
                    _buildLoginForm(),
                    
                    const SizedBox(height: 20),
                    
                    // Account info (if exists)
                    if (_account != null) _buildAccountInfoCard(_account!),
                  ],
                ),
              ),
      ),
    );
  }

  /// Builds the header section
  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Enter Your Login',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your username and password',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds the error message
  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red[800], fontSize: 14),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[600], size: 20),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  /// Builds the login form
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username field
          _buildInputField(
            controller: _usernameController,
            label: 'Username',
            hint: 'Enter your username',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Password field
          _buildInputField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 30),
          
          // Login button
          _buildLoginButton(),
          
          const SizedBox(height: 16),
          
          // Register button (if no account exists)
          if (_account == null) _buildRegisterButton(),
          
          const SizedBox(height: 16),
          
          // Debug button (temporary)
          _buildDebugButton(),
        ],
      ),
    );
  }

  /// Builds a styled input field
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.purple[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(
            color: Colors.purple[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        validator: validator,
      ),
    );
  }

  /// Builds the login button
  Widget _buildLoginButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoggingIn ? null : _loginToAccount,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoggingIn
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login to Game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// Builds the register button
  Widget _buildRegisterButton() {
    return Container(
      height: 48,
      child: ElevatedButton(
        onPressed: _goToRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Go to Register',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds the debug button
  Widget _buildDebugButton() {
    return Container(
      height: 40,
      child: ElevatedButton(
        onPressed: _debugAccountInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Debug Account Info',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds an account info card
  Widget _buildAccountInfoCard(Account account) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.purple[600],
                child: Text(
                  account.displayName.isNotEmpty 
                      ? account.displayName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${account.username}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Player: ${account.player.name}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level ${account.player.level}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'HP: ${account.player.currentHp}/${account.player.maxHp}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Chakra: ${account.player.currentChakra}/${account.player.maxChakra}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Last login: ${_formatLastLogin(account.lastLoginAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
