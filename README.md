# WithYou - Couples Habit Tracking App

A clean, simple Flutter MVP for couples to build habits together through shared habits, daily check-ins, point scoring, and monthly fun challenges.

## Features

### ✅ Authentication
- Email & Password authentication
- Google Sign-In
- User profiles with name, email, and couple pairing

### 💑 Couple Pairing
- Create a couple and generate a unique 6-digit invite code
- Join a couple using an invite code
- Each couple has exactly 2 users

### 📋 Habit Management
- Create shared habits with custom names
- Set frequency (daily/weekly)
- Assign points to each habit
- Both partners see the same habit list

### ✨ Daily Habit Logging
- Mark habits as completed once per day
- Prevent duplicate logs for the same day
- Track completion status visually

### 🏆 Points System
- Earn points for each completed habit
- Monthly point aggregation per user
- Automatic monthly reset (history preserved)

### 📊 Leaderboard
- View both partners' monthly points
- See progress indicators
- Current leader highlighted

### 🎉 Monthly Winner
- Automatic winner detection
- Celebration screen with random dare/question
- Fun challenges from Firestore

## Tech Stack

- **Flutter**: Latest stable version
- **Firebase Auth**: Email + Google authentication
- **Cloud Firestore**: Real-time database
- **GetX**: State management and routing
- **Material 3**: Modern UI design

## Architecture

Clean architecture with clear separation of concerns:

```
lib/
├── core/
│   ├── bindings/         # GetX dependency injection
│   ├── constants/        # App constants
│   ├── routes/          # Route definitions
│   └── theme/           # App theme (Material 3)
├── data/
│   ├── models/          # Data models with Firestore serialization
│   └── services/        # Firebase services (Auth, Firestore)
└── presentation/
    ├── controllers/     # GetX controllers (state management)
    └── screens/         # UI screens
```

## Setup Instructions

### 1. Prerequisites
- Flutter SDK (3.9.2 or higher)
- Firebase account
- Android Studio / Xcode for mobile development

### 2. Firebase Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named "WithYou"
3. Enable Google Analytics (optional)

#### Enable Authentication
1. Go to Authentication → Sign-in method
2. Enable **Email/Password**
3. Enable **Google** sign-in

#### Create Firestore Database
1. Go to Firestore Database
2. Create database in **production mode** (or test mode for development)
3. Choose a location

#### Add Firebase to Your App

**For Android:**
1. Add Android app in Firebase Console
2. Download `google-services.json`
3. Place it in `android/app/`
4. Follow Firebase setup instructions

**For iOS:**
1. Add iOS app in Firebase Console
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`
4. Follow Firebase setup instructions

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run the App

```bash
flutter run
```

## Firestore Data Structure

### Collections

#### `users`
```javascript
{
  "userId": "auto-generated-id",
  "name": "John Doe",
  "email": "john@example.com",
  "coupleId": "couple-id-reference",
  "createdAt": Timestamp
}
```

#### `couples`
```javascript
{
  "coupleId": "auto-generated-id",
  "inviteCode": "123456", // 6-digit code
  "userIds": ["user-id-1", "user-id-2"],
  "createdAt": Timestamp
}
```

#### `habits`
```javascript
{
  "habitId": "auto-generated-id",
  "coupleId": "couple-id-reference",
  "name": "Morning workout",
  "frequency": "daily", // or "weekly"
  "points": 10,
  "createdAt": Timestamp
}
```

#### `habitLogs`
```javascript
{
  "logId": "auto-generated-id",
  "userId": "user-id-reference",
  "habitId": "habit-id-reference",
  "date": Timestamp, // Start of day
  "points": 10,
  "createdAt": Timestamp
}
```

#### `dares`
```javascript
{
  "dareId": "auto-generated-id",
  "content": "Cook a romantic dinner together",
  "type": "dare" // or "question"
}
```

### Firestore Indexes

Create composite indexes for:

1. **habitLogs** collection:
   - `userId` (Ascending) + `habitId` (Ascending) + `date` (Ascending)
   - `userId` (Ascending) + `date` (Ascending)

## Sample Firestore Queries

### Get habits for a couple:
```dart
FirebaseFirestore.instance
  .collection('habits')
  .where('coupleId', isEqualTo: coupleId)
  .orderBy('createdAt', descending: false)
  .snapshots();
