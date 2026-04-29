# MindWell AI 🧠💚
### AI-Powered Mental Health Support Application

> **PUSL3190 Computing Project** — University of Plymouth  
> **Student:** Parana Karunasena | **Index:** 10952637  
> **Supervisor:** Ms. Chathurma Wijesinghe  
> **Degree:** BSc (Honours) Software Engineering

---

## 📖 Overview

MindWell AI is a mobile mental health support application built with Flutter and Firebase. It combines mood tracking, journaling with AI-powered sentiment analysis, standardized psychological assessments (PHQ-9 & GAD-7), mindfulness exercises, and localized crisis support into one privacy-focused platform designed for Sri Lankan university students and young professionals.

> ⚠️ **Disclaimer:** This application is a self-help tool only. It is **not** a substitute for professional mental health therapy or medical advice. In a crisis, please contact a helpline immediately.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **Authentication** | Email/password and Google OAuth via Firebase Auth |
| 😊 **Mood Tracking** | Daily mood logging with 10-emoji picker, streak counter, and trend chart |
| 📔 **Journal** | Encrypted journal entries with AI sentiment analysis (POSITIVE/NEUTRAL/NEGATIVE) |
| 📋 **PHQ-9 Assessment** | Standardized depression screening with auto-scoring and severity classification |
| 📋 **GAD-7 Assessment** | Standardized anxiety screening with auto-scoring and severity classification |
| 🧘 **Calm Hub** | 4-7-8 breathing exercise, 5-4-3-2-1 grounding, and daily affirmations |
| 🆘 **Crisis Support** | One-tap call cards for Sri Lankan helplines (NIMH, Sumithrayo, CCC, Police) |
| ⚙️ **Settings** | Data export (JSON), account deletion, notification toggles, privacy policy |

---

## 🏗️ System Architecture

```
Flutter App (Android · Dart)
    │
    ├── HTTPS/SDK ──→ Firebase Backend (Google Cloud · BaaS)
    │                   ├── Firebase Auth (Email + Google OAuth)
    │                   ├── Firestore (NoSQL · Encrypted)
    │                   └── Firebase Storage
    │
    └── HTTP ──→ VADER Service (Python · Flask)
                    ├── NLP Engine (VADER + NLTK)
                    └── POST /analyze endpoint
                            │
                            ↓
                    Data Layer (Encrypted at rest · GDPR-compliant)
                    ├── Users / Profiles
                    ├── Mood Entries
                    ├── Journal Entries
                    ├── Assessments
                    └── Settings
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile Frontend | Flutter 3.x (Dart) |
| Backend / BaaS | Firebase (Auth, Firestore, Storage) |
| AI / NLP | VADER Sentiment Analysis (Python) |
| Microservice | Flask (Python 3.11) |
| Charts | fl_chart |
| HTTP Client | http package |
| Version Control | Git / GitHub |

---

## 📋 Prerequisites

Make sure you have the following installed:

- [Flutter SDK 3.x](https://flutter.dev/docs/get-started/install) (stable channel)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or VS Code with Flutter extension
- [Python 3.11+](https://python.org/downloads)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Git](https://git-scm.com)
- Android Emulator or physical Android device

---

## 🚀 Setup & Installation

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/mindwell_ai.git
cd mindwell_ai
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

This project requires a Firebase project. Follow these steps:

**a) Create a Firebase project:**
1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Create a new project named `mindwell-ai`
3. Enable **Email/Password** and **Google** authentication under Authentication → Sign-in method
4. Create a **Firestore Database** in `asia-south1` region, start in test mode

**b) Connect Firebase to Flutter:**
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Select your `mindwell-ai` project and `android` platform. This generates `lib/firebase_options.dart`.

**c) Place `google-services.json`:**
Download from Firebase Console → Project Settings → Your Android App and place it at:
```
android/app/google-services.json
```

**d) Firestore Security Rules:**
In Firebase Console → Firestore → Rules, paste:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null
                         && request.auth.uid == userId;
    }
  }
}
```

### 4. Start the VADER Sentiment Microservice

Open a **separate terminal** and run:

```bash
cd vader_service
pip install -r requirements.txt
python app.py
```

The service runs at `http://localhost:5000`. Test it:
```bash
curl -X POST http://localhost:5000/health
# Expected: {"service": "MindWell VADER", "status": "ok"}
```

> **Note:** The Flutter app uses `http://10.0.2.2:5000` to reach localhost from the Android emulator.

### 5. Run the Flutter App

In a **new terminal**:

```bash
flutter run
```

---

## 🧪 Running Tests

```bash
flutter test
```

Expected output:
```
00:05 +56: All tests passed!
```

