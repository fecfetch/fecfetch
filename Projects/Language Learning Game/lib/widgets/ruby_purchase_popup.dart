import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class RubyPurchasePopup extends StatelessWidget {
  final VoidCallback onWatchAd;

  const RubyPurchasePopup({super.key, required this.onWatchAd});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: const Color(0xFFF0F4F8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Center(
        child: Text(
          l10n.getMoreRubies,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPurchaseOption(context, '100', '\$0.99', Colors.blue, l10n),
          const SizedBox(height: 10),
          _buildPurchaseOption(context, '500', '\$4.99', Colors.purple, l10n),
          const SizedBox(height: 10),
          _buildPurchaseOption(context, '1000', '\$9.99', Colors.orange, l10n),
          const SizedBox(height: 20),
          _buildWatchAdButton(context, l10n),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildPurchaseOption(
      BuildContext context, String amount, String price, Color color, AppLocalizations l10n) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(l10n.purchaseNotImplemented(amount))),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.diamond, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatchAdButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton.icon(
      onPressed: onWatchAd,
      icon: const Icon(Icons.movie, color: Colors.white),
      label: Expanded(
        child: Text(
          l10n.watchAdForRubies,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
    );
  }
}