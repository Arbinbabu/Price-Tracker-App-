# Price Tracker

A Flutter + Firebase app that tracks Daraz Nepal prices with automated scraping and notifications.

## Requirements
- Flutter 3.x (`flutter doctor` should report no critical issues)
- Dart SDK compatible with Flutter 3.x
- Python 3.11
- Firebase project (Auth, Firestore, Functions, Messaging enabled)

## Setup
1. Clone the repository.
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Configure Firebase for Flutter (`google-services.json` / `GoogleService-Info.plist`).
4. Install Python dependencies for functions:
   ```bash
   cd functions
   pip install -r requirements.txt
   ```
5. Deploy Firestore rules/indexes and functions via Firebase CLI.

## Run
```bash
flutter run
```

## Cloud Functions
- `add_product_http`: HTTP endpoint to add + scrape products.
- `scheduled_price_update`: scheduler-triggered daily scraping and history updates.
