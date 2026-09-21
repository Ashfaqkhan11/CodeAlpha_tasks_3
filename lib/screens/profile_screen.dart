import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/fitness_provider.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _heightController = TextEditingController(text: '175');
  final _weightController = TextEditingController(text: '70');
  double? _bmi;

  void _calculateBMI() {
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    if (h != null && w != null && h > 0) {
      setState(() {
        _bmi = w / ((h / 100) * (h / 100));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FitnessProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Goals')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF6C63FF),
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text('Fitness Enthusiast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // BMI Calculator Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BMI Calculator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Height (cm)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _calculateBMI,
                      child: const Text('Calculate BMI'),
                    ),
                    if (_bmi != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Your BMI: ${_bmi!.toStringAsFixed(1)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6C63FF)),
                      )
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Goals Configuration
            ListTile(
              title: const Text('Step Goal'),
              subtitle: Text('${provider.stepGoal} steps'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showGoalDialog(context, 'Steps', provider.stepGoal, (val) {
                provider.setGoals(val, provider.calorieGoal);
              }),
            ),
            ListTile(
              title: const Text('Calorie Goal'),
              subtitle: Text('${provider.calorieGoal} kcal'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showGoalDialog(context, 'Calories', provider.calorieGoal, (val) {
                provider.setGoals(provider.stepGoal, val);
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context, String title, int currentValue, Function(int) onSave) {
    final controller = TextEditingController(text: currentValue.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set $title Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'New $title Goal'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) onSave(val);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}