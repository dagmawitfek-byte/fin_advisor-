# FinAdvisor – Personal Financial Advisor (Flutter)

A clean, modern, fully offline Personal Finance app built with Flutter.

## Features

- **Dashboard** – Balance overview, income/expense this month, recent transactions, goals preview
- **Transactions** – Add, edit, delete income & expenses with categories
- **Budgets** – Set monthly category budgets and track progress
- **Savings Goals** – Create goals and add money toward them
- **Reports** – Pie chart (spending by category) + Bar chart (last 6 months)
- Light / Dark mode (follows system)
- Fully offline (Hive local database)
- Material 3 design

## Getting Started

### Prerequisites
- Flutter 3.16+ (stable)
- Android Studio / VS Code with Flutter extension
- Android SDK (for building APK)

### Setup

```bash
cd fin_advisor
flutter pub get
```

### Run on device / emulator

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

The APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

---

## Build APK Online (No Android SDK needed)

This project includes a GitHub Actions workflow.

1. Create a new **Public** repository on GitHub named `fin_advisor`
2. Upload **all** the project files (keeping the exact folder structure)
3. Go to the **Actions** tab
4. Click **Build Flutter APK** → **Run workflow**
5. Wait 5–8 minutes
6. Download the APK from the **Artifacts** section

The workflow file is located at:
`.github/workflows/build.yml`

## Project Structure

```
lib/
├── main.dart
├── models/          # Transaction, Category, Budget, Goal + Hive adapters
├── providers/       # Riverpod state notifiers
├── screens/         # All UI screens
├── services/        # HiveService
├── theme/           # AppTheme
├── utils/           # Formatters
└── widgets/         # Reusable widgets
```

## Notes

- Default categories are seeded on first launch.
- All data is stored locally with Hive.
- To regenerate Hive adapters (if you change models):
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Future Improvements (easy to add)

- Recurring transactions
- Export to CSV / PDF
- Cloud sync (Firebase)
- Multi-currency
- AI spending insights
- Widgets & notifications

---

Built with ❤️ using Flutter + Riverpod + Hive + fl_chart
