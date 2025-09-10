import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/account_manager.dart';
import '../core/widgets/base_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Landing screen for the Shinobi RPG app.
/// 
/// This screen provides the initial entry point for users with options to
/// register or sign in. Registration is restricted to single accounts only.
/// 
/// Features:
/// - Always shows both Register and Sign In buttons
/// - Prevents multiple account registration with alert dialog
/// - Automatically loads existing account on Sign In
/// - Enhanced ninja-themed UI with animations
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const LandingScreen(),
///   ),
/// );
/// ```
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Check for existing accounts
    _checkForExistingAccount();
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  /// Initializes the landing screen and checks for existing accounts
  Future<void> _checkForExistingAccount() async {
    try {
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      final accounts = await accountManager.getAllAccounts();
      
      // Just check if accounts exist, don't auto-navigate
      // Let the user choose whether to register or sign in
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('ERROR: Failed to check for existing accounts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Handles register button tap with single-account check
  void _handleRegister(BuildContext context) async {
    HapticFeedback.lightImpact();
    
    try {
      // Check if an account already exists
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      final accounts = await accountManager.getAllAccounts();
      
      if (accounts.isNotEmpty) {
        // Show alert dialog if account exists
        _showAccountExistsDialog(context);
      } else {
        // Navigate to register screen if no account exists
        _navigateToRegister(context);
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to check existing accounts: $e');
    }
  }

  /// Handles sign in button tap
  void _handleSignIn(BuildContext context) async {
    HapticFeedback.lightImpact();
    
    try {
      // Check if an account exists
      final accountManager = AccountManager.instance;
      
      // Ensure AccountManager is initialized
      if (!accountManager.isInitialized) {
        await accountManager.initialize();
      }
      
      final accounts = await accountManager.getAllAccounts();
      
      if (accounts.isNotEmpty) {
        // Navigate to login screen to let user enter credentials
        _navigateToLogin(context);
      } else {
        // Navigate to login screen if no account exists
        _navigateToLogin(context);
      }
    } catch (e) {
      _showErrorDialog(context, 'Failed to load account: $e');
    }
  }

  /// Navigates to the register screen
  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  /// Navigates to the login screen
  void _navigateToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }


  /// Shows a dialog when user tries to register but account already exists
  void _showAccountExistsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.person,
              color: Colors.deepPurple.shade700,
            ),
            const SizedBox(width: 8),
            const Text('Account Already Exists'),
          ],
        ),
        content: const Text(
          'You already have an account. Please log in to continue your ninja journey.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleSignIn(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  /// Shows an error dialog
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Builds the main app logo/title section with enhanced ninja theming
  Widget _buildAppTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Enhanced animated ninja icon with shimmer effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.indigo.withOpacity(0.6),
                          Colors.purple.withOpacity(0.3),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.6),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shimmer effect
                        AnimatedBuilder(
                          animation: _shimmerAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.0),
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                  stops: [
                                    (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                    _shimmerAnimation.value.clamp(0.0, 1.0),
                                    (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const Icon(
                          Icons.sports_martial_arts,
                          size: 80,
                          color: Colors.indigo,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Enhanced title with gradient text
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.indigo,
                  Colors.purple,
                  Colors.indigo,
                ],
                stops: const [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Text(
                '🥷 Shinobi RPG',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                  letterSpacing: 1.5,
                  fontSize: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'A Naruto-inspired Text-Based MMORPG',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the action buttons section with enhanced styling
  Widget _buildActionButtons() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Always show both buttons
              _buildEnhancedActionButton(
                icon: Icons.person_add_rounded,
                label: 'Register',
                description: 'Create a new ninja character',
                color: Colors.teal,
                gradientColors: [Colors.teal.shade600, Colors.teal.shade400],
                onPressed: () => _handleRegister(context),
              ),
              const SizedBox(height: 20),
              _buildEnhancedActionButton(
                icon: Icons.login_rounded,
                label: 'Sign In',
                description: 'Access your existing character',
                color: Colors.indigo,
                gradientColors: [Colors.indigo.shade600, Colors.indigo.shade400],
                onPressed: () {
                  print('DEBUG: Sign In button pressed - going to login screen');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an enhanced action button with gradient and animations
  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required List<Color> gradientColors,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: gradientColors.first,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the footer section with enhanced game features
  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[50]!,
                  Colors.white,
                  Colors.grey[50]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Game Features',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEnhancedFeatureItem(Icons.flash_on_rounded, 'Turn-Based Combat'),
                    _buildEnhancedFeatureItem(Icons.auto_awesome_rounded, 'Jutsu System'),
                    _buildEnhancedFeatureItem(Icons.inventory_2_rounded, 'Inventory'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Version 1.0.0 • Made with Flutter',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an enhanced feature item in the footer
  Widget _buildEnhancedFeatureItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Shinobi RPG',
      showBackButton: false,
      isLoading: _isLoading,
      body: Column(
        children: [
          // Title section at the top
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppTitle(),
                ],
              ),
            ),
          ),
          // Action buttons at the bottom
          _buildActionButtons(),
          _buildFooter(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

