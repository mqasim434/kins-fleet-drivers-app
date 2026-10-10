# Google Play release — KINS Chauffeur

Package: `com.kins.logistics.driver`  
Firebase: **`kins-logistics`**  
Version: see `pubspec.yaml` (`1.0.0+1` for first upload)

## 1. Firebase Blaze (required for production)

Spark daily caps block photo saves when exhausted. Upgrade before Production:

1. Open [Firebase Usage & billing — kins-logistics](https://console.firebase.google.com/project/kins-logistics/usage/details)
2. Choose **Modify plan** → **Blaze**
3. Link a billing account / payment method
4. Optionally set a budget alert (e.g. €25/month)

Confirm Firestore rules stay deployed:

```bash
cd ../kins-fleet-dashboard
npx -y firebase-tools@latest deploy --only firestore:rules --project kins-logistics
```

## 2. Upload signing (local, gitignored)

Already prepared on the build machine:

- `android/upload-keystore.jks` (alias `upload`)
- `android/key.properties` (passwords — keep in a password manager; never commit)

Release SHA-1 / SHA-256 are registered on the Firebase Android app  
`1:871386815586:android:e5438154a47cc74b50c53b`.

After Play App Signing, also add the **App signing key** certificate hashes from Play Console → Setup → App integrity into Firebase.

## 3. Build the App Bundle

```bash
flutter pub get
flutter build appbundle --release --dart-define-from-file=.env.json
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Optional device smoke test:

```bash
flutter build apk --release --dart-define-from-file=.env.json
```

## 4. Play Console checklist

1. [Play Console](https://play.google.com/console) → create or open **KINS Chauffeur**
2. Package name must be **`com.kins.logistics.driver`**
3. **Store listing** (NL recommended):
   - Short description: chauffeur-app voor diensten, bussen en wagenparkfoto's
   - Full description: login via KINS-account (geen publieke registratie); diensten, busfoto's, schade, klokken waar toegestaan
   - Icon: `assets/logo/playstore.png`
4. **Data safety**: account; location (clock-in); photos/camera; data used for app functionality; no sale of data
5. **Content rating** questionnaire (utility / productivity)
6. Upload AAB to **Internal testing** → test with a driver account
7. Promote to **Production** when smoke tests pass
8. Enable **Play App Signing** (upload key = local keystore)

## 5. Post-release smoke test

- Login: `users/{uid}` with `role: driver`, `status: active`, `driverId` set
- Bus photos: ImageKit + Firestore `busPhotos` document
- Dashboard Photos page shows the new photo
