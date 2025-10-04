Provokely Mobile MVP

Run locally (Linux dev):

1) Install Flutter (stable) and Android SDK.
2) From repo root, scaffold platforms once:
   flutter create .
3) Configure deep links and iOS/Android URL scheme:
   bash scripts/config_platforms.sh
4) Run with API base:
   flutter run --dart-define=API_BASE_URL=https://provokely.com --dart-define=ENABLE_FCM=false

Notes
- Set ENABLE_FCM=true only after adding Firebase files (Android/iOS). Without them, keep false.
- iOS build requires a macOS host. CI workflows generate artifacts.


