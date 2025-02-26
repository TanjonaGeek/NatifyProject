import 'package:flutter/material.dart';

class DashboardSummary extends StatelessWidget {
  final List<Map<String, dynamic>> summaryCards = [
    {
      'color': Colors.blue,
      'icon': Icons.receipt_long,
      'amount': '\$2,342',
      'description': 'Total Invoice',
    },
    {
      'color': Colors.green,
      'icon': Icons.check_circle_outline,
      'amount': '\$2,312',
      'description': 'Paid Invoices',
    },
    {
      'color': Colors.orange,
      'icon': Icons.warning_amber_outlined,
      'amount': '\$2,332',
      'description': 'Unpaid Invoice',
    },
    {
      'color': Colors.purple,
      'icon': Icons.send,
      'amount': '\$3,587',
      'description': 'Total Invoice Sent',
    },
  ];

  DashboardSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: summaryCards.map((card) {
            return Flexible(
              child: SummaryCard(
                color: card['color'],
                icon: card['icon'],
                amount: card['amount'],
                description: card['description'],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String amount;
  final String description;

  const SummaryCard({
    super.key,
    required this.color,
    required this.icon,
    required this.amount,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 150,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              Spacer(),
              Text(
                amount,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
