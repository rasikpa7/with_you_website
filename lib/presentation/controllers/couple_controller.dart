import 'package:get/get.dart';
import 'package:withyou/data/services/firestore_service.dart';
import 'package:withyou/data/models/couple_model.dart';
import 'package:withyou/data/models/user_model.dart';
import 'package:withyou/presentation/controllers/auth_controller.dart';

class CoupleController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthController _authController = Get.find<AuthController>();

  Rx<CoupleModel?> currentCouple = Rx<CoupleModel?>(null);
  RxList<UserModel> coupleUsers = <UserModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCouple();
  }

  void _loadCouple() {
    String? coupleId = _authController.currentUser.value?.coupleId;
    if (coupleId != null) {
      currentCouple.bindStream(_firestoreService.streamCouple(coupleId));
      ever(currentCouple, _loadCoupleUsers);
    }
  }

  Future<void> _loadCoupleUsers(CoupleModel? couple) async {
    if (couple != null) {
      coupleUsers.clear();
      for (String userId in couple.userIds) {
        UserModel? user = await _firestoreService.getUser(userId);
        if (user != null) {
          coupleUsers.add(user);
        }
      }
    }
  }

  // Create Couple
  Future<void> createCouple() async {
    try {
      isLoading.value = true;
      String userId = _authController.currentUser.value!.userId;
      CoupleModel couple = await _firestoreService.createCouple(userId);
      currentCouple.value = couple;

      // Update current user
      _authController.currentUser.value =
          await _firestoreService.getUser(userId);

      Get.snackbar(
        'Success',
        'Couple created! Invite code: ${couple.inviteCode}',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to home if couple is complete
      if (couple.isComplete) {
        Get.offAllNamed('/home');
      }
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

  // Join Couple
  Future<void> joinCouple(String inviteCode) async {
    try {
      isLoading.value = true;
      String userId = _authController.currentUser.value!.userId;
      CoupleModel? couple =
          await _firestoreService.joinCouple(userId, inviteCode);

      if (couple != null) {
        currentCouple.value = couple;

        // Update current user
        _authController.currentUser.value =
            await _firestoreService.getUser(userId);

        Get.snackbar(
          'Success',
          'Successfully joined couple!',
          snackPosition: SnackPosition.BOTTOM,
        );

        Get.offAllNamed('/home');
      }
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

  // Get Partner
  UserModel? getPartner() {
    String currentUserId = _authController.currentUser.value!.userId;
    return coupleUsers.firstWhereOrNull((user) => user.userId != currentUserId);
  }
}
