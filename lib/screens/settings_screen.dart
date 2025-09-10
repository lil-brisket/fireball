import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/account.dart';
import '../services/player_data_manager.dart';
import '../services/account_manager.dart';
import '../services/theme_manager.dart';
import '../core/widgets/base_screen.dart';
import '../core/widgets/bottom_navigation.dart';
import 'landing_screen.dart';

/// A screen that displays game settings and account management options.
/// 
/// This screen allows players to adjust game settings, manage their account,
/// and access various game options.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const SettingsScreen(),
///   ),
/// );
/// ```
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Player? _player;
  Account? _account;
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  String _selectedTheme = 'Auto';
  
  // Avatar management
  final TextEditingController _avatarUrlController = TextEditingController();
  bool _isAvatarLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
    _loadAccount();
    _loadSettings();
  }

  @override
  void dispose() {
    _avatarUrlController.dispose();
    super.dispose();
  }

  /// Loads the current player from the data manager
  void _loadPlayer() {
    setState(() {
      _player = PlayerDataManager.instance.currentPlayer;
    });
  }

  /// Loads the current account from the account manager
  void _loadAccount() {
    setState(() {
      _account = AccountManager.instance.currentAccount;
      if (_account != null) {
        _avatarUrlController.text = _account!.avatar ?? '';
      }
    });
  }

  /// Loads saved settings from theme manager
  void _loadSettings() {
    final themeManager = ThemeManager.instance;
    setState(() {
      _soundEnabled = true;
      _musicEnabled = true;
      _notificationsEnabled = true;
      _soundVolume = 0.8;
      _musicVolume = 0.6;
      _selectedTheme = themeManager.currentThemeModeString;
    });
  }

  /// Saves settings (placeholder for now)
  void _saveSettings() {
    // In a real implementation, this would save to persistent storage
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Changes the app theme and saves the setting
  Future<void> _changeTheme(String themeString) async {
    final themeManager = ThemeManager.instance;
    await themeManager.setThemeModeFromString(themeString);
    
    setState(() {
      _selectedTheme = themeString;
    });

    // Show feedback to user
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Theme changed to $themeString'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Saves the avatar URL to the account
  Future<void> _saveAvatar() async {
    if (_account == null) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      final updatedAccount = _account!.copyWith(
        avatar: _avatarUrlController.text.trim().isEmpty ? null : _avatarUrlController.text.trim(),
      );
      
      await AccountManager.instance.updateAccount(updatedAccount);
      
      setState(() {
        _account = updatedAccount;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAvatarLoading = false;
      });
    }
  }

  /// Handles account logout
  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? Your progress will be saved automatically.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Save current progress before logout
        await PlayerDataManager.instance.saveCurrentPlayer();
        
        // Clear current account from AccountManager
        final accountManager = AccountManager.instance;
        await accountManager.clearCurrentAccount();
        
        // Navigate back to landing screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LandingScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Handles account deletion
  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account? This action cannot be undone and will permanently delete all progress.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final accountManager = AccountManager.instance;
        if (_player != null) {
          await accountManager.deleteAccount(_player!.id);
        }
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LandingScreen(),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Debug method to clear all accounts
  Future<void> _clearAllAccounts() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Accounts'),
        content: const Text(
          'This will permanently delete ALL accounts. This is for testing purposes only. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AccountManager.instance.clearAllAccounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All accounts cleared'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to landing screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/',
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear accounts: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Debug method to refresh database
  Future<void> _refreshDatabase() async {
    try {
      await AccountManager.instance.refreshDatabase();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh database: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Debug method to test account persistence
  Future<void> _testAccountPersistence() async {
    try {
      final accountManager = AccountManager.instance;
      
      // Create a test account
      final testAccount = await accountManager.createAccount(
        username: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        password: 'test123',
        email: 'test@example.com',
        gender: 'Male',
        playerName: 'Test Player',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test account created: ${testAccount.username}'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Wait a moment
      await Future.delayed(const Duration(seconds: 1));
      
      // Check if account still exists
      final accounts = await accountManager.getAllAccounts();
      final found = accounts.any((account) => account.id == testAccount.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account persistence test: ${found ? "PASSED" : "FAILED"}'),
            backgroundColor: found ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Builds the avatar management section
  Widget _buildAvatarManagement() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.face, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Avatar Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Avatar preview
            Center(
              child: Container(
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
                  child: _avatarUrlController.text.isNotEmpty
                      ? Image.network(
                          _avatarUrlController.text,
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
              ),
            ),
            const SizedBox(height: 16),
            
            // Avatar URL input
            TextFormField(
              controller: _avatarUrlController,
              decoration: InputDecoration(
                labelText: 'Avatar URL',
                hintText: 'Enter image URL for your avatar',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            
            // Save avatar button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAvatarLoading ? null : _saveAvatar,
                icon: _isAvatarLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isAvatarLoading ? 'Saving...' : 'Save Avatar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
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
      child: const Center(
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the player info section
  Widget _buildPlayerInfo() {
    if (_player == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: Text('No player data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
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
                  'Player Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('Name', _player!.name),
                ),
                Expanded(
                  child: _buildInfoItem('Level', '${_player!.level}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('HP', '${_player!.currentHp}/${_player!.maxHp}'),
                ),
                Expanded(
                  child: _buildInfoItem('Chakra', '${_player!.currentChakra}/${_player!.maxChakra}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem('XP', '${_player!.xp}/${_player!.xpToNextLevel}'),
                ),
                Expanded(
                  child: _buildInfoItem('Items', '${_player!.inventory.length}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an info item widget
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds the audio settings section
  Widget _buildAudioSettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Audio Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Enable sound effects'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Background Music'),
              subtitle: const Text('Enable background music'),
              value: _musicEnabled,
              onChanged: (value) {
                setState(() {
                  _musicEnabled = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable push notifications'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Sound Volume',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _soundVolume,
              onChanged: _soundEnabled ? (value) {
                setState(() {
                  _soundVolume = value;
                });
              } : null,
              activeColor: Colors.orange,
            ),
            Text(
              'Music Volume',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: _musicVolume,
              onChanged: _musicEnabled ? (value) {
                setState(() {
                  _musicVolume = value;
                });
              } : null,
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the display settings section
  Widget _buildDisplaySettings() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Display Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Theme'),
              subtitle: Text('Current: $_selectedTheme'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Select Theme'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: const Text('Light'),
                          value: 'Light',
                          groupValue: _selectedTheme,
                          onChanged: (value) async {
                            await _changeTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Dark'),
                          value: 'Dark',
                          groupValue: _selectedTheme,
                          onChanged: (value) async {
                            await _changeTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Auto'),
                          value: 'Auto',
                          groupValue: _selectedTheme,
                          onChanged: (value) async {
                            await _changeTheme(value!);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the account management section
  Widget _buildAccountManagement() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Account Management',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.save, color: Colors.green),
              title: const Text('Save Progress'),
              subtitle: const Text('Manually save your current progress'),
              onTap: () async {
                try {
                  await PlayerDataManager.instance.saveCurrentPlayer();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progress saved successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            // Debug section
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.purple),
              title: const Text('Debug: Clear All Accounts'),
              subtitle: const Text('Clear all saved accounts (for testing)'),
              onTap: _clearAllAccounts,
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.blue),
              title: const Text('Debug: Refresh Database'),
              subtitle: const Text('Refresh database connection'),
              onTap: _refreshDatabase,
            ),
            ListTile(
              leading: const Icon(Icons.science, color: Colors.orange),
              title: const Text('Debug: Test Persistence'),
              subtitle: const Text('Test if accounts persist in storage'),
              onTap: _testAccountPersistence,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.orange),
              title: const Text('Logout'),
              subtitle: const Text('Logout and return to login screen'),
              onTap: _logout,
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently delete this account'),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the about section
  Widget _buildAboutSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: Colors.grey, size: 24),
                const SizedBox(width: 8),
                Text(
                  'About',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Developer'),
              subtitle: const Text('Shinobi RPG Team'),
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help & Support'),
              subtitle: const Text('Get help with the game'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Help & Support'),
                    content: const Text(
                      'For help and support, please contact us at:\n\n'
                      'Email: support@shinobi-rpg.com\n'
                      'Discord: Shinobi RPG Community\n\n'
                      'We\'re here to help with any questions or issues!',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: '🥷 Settings',
      actions: [
        TextButton(
          onPressed: _saveSettings,
          child: Text(
            'Save',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                  _buildAvatarManagement(),
                  const SizedBox(height: 16),
                  _buildPlayerInfo(),
                  const SizedBox(height: 16),
                  _buildAudioSettings(),
                  const SizedBox(height: 16),
                  _buildDisplaySettings(),
                  const SizedBox(height: 16),
                  _buildAccountManagement(),
                  const SizedBox(height: 16),
                  _buildAboutSection(),
                ],
              ),
            ),
          ),
          // Bottom navigation
          BottomNavigation(currentRoute: '/settings'),
        ],
      ),
    );
  }
}
