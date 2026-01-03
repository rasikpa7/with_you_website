import 'package:get/get.dart';
import 'package:withyou/data/services/firestore_service.dart';
import 'package:withyou/data/models/user_model.dart';
import 'package:withyou/data/models/dare_model.dart';
import 'package:withyou/presentation/controllers/auth_controller.dart';
import 'package:withyou/presentation/controllers/couple_controller.dart';

class LeaderboardController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();
  final CoupleController _coupleController = Get.find<CoupleController>();

  RxMap<String, int> monthlyPoints = <String, int>{}.obs;
  Rx<UserModel?> monthlyWinner = Rx<UserModel?>(null);
  Rx<DareModel?> winnerDare = Rx<DareModel?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonthlyLeaderboard();
  }

  // Load Monthly Leaderboard
  Future<void> loadMonthlyLeaderboard() async {
    try {
      isLoading.value = true;
      monthlyPoints.clear();

      List<UserModel> users = _coupleController.coupleUsers;
      if (users.isEmpty) {
        return;
      }

      for (UserModel user in users) {
        int points = await _firestoreService.getMonthlyPoints(user.userId);
        monthlyPoints[user.userId] = points;
      }

      _determineWinner();
    } catch (e) {
      print('Load leaderboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Determine Monthly Winner
  void _determineWinner() {
    if (monthlyPoints.isEmpty) return;

    String? winnerId;
    int maxPoints = 0;

    monthlyPoints.forEach((userId, points) {
      if (points > maxPoints) {
        maxPoints = points;
        winnerId = userId;
      }
    });

    if (winnerId != null && maxPoints > 0) {
      monthlyWinner.value = _coupleController.coupleUsers
          .firstWhereOrNull((user) => user.userId == winnerId);
    } else {
      monthlyWinner.value = null;
    }
  }

  // Load Winner Dare
  Future<void> loadWinnerDare() async {
    try {
      winnerDare.value = await _firestoreService.getRandomDare();
    } catch (e) {
      print('Load dare error: $e');
    }
  }

  // Get points for user
  int getPoints(String userId) {
    return monthlyPoints[userId] ?? 0;
  }

  // Get current month progress percentage
  double getProgressPercentage(String userId) {
    int points = monthlyPoints[userId] ?? 0;
    int maxPoints = monthlyPoints.values.isNotEmpty
        ? monthlyPoints.values.reduce((a, b) => a > b ? a : b)
        : 0;

    if (maxPoints == 0) return 0;
    return points / maxPoints;
  }

  // Check if current user is winner
  bool isCurrentUserWinner() {
    return monthlyWinner.value?.userId ==
        _authController.currentUser.value?.userId;
  }
}
