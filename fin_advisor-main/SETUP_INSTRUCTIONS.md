# FinAdvisor SMS Features - Setup Instructions

## Prerequisites
- Flutter 3.16+ (stable channel)
- Android SDK API 21+
- Device with SMS capability
- Bank account with SMS alerts enabled

## Installation Steps

### 1. Clone the Repository
```bash
git clone https://github.com/samibdrhr/fin_advisor.git
cd fin_advisor
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Hive Adapters
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App

#### On Emulator
```bash
flutter emulators --launch Pixel_4_API_30  # or your emulator
flutter run
```

#### On Physical Device
```bash
flutter run
```

### 5. Grant Permissions
When the app launches:
1. A permission dialog will appear
2. Tap "Allow" to grant SMS reading permissions
3. App will scan recent bank SMS messages
4. If debit found, categorization dialog appears

## Building APK

### Release APK (Recommended)
```bash
flutter build apk --release
```

APK location: `build/app/outputs/flutter-apk/app-release.apk`

### Debug APK
```bash
flutter build apk
```

APK location: `build/app/outputs/flutter-apk/app-debug.apk`

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

Bundle location: `build/app/outputs/bundle/release/app-release.aab`

## Installation on Device

### Using ADB
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Manual Installation
1. Transfer APK to your device
2. Open file manager
3. Tap the APK file
4. Tap "Install"
5. Grant permissions when prompted

## Testing SMS Features

### Simulate Bank SMS (On Emulator)
1. Open Android Emulator
2. Go to settings
3. Find "SMS" or "Messages" app
4. Send a test message from another number with this format:
   ```
   Telebirr: Debit alert. Amount: 500 ETB. Balance: 2500 ETB
   ```

### Test on Real Device
1. Ask your bank to send a test SMS
2. Launch FinAdvisor
3. Grant SMS permission
4. Check if balance card shows your balance
5. Wait for next debit SMS to test dialog

## Configuration

### Adjust Bank Keywords
Edit `lib/models/sms_message.dart`:
```dart
bool isFromBank() {
  final bankKeywords = [
    'your_bank_name', // Add your bank here
    'telebirr',
    'awash',
    // ...
  ];
  return bankKeywords.any((keyword) => 
    address.toLowerCase().contains(keyword) || 
    body.toLowerCase().contains(keyword)
  );
}
```

### Change SMS Regex Patterns
Edit patterns in `lib/models/sms_message.dart`:
```dart
double? extractBalance() {
  final balancePattern = RegExp(
    r'your_custom_pattern_here'
  );
  // ...
}
```

## Troubleshooting

### Build Fails
```bash
# Clean build
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### SMS Permission Not Granted
1. Check Android version (requires API 21+)
2. Manually grant in Settings → Apps → Permissions
3. Restart app

### No Balance Showing
- Verify bank SMS format matches regex patterns
- Check SMS sender contains bank keywords
- Test with a known SMS format

### App Crashes on Startup
1. Check logcat: `flutter logs`
2. Ensure all dependencies are installed
3. Try `flutter pub get` again

## Development Tips

### Enable Debugging
Add to your terminal:
```bash
flutter run -v  # Verbose output
```

### View Logs
```bash
flutter logs
```

### Test SMS Service
Create a simple test in `main.dart`:
```dart
import 'package:fin_advisor/services/sms_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final smsService = SmsService();
  final bankSms = await smsService.fetchBankSms();
  print('Found ${bankSms.length} bank SMS messages');
  for (var sms in bankSms) {
    print('From: ${sms.address}');
    print('Amount: ${sms.extractAmount()}');
    print('Balance: ${sms.extractBalance()}');
  }
}
```

## Performance Optimization

### Initial Load
- SMS scanning on first launch may take 2-3 seconds
- Subsequent launches are instant (cached)
- Large SMS history (1000+) may increase load time

### Memory Usage
- App uses ~50-100 MB RAM on average
- SMS parsing is done in-memory
- No SMS data persisted unless saved as transaction

## Next Steps

1. ✅ Customize bank keywords for your banks
2. ✅ Test with real bank SMS
3. ✅ Adjust regex patterns if needed
4. ✅ Build and distribute APK
5. ✅ Gather user feedback

## Support

For help:
- Check SMS_FEATURES.md for detailed feature docs
- Review code comments in relevant files
- Test with sample SMS formats
- Enable verbose logging for debugging
