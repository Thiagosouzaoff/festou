import 'package:flutter/material.dart';
import 'package:festou/theme.dart';

class PaymentScreen extends StatefulWidget {
  final int premiumDays;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.premiumDays,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  bool _isProcessing = false;

  double get totalAmount => widget.premiumDays * 2.60;

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um método de pagamento')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isProcessing = false);

    if (mounted) {
      widget.onPaymentSuccess();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento Premium', style: Theme.of(context).textTheme.headlineSmall?.bold),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, size: 64, color: Colors.white),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Festa Premium',
                    style: Theme.of(context).textTheme.headlineSmall?.semiBold.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${widget.premiumDays} ${widget.premiumDays == 1 ? "dia" : "dias"}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Resumo do Pedido', style: Theme.of(context).textTheme.titleLarge?.semiBold),
            const SizedBox(height: AppSpacing.md),

            _buildSummaryRow('Dias Premium', '${widget.premiumDays}x'),
            _buildSummaryRow('Valor por dia', 'R\$ 2,60'),
            const Divider(height: AppSpacing.lg),
            _buildSummaryRow(
              'Total',
              'R\$ ${totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Método de Pagamento', style: Theme.of(context).textTheme.titleLarge?.semiBold),
            const SizedBox(height: AppSpacing.md),

            _buildPaymentMethod(
              'pix',
              'PIX',
              Icons.qr_code,
              'Aprovação instantânea',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildPaymentMethod(
              'credit_card',
              'Cartão de Crédito',
              Icons.credit_card,
              'Parcelamento disponível',
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildPaymentMethod(
              'debit_card',
              'Cartão de Débito',
              Icons.payment,
              'Aprovação instantânea',
            ),
            const SizedBox(height: AppSpacing.xl),

            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Pagamento simulado para demonstração. Em produção, será integrado com gateway de pagamento real.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Confirmar Pagamento - R\$ ${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.semiBold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.bold
              : Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.bold.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                )
              : Theme.of(context).textTheme.bodyLarge?.semiBold,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String id, String title, IconData icon, String subtitle) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.semiBold),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
