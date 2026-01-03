import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:withyou/presentation/controllers/habit_controller.dart';
import 'package:withyou/core/theme/app_theme.dart';
import 'package:withyou/core/constants/app_constants.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final HabitController _habitController = Get.find<HabitController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedFrequency = AppConstants.frequencyDaily;
  int _points = AppConstants.defaultHabitPoints;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _habitController.createHabit(
        name: _nameController.text.trim(),
        frequency: _selectedFrequency,
        points: _points,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create a new habit',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Build healthy habits together with your partner',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Habit Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Morning workout',
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Frequency
              const Text(
                'Frequency',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Daily'),
                      value: AppConstants.frequencyDaily,
                      groupValue: _selectedFrequency,
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Weekly'),
                      value: AppConstants.frequencyWeekly,
                      groupValue: _selectedFrequency,
                      onChanged: (value) {
                        setState(() {
                          _selectedFrequency = value!;
                        });
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Points
              const Text(
                'Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_points > 5) _points -= 5;
                        });
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                      color: AppTheme.primaryColor,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          '$_points points',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _points += 5;
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _habitController.isLoading.value
                          ? null
                          : _submit,
                      child: _habitController.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text('Create Habit'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
