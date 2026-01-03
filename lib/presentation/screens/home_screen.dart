import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:withyou/presentation/controllers/auth_controller.dart';
import 'package:withyou/presentation/controllers/habit_controller.dart';
import 'package:withyou/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final HabitController habitController = Get.find<HabitController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WithYou'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () => Get.toNamed('/leaderboard'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Obx(() => Text(
                      'Hello, ${authController.currentUser.value?.name ?? "User"}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Habits List
          Expanded(
            child: Obx(() {
              if (habitController.habits.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 80,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No habits yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first habit together!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: habitController.habits.length,
                itemBuilder: (context, index) {
                  final habit = habitController.habits[index];
                  final isCompleted =
                      habitController.isHabitCompleted(habit.habitId);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.primaryColor.withOpacity(0.2),
                        child: Icon(
                          isCompleted ? Icons.check : Icons.circle_outlined,
                          color: isCompleted
                              ? Colors.white
                              : AppTheme.primaryColor,
                        ),
                      ),
                      title: Text(
                        habit.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(
                        '${habit.frequency} • ${habit.points} points',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: isCompleted
                          ? const Chip(
                              label: Text('Done'),
                              backgroundColor: AppTheme.successColor,
                              labelStyle: TextStyle(color: Colors.white),
                            )
                          : ElevatedButton(
                              onPressed: () =>
                                  habitController.logHabit(habit),
                              child: const Text('Complete'),
                            ),
                      onLongPress: () {
                        Get.defaultDialog(
                          title: 'Delete Habit',
                          middleText:
                              'Are you sure you want to delete this habit?',
                          textConfirm: 'Delete',
                          textCancel: 'Cancel',
                          confirmTextColor: Colors.white,
                          onConfirm: () {
                            habitController.deleteHabit(habit.habitId);
                            Get.back();
                          },
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/add-habit'),
        backgroundColor: AppTheme.secondaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }
}
