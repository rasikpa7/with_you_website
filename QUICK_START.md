# WithYou - Quick Start Guide

## Project Structure

```
withyou/
├── lib/
│   ├── core/
│   │   ├── bindings/
│   │   │   └── app_binding.dart           # GetX dependency injection
│   │   ├── constants/
│   │   │   └── app_constants.dart         # App-wide constants
│   │   ├── routes/
│   │   │   └── app_routes.dart            # Route definitions
│   │   └── theme/
│   │       └── app_theme.dart             # Material 3 theme
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart            # User data model
│   │   │   ├── couple_model.dart          # Couple data model
│   │   │   ├── habit_model.dart           # Habit data model
│   │   │   ├── habit_log_model.dart       # Habit log data model
│   │   │   └── dare_model.dart            # Dare/Question model
│   │   └── services/
│   │       ├── auth_service.dart          # Firebase Auth service
│   │       └── firestore_service.dart     # Firestore CRUD operations
│   ├── presentation/
│   │   ├── controllers/
│   │   │   ├── auth_controller.dart       # Authentication logic
│   │   │   ├── couple_controller.dart     # Couple management
│   │   │   ├── habit_controller.dart      # Habit management
│   │   │   └── leaderboard_controller.dart # Points & winner logic
│   │   └── screens/
│   │       ├── login_screen.dart          # Login/Signup
│   │       ├── couple_setup_screen.dart   # Create/Join choice
│   │       ├── create_couple_screen.dart  # Create couple flow
│   │       ├── join_couple_screen.dart    # Join couple flow
│   │       ├── home_screen.dart           # Main habit list
│   │       ├── add_habit_screen.dart      # Create new habit
│   │       ├── leaderboard_screen.dart    # Monthly points
│   │       └── winner_screen.dart         # Winner celebration
│   └── main.dart                          # App entry point
```

## Key Implementation Details

### 1. Authentication Flow
- User opens app → `AuthController` checks auth state
- Not authenticated → `/login`
- Authenticated but no couple → `/couple-setup`
- Authenticated with couple → `/home`

### 2. Couple Pairing
- User A creates couple → Gets 6-digit code
- User B joins with code → Both users now paired
- Invite code is unique (validated in Firestore)

### 3. Habit Logging
- Each user can complete a habit once per day
- Completion adds points to user's monthly total
- Prevents duplicate logs using date range query

### 4. Monthly Points
- Points aggregated from `habitLogs` collection
- Filtered by current month
- Automatically resets each month (history preserved)

### 5. Winner Detection
- Compares monthly points between two partners
- Winner shown in leaderboard with trophy icon
- Random dare/question fetched from Firestore

## Important Files

### app_constants.dart
```dart
- Collection names
- Habit frequency options
- Invite code length
- Default point values
```

### app_theme.dart
```dart
- Material 3 color scheme
- Warm, soft color palette
- Button styles
- Input decoration
```

### firestore_service.dart
Key methods:
- `createCouple()` - Generate invite code
- `joinCouple()` - Join with code
- `createHabit()` - Add new habit
- `logHabit()` - Mark habit complete
- `getMonthlyPoints()` - Calculate points
- `getRandomDare()` - Fetch dare/question

### auth_service.dart
Key methods:
- `signUpWithEmail()` - Create account
- `signInWithEmail()` - Login
- `signInWithGoogle()` - Google OAuth
- `signOut()` - Logout

## GetX State Management

### Controllers
- **AuthController**: Current user, auth state
- **CoupleController**: Couple data, partner info
- **HabitController**: Habit list, completion status
- **LeaderboardController**: Points, winner, dares

### Observables (Reactive)
```dart
Rx<UserModel?> currentUser
RxList<HabitModel> habits
RxMap<String, bool> habitCompletionStatus
Rx<CoupleModel?> currentCouple
```

## Firebase Configuration Checklist

- [ ] Create Firebase project
- [ ] Enable Email/Password auth
- [ ] Enable Google Sign-In auth
- [ ] Create Firestore database
- [ ] Add `google-services.json` (Android)
- [ ] Add `GoogleService-Info.plist` (iOS)
- [ ] Set up Firestore security rules
- [ ] Create composite indexes for habitLogs
- [ ] (Optional) Seed dares collection

## Testing the App

### 1. Authentication
1. Sign up with email/password
2. Logout and sign in again
3. Try Google Sign-In

### 2. Couple Pairing
1. Create couple as User A → Note invite code
2. Sign in as User B → Join with code
3. Both should see each other on leaderboard

### 3. Habit Management
1. Create a daily habit with 10 points
2. Complete the habit
3. Check leaderboard - should show 10 points
4. Try completing again - should prevent duplicate

### 4. Leaderboard
1. Both users complete different habits
2. View leaderboard
3. User with more points is highlighted
4. View winner celebration

## Common Issues & Fixes

### Issue: Firebase not initialized
**Fix**: Make sure `await Firebase.initializeApp()` is called in `main()`

### Issue: Google Sign-In not working
**Fix**: Add SHA-1 fingerprint to Firebase Console (Android)

### Issue: Firestore permission denied
**Fix**: Update security rules to allow authenticated reads/writes

### Issue: Habit can be completed multiple times
**Fix**: Check `isHabitLoggedToday()` logic in `firestore_service.dart`

### Issue: Couple can't be joined
**Fix**: Verify invite code is correct and couple has < 2 users

## Next Steps After Setup

1. ✅ Install dependencies: `flutter pub get`
2. ✅ Set up Firebase project
3. ✅ Add Firebase config files
4. ✅ Update security rules
5. ✅ Run the app: `flutter run`
6. ✅ Create two test accounts
7. ✅ Test couple pairing
8. ✅ Create and complete habits
9. ✅ Check leaderboard
10. ✅ Seed dares for winner screen

## API Reference

### AuthService
```dart
Future<UserModel?> signUpWithEmail(email, password, name)
Future<UserModel?> signInWithEmail(email, password)
Future<UserModel?> signInWithGoogle()
Future<void> signOut()
```

### FirestoreService
```dart
Future<CoupleModel> createCouple(userId)
Future<CoupleModel?> joinCouple(userId, inviteCode)
Future<HabitModel> createHabit({coupleId, name, frequency, points})
Future<HabitLogModel?> logHabit({userId, habitId, points})
Future<bool> isHabitLoggedToday(userId, habitId)
Future<int> getMonthlyPoints(userId)
Future<DareModel?> getRandomDare()
```

## Performance Optimization

### Firestore Reads
- Use `.snapshots()` for real-time updates (habits, couple)
- Use `.get()` for one-time reads (points, dares)
- Limit queries with `.limit(1)` when appropriate

### State Management
- Use `Get.lazyPut()` for controllers not needed immediately
- Use `permanent: true` for AuthController
- Use `ever()` for reactive side effects

### UI
- Use `Obx()` for reactive widgets
- Keep build methods lightweight
- Use `const` constructors where possible

---

Happy coding! 🚀
