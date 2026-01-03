import 'package:get/get.dart';
import 'package:withyou/presentation/screens/login_screen.dart';
import 'package:withyou/presentation/screens/couple_setup_screen.dart';
import 'package:withyou/presentation/screens/create_couple_screen.dart';
import 'package:withyou/presentation/screens/join_couple_screen.dart';
import 'package:withyou/presentation/screens/home_screen.dart';
import 'package:withyou/presentation/screens/add_habit_screen.dart';
import 'package:withyou/presentation/screens/leaderboard_screen.dart';
import 'package:withyou/presentation/screens/winner_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String coupleSetup = '/couple-setup';
  static const String createCouple = '/create-couple';
  static const String joinCouple = '/join-couple';
  static const String home = '/home';
  static const String addHabit = '/add-habit';
  static const String leaderboard = '/leaderboard';
  static const String winner = '/winner';

  static List<GetPage> routes = [
    GetPage(
      name: login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: coupleSetup,
      page: () => const CoupleSetupScreen(),
    ),
    GetPage(
      name: createCouple,
      page: () => const CreateCoupleScreen(),
    ),
    GetPage(
      name: joinCouple,
      page: () => const JoinCoupleScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: addHabit,
      page: () => const AddHabitScreen(),
    ),
    GetPage(
      name: leaderboard,
      page: () => const LeaderboardScreen(),
    ),
    GetPage(
      name: winner,
      page: () => const WinnerScreen(),
    ),
  ];
}
