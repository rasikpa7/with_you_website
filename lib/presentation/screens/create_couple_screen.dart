import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:withyou/presentation/controllers/couple_controller.dart';
import 'package:withyou/core/theme/app_theme.dart';

class CreateCoupleScreen extends StatelessWidget {
  const CreateCoupleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CoupleController coupleController = Get.find<CoupleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Couple'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_circle,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Your Couple',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You\'ll get an invite code to share with your partner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 48),

              Obx(() {
                if (coupleController.currentCouple.value != null &&
                    !coupleController.currentCouple.value!.isComplete) {
                  return Column(
                    children: [
                      const Text(
                        'Your Invite Code:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          coupleController.currentCouple.value!.inviteCode,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: coupleController
                                  .currentCouple.value!.inviteCode));
                          Get.snackbar(
                            'Copied',
                            'Invite code copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Code'),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Waiting for partner to join...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  );
                }

                return Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: coupleController.isLoading.value
                            ? null
                            : () => coupleController.createCouple(),
                        child: coupleController.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Create Couple'),
                      ),
                    ));
              }),
            ],
          ),
        ),
      ),
    );
  }
}
