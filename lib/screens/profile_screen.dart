import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_manager.dart';
import '../core/widgets/base_screen.dart';
import '../core/widgets/bottom_navigation.dart';
import 'settings_screen.dart';
import 'landing_screen.dart';

/// Screen for displaying and managing player profile information.
/// 
/// This screen shows the player's avatar, username, gender, email, level, XP,
/// and other profile details. It also provides navigation to settings for
/// updating profile information.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const ProfileScreen(),
///   ),
/// );
/// ```
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Account? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  /// Loads the current account from the account manager
  void _loadAccount() {
    setState(() {
      _account = AccountManager.instance.currentAccount;
      _isLoading = false;
    });
  }

  /// Navigates to the settings screen for profile editing
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    ).then((_) {
      // Refresh account data when returning from settings
      _loadAccount();
    });
  }

  /// Logs out the current user and returns to landing screen
  Future<void> _logout() async {
    // Show confirmation dialog
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Clear current account
      await AccountManager.instance.clearCurrentAccount();
      
      // Navigate to landing screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LandingScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  /// Builds the avatar display widget
  Widget _buildAvatarDisplay() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.shade300,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _account?.avatar != null && _account!.avatar!.isNotEmpty
            ? Image.network(
                _account!.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              )
            : _buildDefaultAvatar(),
      ),
    );
  }

  /// Builds the default avatar when no avatar URL is provided
  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400,
            Colors.blue.shade400,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the profile information section
  Widget _buildProfileInfo() {
    if (_account == null) {
      return Card(
        elevation: 4,
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.person_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(height: 8),
              Text(
                'No Account Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Profile Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Username', _account!.username, Icons.person_outline),
            const SizedBox(height: 8),
            _buildInfoRow('Email', _account!.email, Icons.email),
            const SizedBox(height: 8),
            _buildInfoRow('Gender', _account!.gender, Icons.person),
            const SizedBox(height: 8),
            _buildInfoRow('Character Name', _account!.player.name, Icons.face),
            const SizedBox(height: 8),
            _buildInfoRow('Level', '${_account!.player.level}', Icons.star),
            const SizedBox(height: 8),
            _buildInfoRow('XP', '${_account!.player.xp}/${_account!.player.xpToNextLevel}', Icons.trending_up),
            const SizedBox(height: 8),
            _buildInfoRow('Account Created', _formatDate(_account!.createdAt), Icons.calendar_today),
            const SizedBox(height: 8),
            _buildInfoRow('Last Login', _formatDate(_account!.lastLoginAt), Icons.login),
          ],
        ),
      ),
    );
  }

  /// Builds a single information row
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the player stats section
  Widget _buildPlayerStats() {
    if (_account == null) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Player Statistics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'HP',
                    '${_account!.player.currentHp}/${_account!.player.maxHp}',
                    Colors.red,
                    Icons.favorite,
                    _account!.player.hpPercentage,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Chakra',
                    '${_account!.player.currentChakra}/${_account!.player.maxChakra}',
                    Colors.blue,
                    Icons.bolt,
                    _account!.player.chakraPercentage,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Strength',
                    '${_account!.player.strength}',
                    Colors.orange,
                    Icons.fitness_center,
                    1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Defense',
                    '${_account!.player.defense}',
                    Colors.purple,
                    Icons.shield,
                    1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Jutsu',
                    '${_account!.player.availableJutsu.length}',
                    Colors.teal,
                    Icons.auto_awesome,
                    1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Items',
                    '${_account!.player.inventory.length}',
                    Colors.indigo,
                    Icons.inventory,
                    1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stat card widget
  Widget _buildStatCard(String label, String value, Color color, IconData icon, double percentage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (percentage < 1.0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: color.withOpacity(0.4),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Profile',
      isLoading: _isLoading,
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: _openSettings,
          tooltip: 'Edit Profile',
        ),
      ],
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar display
                  Center(
                    child: _buildAvatarDisplay(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Profile information
                  _buildProfileInfo(),
                  const SizedBox(height: 16),
                  
                  // Player statistics
                  _buildPlayerStats(),
                  const SizedBox(height: 16),
                  
                  // Edit profile button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom navigation
          BottomNavigation(currentRoute: '/profile'),
        ],
      ),
    );
  }
}
