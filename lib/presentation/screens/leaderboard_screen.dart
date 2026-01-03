import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:withyou/presentation/controllers/leaderboard_controller.dart';
import 'package:withyou/presentation/controllers/couple_controller.dart';
import 'package:withyou/core/theme/app_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LeaderboardController leaderboardController =
        Get.put(LeaderboardController());
    final CoupleController coupleController = Get.find<CoupleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: Obx(() {
        if (leaderboardController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (coupleController.coupleUsers.isEmpty) {
          return const Center(
            child: Text('No data available'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Monthly Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Monthly Challenge',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      if (leaderboardController.monthlyWinner.value != null) {
                        return Column(
                          children: [
                            const Text(
                              'Current Leader',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              leaderboardController
                                  .monthlyWinner.value!.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }
                      return const Text(
                        'No winner yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // User Cards
              ...coupleController.coupleUsers.map((user) {
                int points = leaderboardController.getPoints(user.userId);
                double progress =
                    leaderboardController.getProgressPercentage(user.userId);
                bool isWinner = leaderboardController.monthlyWinner.value
                        ?.userId ==
                    user.userId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isWinner
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              user.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isWinner) ...[
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.emoji_events,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$points points',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor:
                              AppTheme.primaryColor.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 16),

              // View Winner Button (if there's a winner)
              Obx(() {
                if (leaderboardController.monthlyWinner.value != null) {
                  return ElevatedButton.icon(
                    onPressed: () async {
                      await leaderboardController.loadWinnerDare();
                      Get.toNamed('/winner');
                    },
                    icon: const Icon(Icons.celebration),
                    label: const Text('View Winner Celebration'),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        );
      }),
    );
  }
}
