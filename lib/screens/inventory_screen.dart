import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/item.dart';
import '../services/player_data_manager.dart';
import '../services/mission_manager.dart';
import '../core/widgets/bottom_navigation.dart';

/// A screen that displays the player's inventory and allows item management.
/// 
/// This screen shows all items in the player's inventory with quantities,
/// allows using items, and automatically saves progress after changes.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => InventoryScreen(),
///   ),
/// );
/// ```
class InventoryScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showBottomNavigation;
  
  const InventoryScreen({
    super.key,
    this.showAppBar = true,
    this.showBottomNavigation = true,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  Player? _player;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  /// Loads the current player from the data manager
  void _loadPlayer() {
    setState(() {
      _player = PlayerDataManager.instance.currentPlayer;
    });
  }

  /// Uses an item from the inventory
  /// 
  /// [itemName] - The name of the item to use
  Future<void> _useItem(String itemName) async {
    if (_player == null) return;

    final success = _player!.useItem(itemName);
    
    if (success) {
      setState(() {});
      // Save inventory progress after using an item
      await PlayerDataManager.instance.saveInventoryProgress();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Used $itemName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to use $itemName'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Adds a test item to the inventory for demonstration
  Future<void> _addTestItem() async {
    if (_player == null) return;

    // Add a random test item
    final testItems = [
      Item.healingPotion(),
      Item.chakraPotion(),
      Item.attackBuff(),
      Item.defenseBuff(),
    ];
    
    final randomItem = testItems[DateTime.now().millisecondsSinceEpoch % testItems.length];
    _player!.addItem(randomItem);
    
    // Update mission progress for collection missions
    MissionManager.instance.updateMissionProgress('item_collected', eventData: {
      'item_name': randomItem.name,
      'item_type': randomItem.type.toString(),
    });
    
    setState(() {});
    
    // Save inventory progress after adding an item
    await PlayerDataManager.instance.saveInventoryProgress();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${randomItem.name} to inventory'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  /// Builds the player stats display
  Widget _buildPlayerStats() {
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
                  _player!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Text(
                    'Level ${_player!.level}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay(
                    'HP',
                    '${_player!.currentHp}/${_player!.maxHp}',
                    Colors.green,
                    Icons.favorite,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDisplay(
                    'Chakra',
                    '${_player!.currentChakra}/${_player!.maxChakra}',
                    Colors.blue,
                    Icons.bolt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatDisplay(
                    'XP',
                    '${_player!.xp}/${_player!.xpToNextLevel}',
                    Colors.amber,
                    Icons.star,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatDisplay(
                    'Items',
                    '${_player!.inventory.length}',
                    Colors.purple,
                    Icons.inventory,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a stat display widget
  Widget _buildStatDisplay(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the inventory list
  Widget _buildInventoryList() {
    if (_player == null || _player!.inventory.isEmpty) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Inventory Empty',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your inventory is empty. Items will appear here when you collect them.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventory (${_player!.inventory.length} items)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addTestItem,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Test Item'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _player!.inventory.length,
              itemBuilder: (context, index) {
                final entry = _player!.inventory.values.elementAt(index);
                return _buildInventoryItem(entry);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an individual inventory item
  Widget _buildInventoryItem(InventoryEntry entry) {
    final item = entry.item;
    final quantity = entry.quantity;
    final canUse = quantity > 0 && (item.canUseInBattle || item.canUseOutsideBattle);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Item icon based on type
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getItemTypeColor(item.type).withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getItemTypeColor(item.type)),
            ),
            child: Icon(
              _getItemTypeIcon(item.type),
              color: _getItemTypeColor(item.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getItemTypeColor(item.type).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getItemTypeName(item.type),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getItemTypeColor(item.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'x$quantity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Use button
          if (canUse)
            ElevatedButton(
              onPressed: () => _useItem(item.name),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getItemTypeColor(item.type),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Use'),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Cannot Use',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Gets the color for an item type
  Color _getItemTypeColor(ItemType type) {
    switch (type) {
      case ItemType.healing:
        return Colors.green;
      case ItemType.chakra:
        return Colors.blue;
      case ItemType.buff:
        return Colors.purple;
    }
  }

  /// Gets the icon for an item type
  IconData _getItemTypeIcon(ItemType type) {
    switch (type) {
      case ItemType.healing:
        return Icons.favorite;
      case ItemType.chakra:
        return Icons.bolt;
      case ItemType.buff:
        return Icons.auto_awesome;
    }
  }

  /// Gets the display name for an item type
  String _getItemTypeName(ItemType type) {
    switch (type) {
      case ItemType.healing:
        return 'Healing';
      case ItemType.chakra:
        return 'Chakra';
      case ItemType.buff:
        return 'Buff';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('🥷 Inventory'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ) : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPlayerStats(),
            const SizedBox(height: 16),
            _buildInventoryList(),
          ],
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation ? const BottomNavigation(currentRoute: '/inventory') : null,
    );
  }
}
