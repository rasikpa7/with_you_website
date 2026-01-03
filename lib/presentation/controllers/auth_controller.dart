import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:withyou/data/services/auth_service.dart';
import 'package:withyou/data/services/firestore_service.dart';
import 'package:withyou/data/models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Rx<User?> firebaseUser = Rx<User?>(null);
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authService.authStateChanges);
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) async {
    if (user == null) {
      currentUser.value = null;
      Get.offAllNamed('/login');
    } else {
      currentUser.value = await _firestoreService.getUser(user.uid);
      if (currentUser.value?.coupleId == null) {
        Get.offAllNamed('/couple-setup');
      } else {
        Get.offAllNamed('/home');
      }
    }
  }

  // Sign Up with Email
  Future<void> signUpWithEmail(String email, String password, String name) async {
    try {
      isLoading.value = true;
      UserModel? user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      if (user != null) {
        currentUser.value = user;
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

  // Sign In with Email
  Future<void> signInWithEmail(String email, String password) async {
    try {
      isLoading.value = true;
      UserModel? user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        currentUser.value = user;
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

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      UserModel? user = await _authService.signInWithGoogle();
      if (user != null) {
        currentUser.value = user;
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

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    currentUser.value = null;
  }
}
