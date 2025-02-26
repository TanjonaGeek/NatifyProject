import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  final List<Map<String, dynamic>> summaryCards = [
    {'color': Colors.blue, 'title': 'Utilisateur vérifié', 'amount': '17'},
    {'color': Colors.green, 'title': 'Utilisateur Non vérifié', 'amount': '2'},
    {'color': Colors.orange, 'title': 'Signalement en attente', 'amount': '5'},
    {'color': Colors.purple, 'title': 'Signalement traité', 'amount': '2'},
    {'color': Colors.purple, 'title': 'Story du jour', 'amount': '6'},
  ];

  Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aperçu global',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: SizedBox.shrink(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine number of columns based on screen width
          int crossAxisCount = constraints.maxWidth > 800
              ? 4
              : constraints.maxWidth > 600
                  ? 2
                  : 1;

          return Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
              ),
              itemCount: summaryCards.length,
              itemBuilder: (context, index) {
                final card = summaryCards[index];
                return DashboardCard(
                  color: card['color'],
                  title: card['title'],
                  amount: card['amount'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final Color color;
  final String title;
  final String amount;

  const DashboardCard({
    super.key,
    required this.color,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
