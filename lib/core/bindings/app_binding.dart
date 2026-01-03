import 'package:get/get.dart';
import 'package:withyou/presentation/controllers/auth_controller.dart';
import 'package:withyou/presentation/controllers/couple_controller.dart';
import 'package:withyou/presentation/controllers/habit_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
    Get.lazyPut(() => CoupleController());
    Get.lazyPut(() => HabitController());
  }
}
