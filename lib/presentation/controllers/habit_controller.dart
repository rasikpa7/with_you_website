import 'package:get/get.dart';
import 'package:withyou/data/services/firestore_service.dart';
import 'package:withyou/data/models/habit_model.dart';
import 'package:withyou/presentation/controllers/auth_controller.dart';
import 'package:withyou/core/constants/app_constants.dart';

class HabitController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  RxList<HabitModel> habits = <HabitModel>[].obs;
  RxMap<String, bool> habitCompletionStatus = <String, bool>{}.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHabits();
  }

  void _loadHabits() {
    String? coupleId = _authController.currentUser.value?.coupleId;
    if (coupleId != null) {
      habits.bindStream(_firestoreService.streamHabits(coupleId));
      ever(habits, (_) => _checkHabitCompletions());
    }
  }

  Future<void> _checkHabitCompletions() async {
    String userId = _authController.currentUser.value!.userId;
    for (var habit in habits) {
      bool isCompleted =
          await _firestoreService.isHabitLoggedToday(userId, habit.habitId);
      habitCompletionStatus[habit.habitId] = isCompleted;
    }
  }

  // Create Habit
  Future<void> createHabit({
    required String name,
    required String frequency,
    required int points,
  }) async {
    try {
      isLoading.value = true;
      String coupleId = _authController.currentUser.value!.coupleId!;

      await _firestoreService.createHabit(
        coupleId: coupleId,
        name: name,
        frequency: frequency,
        points: points,
      );

      Get.back();
      Get.snackbar(
        'Success',
        'Habit created!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Log Habit Completion
  Future<void> logHabit(HabitModel habit) async {
    try {
      String userId = _authController.currentUser.value!.userId;

      await _firestoreService.logHabit(
        userId: userId,
        habitId: habit.habitId,
        points: habit.points,
      );

      habitCompletionStatus[habit.habitId] = true;

      Get.snackbar(
        'Success',
        'Habit logged! +${habit.points} points',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete Habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _firestoreService.deleteHabit(habitId);
      Get.snackbar(
        'Success',
        'Habit deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Check if habit is completed today
  bool isHabitCompleted(String habitId) {
    return habitCompletionStatus[habitId] ?? false;
  }
}
