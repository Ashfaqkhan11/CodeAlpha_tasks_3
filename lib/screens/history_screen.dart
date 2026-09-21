import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/fitness_provider.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: provider.activities.isEmpty
          ? const Center(child: Text('No history logs available.'))
          : ListView.builder(
        itemCount: provider.activities.length,
        itemBuilder: (context, index) {
          final activity = provider.activities[index];
          return Dismissible(
            key: Key(activity.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (direction) {
              provider.deleteActivity(activity.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity deleted')),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF00D1A0).withValues(alpha: 0.2),
                  child: const Icon(Icons.directions_run, color: Color(0xFF00D1A0)),
                ),
                title: Text(activity.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${activity.duration} mins • ${activity.calories} kcal'),
                trailing: Text(
                  '${activity.date.day}/${activity.date.month}/${activity.date.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}