Test files are located in:
```
test/
├── widget_test.dart
├── unit/
│   ├── phq9_scorer_test.dart      # 18 tests
│   ├── gad7_scorer_test.dart      # 18 tests
│   └── sentiment_service_test.dart # 10 tests
└── widget/
    └── mood_tracker_test.dart     # 10 tests
```

---

## 📁 Project Structure

```
mindwell_ai/
├── lib/
│   ├── main.dart                        # App entry point
│   ├── firebase_options.dart            # Auto-generated Firebase config
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          # Color palette
│   │   │   ├── app_strings.dart         # UI text & helpline numbers
│   │   │   └── app_theme.dart           # ThemeData & typography
│   │   ├── services/
│   │   │   ├── auth_service.dart        # Firebase Auth
│   │   │   ├── firestore_service.dart   # Firestore CRUD
│   │   │   └── sentiment_service.dart   # HTTP calls to VADER
│   │   └── utils/
│   │       ├── phq9_scorer.dart         # PHQ-9 scoring logic
│   │       └── gad7_scorer.dart         # GAD-7 scoring logic
│   ├── models/
│   │   ├── mood_entry.dart
│   │   ├── journal_entry.dart
│   │   └── assessment_result.dart
│   └── features/
│       ├── auth/                        # Login, Register, Consent, Splash
│       ├── home/                        # Dashboard with mood stats & chart
│       ├── mood/                        # Mood tracker & history
│       ├── journal/                     # Journal with sentiment analysis
│       ├── assessment/                  # PHQ-9 & GAD-7 screens & results
│       ├── calm/                        # Breathing, grounding, affirmations
│       ├── help/                        # Crisis support & helplines
│       └── settings/                   # Profile, export, privacy, delete
│
├── vader_service/
│   ├── app.py                           # Flask API — POST /analyze
│   ├── requirements.txt
│   └── Dockerfile
│
├── test/
│   ├── unit/                            # PHQ-9, GAD-7, sentiment tests
│   └── widget/                         # Mood tracker widget tests
│
└── pubspec.yaml
```

---

## 🌿 Git Branch Strategy

```
main                                    # Production / release
└── develop                             # Integration branch
    ├── feature/sprint-1-auth-firebase  # ✅ Auth & Firebase
    ├── feature/sprint-2-mood-tracking  # ✅ Mood tracking
    ├── feature/sprint-3-journal-vader  # ✅ Journal & VADER
    ├── feature/sprint-4-assessments    # ✅ PHQ-9 & GAD-7
    ├── feature/sprint-5-calm-crisis    # ✅ Calm & Crisis
    ├── feature/sprint-6-privacy        # ✅ Settings & Privacy
    ├── feature/sprint-7-testing        # ✅ Unit & Widget tests
    └── feature/sprint-8-docs           # ✅ Documentation
```

---

## 🆘 Sri Lankan Crisis Helplines

| Organisation | Number |
|---|---|
| National Institute of Mental Health (NIMH) | 1926 |
| Sumithrayo | 0800 441 441 |
| CCC Sri Lanka | 011 2696 441 |
| Sri Lanka Police Emergency | 119 |

---

## 📦 Dependencies

```yaml
firebase_core: ^3.1.0
firebase_auth: ^5.1.0
google_sign_in: ^6.2.1
cloud_firestore: ^5.1.0
firebase_storage: ^12.1.0
fl_chart: ^0.68.0
http: ^1.2.1
url_launcher: ^6.3.0
cupertino_icons: ^1.0.8
```

---

## 🔒 Privacy & Security

- Journal entries are stored with user-isolated Firestore security rules
- All data is scoped to the authenticated user's UID
- Users can export all their data as JSON at any time
- Users can permanently delete their account and all associated data
- The app includes a mandatory consent screen on first registration
- No data is sold or shared with third parties

---

## 📚 References

- World Health Organization. (2022). *Mental Health Atlas Report*. WHO Press.
- Spitzer, R. L., Kroenke, K., & Williams, J. B. W. (1999). Validation of the PHQ-9. *Journal of General Internal Medicine, 14*(9), 606–613.
- Löwe, B., et al. (2008). Validation of the GAD-7. *Medical Care, 46*(3), 266–274.
- Hutto, C. J., & Gilbert, E. (2014). VADER: A parsimonious rule-based model for sentiment analysis. *AAAI Conference on Weblogs and Social Media*.
- Andersson, G., et al. (2019). Internet-delivered psychological treatments. *World Psychiatry, 18*(1), 20–28.

---

## 👨‍💻 Author

**Parana Karunasena**  
BSc (Honours) Software Engineering  
University of Plymouth | Plymouth Index: 10952637  
Supervised by Ms. Chathurma Wijesinghe

---

*MindWell AI — Your companion for mental wellness* 💚
