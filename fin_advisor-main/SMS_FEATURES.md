# FinAdvisor SMS Integration Features

## Overview
FinAdvisor now automatically reads bank SMS messages and helps you categorize debit transactions in real-time.

## Features Implemented

### 1. **Automatic SMS Reading**
- App requests READ_SMS permission on startup
- Scans device SMS for messages from Ethiopian banks:
  - Telebirr
  - Commercial Bank of Ethiopia (CBE)
  - Awash Bank
  - Dashen Bank
  - Abysinia Bank
  - Oromia Bank
  - NIB International
  - And other banks with standard SMS formats

### 2. **Bank Balance Display**
- Shows latest account balance from recent bank SMS
- Displayed on the Dashboard in a dedicated card
- Updates when new bank messages arrive
- Supports balance extraction from SMS text

### 3. **Debit Transaction Detection**
- Automatically detects debit/withdrawal messages
- Triggers popup dialog on first app launch or when new debit SMS arrives
- Shows transaction amount extracted from SMS

### 4. **Interactive Debit Dialog**
When a debit is detected, users can:
- ✅ Select purpose from quick options:
  - Food & Groceries
  - Transportation
  - Utilities
  - Entertainment
  - Shopping
  - Medical
  - Education
  - Other
- ✅ Select a category (uses existing expense categories)
- ✅ Enter custom purpose description
- ✅ Save transaction to app database

### 5. **Transaction Auto-Import**
- Debit transactions are automatically saved to Hive database
- Linked to expense categories for better tracking
- Transaction notes include original SMS for reference
- Appears in Recent Transactions and reports
- Maintains full balance calculations

## How to Use

### First Time Setup
1. Launch the app
2. Grant SMS reading permission when prompted
3. App scans recent bank SMS messages
4. If a debit transaction is found, a dialog appears
5. Select the purpose and category
6. Tap "Save" to add to your transactions

### Auto-Detection of New Debits
- App listens for new incoming SMS in background
- When a bank SMS with debit keywords arrives, dialog shows automatically
- User categorizes the transaction immediately

### Viewing Bank Balance
- Navigate to Dashboard (Home tab)
- Look for "Latest Bank Balance" card
- Shows the most recent balance from bank SMS
- Displayed alongside your app's calculated balance

## Technical Details

### Files Added/Modified

#### New Files:
1. **lib/models/sms_message.dart**
   - SmsMessage class to parse SMS data
   - Methods to detect bank messages
   - Amount and balance extraction

2. **lib/services/sms_service.dart**
   - SMS reading and permission handling
   - Bank message filtering
   - Balance and debit detection

3. **lib/services/sms_listener.dart**
   - App initialization logic
   - Dialog triggering on startup
   - Background SMS listener

4. **lib/providers/sms_provider.dart**
   - Riverpod providers for SMS data
   - Reactive state management

5. **lib/widgets/balance_card.dart**
   - UI widget showing bank balance
   - Loading and error states

6. **lib/widgets/debit_dialog.dart**
   - Interactive debit categorization dialog
   - Category selection
   - Transaction saving logic

#### Modified Files:
1. **lib/main.dart**
   - Added SMS listener initialization
   - Changed to StatefulWidget for lifecycle management

2. **lib/screens/dashboard_screen.dart**
   - Integrated BalanceCard widget
   - Shows latest bank balance

3. **pubspec.yaml**
   - Added `telephony: ^0.2.0` package
   - Added `permission_handler: ^11.3.1` package

4. **android/app/src/main/AndroidManifest.xml**
   - Added READ_SMS permission
   - Added RECEIVE_SMS permission
   - Added READ_CONTACTS permission

### Permissions Required (Android)
```xml
<uses-permission android:name="android.permission.READ_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_CONTACTS"/>
```

## SMS Format Detection

The app uses regex patterns to extract data from SMS:

### Balance Pattern
```regex
(?:balance|bal)[:\s]*([0-9,]+(?:\.[0-9]{2})?)
```

### Amount Pattern
```regex
(?:amount|birr|etb)[:\s]*([0-9,]+(?:\.[0-9]{2})?)
```

### Debit Keywords
- debit
- withdrawal
- payment

## Example SMS Formats

### Telebirr
```
Telebirr: You have received a debit alert. Amount: 500.00 ETB. Balance: 2500.00 ETB
```

### CBE
```
CBE Alert: Withdrawal of 1000 ETB. Remaining balance: 5000 ETB
```

### Generic Bank
```
Bank Debit: Amount 250 Birr. Your balance is 8750.50
```

## Customization

### Add More Banks
Edit `lib/models/sms_message.dart` and update the `bankKeywords` list:

```dart
final bankKeywords = [
  'your_bank_name',
  // ... other keywords
];
```

### Change Default Categories
Edit the quick purpose selection in `lib/widgets/debit_dialog.dart`:

```dart
final List<String> _commonPurposes = [
  'Your Purpose',
  // ... other purposes
];
```

### Modify Regex Patterns
Update patterns in `lib/models/sms_message.dart`:

```dart
final balancePattern = RegExp(r'your_pattern_here');
```

## Troubleshooting

### "SMS permission denied" message
- Open Settings → Apps → FinAdvisor → Permissions
- Enable SMS permission
- Restart the app

### No bank balance showing
- Ensure you have recent bank SMS messages
- Check that SMS sender name contains bank keywords
- Verify regex patterns match your bank's SMS format

### Debit dialog not appearing
- Confirm READ_SMS permission is granted
- Check if recent SMS contains debit keywords
- Restart the app to scan latest messages

## Future Enhancements

- 🚀 Recurring transaction detection
- 🚀 Multi-account support
- 🚀 ML-based automatic categorization
- 🚀 Export SMS history
- 🚀 Custom SMS parsing rules
- 🚀 Background service for 24/7 monitoring
- 🚀 Notification on large transactions
- 🚀 SMS backup to cloud

## Security & Privacy

✅ All SMS data is processed locally on your device
✅ No SMS data is sent to external servers
✅ No SMS is stored unless you save it as a transaction
✅ Permission is requested before accessing SMS
✅ Uses Android's native SMS reading APIs

## Support

For issues or feature requests, please report on GitHub:
https://github.com/samibdrhr/fin_advisor
