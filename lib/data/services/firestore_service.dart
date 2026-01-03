import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:withyou/data/models/user_model.dart';
import 'package:withyou/data/models/couple_model.dart';
import 'package:withyou/data/models/habit_model.dart';
import 'package:withyou/data/models/habit_log_model.dart';
import 'package:withyou/data/models/dare_model.dart';
import 'package:withyou/core/constants/app_constants.dart';
import 'dart:math';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ COUPLE METHODS ============

  // Generate unique 6-digit invite code
  String _generateInviteCode() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Create Couple
  Future<CoupleModel> createCouple(String userId) async {
    try {
      String inviteCode = _generateInviteCode();

      // Check if code already exists
      QuerySnapshot existingCodes = await _firestore
          .collection(AppConstants.couplesCollection)
          .where('inviteCode', isEqualTo: inviteCode)
          .get();

      // Generate new code if duplicate
      while (existingCodes.docs.isNotEmpty) {
        inviteCode = _generateInviteCode();
        existingCodes = await _firestore
            .collection(AppConstants.couplesCollection)
            .where('inviteCode', isEqualTo: inviteCode)
            .get();
      }

      // Create couple document
      DocumentReference coupleRef =
          await _firestore.collection(AppConstants.couplesCollection).add({
        'inviteCode': inviteCode,
        'userIds': [userId],
        'createdAt': Timestamp.now(),
      });

      // Update user's coupleId
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'coupleId': coupleRef.id});

      DocumentSnapshot coupleDoc = await coupleRef.get();
      return CoupleModel.fromFirestore(coupleDoc);
    } catch (e) {
      print('Create couple error: $e');
      rethrow;
    }
  }

  // Join Couple
  Future<CoupleModel?> joinCouple(String userId, String inviteCode) async {
    try {
      // Find couple with invite code
      QuerySnapshot coupleQuery = await _firestore
          .collection(AppConstants.couplesCollection)
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (coupleQuery.docs.isEmpty) {
        throw Exception('Invalid invite code');
      }

      DocumentSnapshot coupleDoc = coupleQuery.docs.first;
      CoupleModel couple = CoupleModel.fromFirestore(coupleDoc);

      if (couple.userIds.length >= 2) {
        throw Exception('Couple is already full');
      }

      if (couple.userIds.contains(userId)) {
        throw Exception('You are already in this couple');
      }

      // Add user to couple
      await _firestore
          .collection(AppConstants.couplesCollection)
          .doc(couple.coupleId)
          .update({
        'userIds': FieldValue.arrayUnion([userId])
      });

      // Update user's coupleId
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'coupleId': couple.coupleId});

      DocumentSnapshot updatedCoupleDoc = await _firestore
          .collection(AppConstants.couplesCollection)
          .doc(couple.coupleId)
          .get();

      return CoupleModel.fromFirestore(updatedCoupleDoc);
    } catch (e) {
      print('Join couple error: $e');
      rethrow;
    }
  }

  // Get Couple
  Future<CoupleModel?> getCouple(String coupleId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.couplesCollection)
          .doc(coupleId)
          .get();

      if (doc.exists) {
        return CoupleModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Get couple error: $e');
    }
    return null;
  }

  // Stream Couple
  Stream<CoupleModel?> streamCouple(String coupleId) {
    return _firestore
        .collection(AppConstants.couplesCollection)
        .doc(coupleId)
        .snapshots()
        .map((doc) => doc.exists ? CoupleModel.fromFirestore(doc) : null);
  }

  // ============ HABIT METHODS ============

  // Create Habit
  Future<HabitModel> createHabit({
    required String coupleId,
    required String name,
    required String frequency,
    required int points,
  }) async {
    try {
      DocumentReference habitRef =
          await _firestore.collection(AppConstants.habitsCollection).add({
        'coupleId': coupleId,
        'name': name,
        'frequency': frequency,
        'points': points,
        'createdAt': Timestamp.now(),
      });

      DocumentSnapshot habitDoc = await habitRef.get();
      return HabitModel.fromFirestore(habitDoc);
    } catch (e) {
      print('Create habit error: $e');
      rethrow;
    }
  }

  // Stream Habits for Couple
  Stream<List<HabitModel>> streamHabits(String coupleId) {
    return _firestore
        .collection(AppConstants.habitsCollection)
        .where('coupleId', isEqualTo: coupleId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HabitModel.fromFirestore(doc)).toList());
  }

  // Delete Habit
  Future<void> deleteHabit(String habitId) async {
    await _firestore
        .collection(AppConstants.habitsCollection)
        .doc(habitId)
        .delete();
  }

  // ============ HABIT LOG METHODS ============

  // Log Habit Completion
  Future<HabitLogModel?> logHabit({
    required String userId,
    required String habitId,
    required int points,
  }) async {
    try {
      // Check if already logged today
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot existingLogs = await _firestore
          .collection(AppConstants.habitLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      if (existingLogs.docs.isNotEmpty) {
        throw Exception('Habit already logged today');
      }

      // Create log
      DocumentReference logRef =
          await _firestore.collection(AppConstants.habitLogsCollection).add({
        'userId': userId,
        'habitId': habitId,
        'date': Timestamp.fromDate(startOfDay),
        'points': points,
        'createdAt': Timestamp.now(),
      });

      DocumentSnapshot logDoc = await logRef.get();
      return HabitLogModel.fromFirestore(logDoc);
    } catch (e) {
      print('Log habit error: $e');
      rethrow;
    }
  }

  // Check if habit logged today
  Future<bool> isHabitLoggedToday(String userId, String habitId) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      QuerySnapshot logs = await _firestore
          .collection(AppConstants.habitLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('habitId', isEqualTo: habitId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      return logs.docs.isNotEmpty;
    } catch (e) {
      print('Check habit logged error: $e');
      return false;
    }
  }

  // Get Monthly Points for User
  Future<int> getMonthlyPoints(String userId, {DateTime? month}) async {
    try {
      month ??= DateTime.now();
      DateTime startOfMonth = DateTime(month.year, month.month, 1);
      DateTime endOfMonth = DateTime(month.year, month.month + 1, 1);

      QuerySnapshot logs = await _firestore
          .collection(AppConstants.habitLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThan: Timestamp.fromDate(endOfMonth))
          .get();

      int totalPoints = 0;
      for (var doc in logs.docs) {
        totalPoints += (doc.data() as Map<String, dynamic>)['points'] as int;
      }

      return totalPoints;
    } catch (e) {
      print('Get monthly points error: $e');
      return 0;
    }
  }

  // ============ USER METHODS ============

  // Get User by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
    } catch (e) {
      print('Get user error: $e');
    }
    return null;
  }

  // Stream User
  Stream<UserModel?> streamUser(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  // ============ DARE METHODS ============

  // Get Random Dare
  Future<DareModel?> getRandomDare() async {
    try {
      QuerySnapshot dares = await _firestore
          .collection(AppConstants.daresCollection)
          .get();

      if (dares.docs.isEmpty) {
        return null;
      }

      final random = Random();
      DocumentSnapshot randomDoc =
          dares.docs[random.nextInt(dares.docs.length)];
      return DareModel.fromFirestore(randomDoc);
    } catch (e) {
      print('Get random dare error: $e');
      return null;
    }
  }

  // Add Dare (for seeding database)
  Future<void> addDare(String content, String type) async {
    await _firestore.collection(AppConstants.daresCollection).add({
      'content': content,
      'type': type,
    });
  }
}