```

### Check if habit logged today:
```dart
FirebaseFirestore.instance
  .collection('habitLogs')
  .where('userId', isEqualTo: userId)
  .where('habitId', isEqualTo: habitId)
  .where('date', isGreaterThanOrEqualTo: startOfDay)
  .where('date', isLessThan: endOfDay)
  .get();
```

### Get monthly points:
```dart
FirebaseFirestore.instance
  .collection('habitLogs')
  .where('userId', isEqualTo: userId)
  .where('date', isGreaterThanOrEqualTo: startOfMonth)
  .where('date', isLessThan: endOfMonth)
  .get();
```

## Seeding Sample Data

To add sample dares/questions to your Firestore database, you can use the Firebase Console or run this code:

```dart
final dares = [
  {'content': 'Cook a romantic dinner together', 'type': 'dare'},
  {'content': 'Plan a surprise date night', 'type': 'dare'},
  {'content': 'What\'s your favorite memory of us?', 'type': 'question'},
  {'content': 'Where would you like to travel next?', 'type': 'question'},
];

for (var dare in dares) {
  await FirebaseFirestore.instance
    .collection('dares')
    .add(dare);
}
```

## Screens Overview

### 1. Login Screen (`/login`)
- Email/Password authentication
- Google Sign-In button
- Toggle between Sign In and Sign Up

### 2. Couple Setup Screen (`/couple-setup`)
- Choose to create or join a couple

### 3. Create Couple Screen (`/create-couple`)
- Generate unique 6-digit invite code
- Copy code to clipboard
- Wait for partner to join

### 4. Join Couple Screen (`/join-couple`)
- Enter partner's invite code
- Validate and join couple

### 5. Home Screen (`/home`)
- View all shared habits
- Mark habits as complete
- See today's completion status
- Navigate to leaderboard
- Add new habits

### 6. Add Habit Screen (`/add-habit`)
- Enter habit name
- Select frequency (daily/weekly)
- Set point value
- Create habit

### 7. Leaderboard Screen (`/leaderboard`)
- View both partners' monthly points
- See progress bars
- Identify current leader
- Navigate to winner celebration

### 8. Winner Screen (`/winner`)
- Celebrate monthly winner
- Display random dare/question
- Return to leaderboard

## Controllers (GetX)

### AuthController
- Manages authentication state
- Handles sign in/up/out
- Navigates based on auth state

### CoupleController
- Manages couple data
- Creates/joins couples
- Loads couple users

### HabitController
- Manages habits list
- Creates/deletes habits
- Logs habit completion
- Tracks completion status

### LeaderboardController
- Calculates monthly points
- Determines winner
- Loads winner dares

## Color Palette (Material 3)

- **Primary**: #FF9B9B (Warm pink)
- **Secondary**: #FFD6A5 (Soft orange)
- **Accent**: #FDFFB6 (Light yellow)
- **Background**: #FFFAF0 (Cream)
- **Card**: #FFFFFF (White)
- **Success**: #8BC34A (Green)
- **Error**: #E57373 (Red)

## Firebase Security Rules

Add these rules to your Firestore:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Couples can only be read/written by members
    match /couples/{coupleId} {
      allow read: if request.auth != null && 
        request.auth.uid in resource.data.userIds;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        request.auth.uid in resource.data.userIds;
    }
    
    // Habits can be read/written by couple members
    match /habits/{habitId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Habit logs can only be created by the user
    match /habitLogs/{logId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
    }
    
    // Dares are read-only
    match /dares/{dareId} {
      allow read: if request.auth != null;
    }
  }
}
```

## Future Enhancements (Not in MVP)

- Push notifications
- Chat between couples
- Photo sharing
- Subscription/Premium features
- Analytics dashboard
- Multi-couple support
- Habit streaks
- Badges and achievements

## Troubleshooting

### Firebase not initialized
Make sure you've run `Firebase.initializeApp()` in `main()` before running the app.

### Google Sign-In not working on Android
1. Add SHA-1 fingerprint to Firebase Console
2. Download updated `google-services.json`

### Firestore permission errors
Check your security rules and ensure they match the rules provided above.

## License

This project is for educational purposes.

---

Built with ❤️ using Flutter & Firebase
