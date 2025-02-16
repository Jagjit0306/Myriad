import 'package:flutter/material.dart';

class NotifyPage extends StatelessWidget {
  const NotifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNotificationCard(
              context,
              title: 'Emergency Alert',
              message: 'This is an emergency notification.',
              date: '2023-10-01',
            ),
            _buildNotificationCard(
              context,
              title: 'Reminder',
              message: 'Don\'t forget to take your medication.',
              date: '2023-10-02',
            ),
            _buildNotificationCard(
              context,
              title: 'Update',
              message: 'New features have been added to the app.',
              date: '2023-10-03',
            ),
            // Add more notifications as needed
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, {required String title, required String message, required String date}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              date,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
} 