import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../services/player_data_manager.dart';
import '../core/widgets/bottom_navigation.dart';

/// Screen for banking operations including deposit, withdraw, and transfer.
/// 
/// This screen allows players to manage their Ryo between wallet and bank,
/// and transfer funds to other players.
/// 
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const BankScreen(),
///   ),
/// );
/// ```
class BankScreen extends StatefulWidget {
  const BankScreen({super.key});

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  Player? _player;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  String _selectedOperation = 'deposit';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPlayer();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

  /// Loads the current player from the data manager
  void _loadPlayer() {
    setState(() {
      _player = PlayerDataManager.instance.currentPlayer;
    });
  }

  /// Handles deposit operation
  Future<void> _handleDeposit() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (_player == null) return;

    if (_player!.depositToBank(amount)) {
      await _savePlayer();
      _showSuccessSnackBar('Deposited $amount Ryo to bank');
      _amountController.clear();
    } else {
      _showErrorSnackBar('Insufficient wallet funds');
    }
  }

  /// Handles withdraw operation
  Future<void> _handleWithdraw() async {
    final amount = int.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (_player == null) return;

    if (_player!.withdrawFromBank(amount)) {
      await _savePlayer();
      _showSuccessSnackBar('Withdrew $amount Ryo from bank');
      _amountController.clear();
    } else {
      _showErrorSnackBar('Insufficient bank funds');
    }
  }

  /// Handles transfer operation
  Future<void> _handleTransfer() async {
    final amount = int.tryParse(_amountController.text);
    final recipientName = _recipientController.text.trim();
    
    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter a valid amount');
      return;
    }

    if (recipientName.isEmpty) {
      _showErrorSnackBar('Please enter recipient name');
      return;
    }

    if (_player == null) return;

    // For now, we'll simulate a transfer (in a real app, this would involve server communication)
    if (_player!.bankRyo >= amount) {
      _player!.bankRyo -= amount;
      await _savePlayer();
      _showSuccessSnackBar('Transferred $amount Ryo to $recipientName');
      _amountController.clear();
      _recipientController.clear();
    } else {
      _showErrorSnackBar('Insufficient bank funds');
    }
  }

  /// Saves the player data
  Future<void> _savePlayer() async {
    if (_player != null) {
      await PlayerDataManager.instance.updatePlayer(_player!);
      setState(() {});
    }
  }

  /// Shows success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Builds the balance display
  Widget _buildBalanceDisplay() {
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Bank Account',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceCard(
                    'Wallet',
                    '${_player!.walletRyo}',
                    Colors.orange,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBalanceCard(
                    'Bank',
                    '${_player!.bankRyo}',
                    Colors.blue,
                    Icons.account_balance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Total: ${_player!.totalRyo} Ryo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a balance card
  Widget _buildBalanceCard(String label, String amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount Ryo',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the operation selection
  Widget _buildOperationSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Operation',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOperationButton(
                    'Deposit',
                    'deposit',
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationButton(
                    'Withdraw',
                    'withdraw',
                    Icons.arrow_upward,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildOperationButton(
                    'Transfer',
                    'transfer',
                    Icons.send,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an operation button
  Widget _buildOperationButton(String label, String value, IconData icon, Color color) {
    final isSelected = _selectedOperation == value;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOperation = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the input form
  Widget _buildInputForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (Ryo)',
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons.monetization_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            if (_selectedOperation == 'transfer') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _recipientController,
                decoration: InputDecoration(
                  labelText: 'Recipient Name',
                  hintText: 'Enter player name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleTransaction,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_getOperationIcon()),
                label: Text(_getOperationLabel()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getOperationColor(),
                  foregroundColor: Colors.white,
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
    );
  }

  /// Gets the operation icon
  IconData _getOperationIcon() {
    switch (_selectedOperation) {
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdraw':
        return Icons.arrow_upward;
      case 'transfer':
        return Icons.send;
      default:
        return Icons.help;
    }
  }

  /// Gets the operation label
  String _getOperationLabel() {
    switch (_selectedOperation) {
      case 'deposit':
        return 'Deposit to Bank';
      case 'withdraw':
        return 'Withdraw from Bank';
      case 'transfer':
        return 'Transfer to Player';
      default:
        return 'Process';
    }
  }

  /// Gets the operation color
  Color _getOperationColor() {
    switch (_selectedOperation) {
      case 'deposit':
        return Colors.green;
      case 'withdraw':
        return Colors.orange;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Handles the transaction based on selected operation
  Future<void> _handleTransaction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      switch (_selectedOperation) {
        case 'deposit':
          await _handleDeposit();
          break;
        case 'withdraw':
          await _handleWithdraw();
          break;
        case 'transfer':
          await _handleTransfer();
          break;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥷 Bank'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBalanceDisplay(),
            const SizedBox(height: 16),
            _buildOperationSelection(),
            const SizedBox(height: 16),
            _buildInputForm(),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentRoute: '/bank'),
    );
  }
}
