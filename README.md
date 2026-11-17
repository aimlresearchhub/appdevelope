# Food & Stories Flutter app

Flutter client for a Django food menu and authenticated news reader. The app
uses Provider for state, `http` for Django requests, and SharedPreferences for
the session token, theme preference, and locally remembered favorite IDs.

## Run against Django

The Android emulator reaches the development host at `10.0.2.2`, so the default
API base URL is `http://10.0.2.2:8000`. Pass a different origin when running on
a device or browser:

```shell
flutter run --dart-define=API_BASE_URL=http://192.168.1.25:8000
```

For an offline frontend demo without Django, enable the local demo account:

```shell
flutter run --dart-define=ENABLE_DEMO_LOGIN=true
```

Demo credentials are `demo` / `demo1234`. This debug-only mode supplies sample
food and article data and keeps favorites locally. It is disabled in release
builds and should not be used as real authentication.

In Django, allow the app origin through CORS/CSRF policy as appropriate and
serve the API over HTTPS outside local development. Android cleartext traffic
is enabled for the development server in
`android/app/src/main/AndroidManifest.xml`.

The client uses these defaults in `lib/config.dart`:

| Purpose | Endpoint |
| --- | --- |
| Food list | `GET /api/foods/` |
| Article list | `GET /api/articles/` |
| Login | `POST /api/auth/login/` |
| Register | `POST /api/auth/register/` |
| Toggle article favorite | `POST /api/articles/{id}/toggle_favorite/` |

Change those constants to match your Django URL configuration. List responses
may be a JSON array or a paginated object with a `results` or `items` array.
Food records use `id`, `name`, `price`, `rating`, `image`/`image_url`, and
optional `description`. Article records use `id`, `title`, `body`/`content`,
optional `summary`/`excerpt`, `image`/`image_url`, `is_favorite`, and
`favorites_count`. Login and registration return a token in `token`, `key`, or
`access`. Article requests use `Authorization: Token <token>`. Favorite
responses may return `is_favorite` and `favorites_count`; update the endpoint
path or response mapping in `lib/services/api_service.dart` if your API differs.

## Features

- Food list switches between a phone list and a responsive wide-screen grid.
- Searchable article list, article detail, and authenticated favorite toggles.
- Light/dark themes, persisted login, and login/register error snackbars.
- Profile page opens the camera and saves the chosen profile image path.
  Camera permission is requested in-app; the Android camera permission is
  declared in the manifest.

## Optional Firebase Analytics setup

Firebase is optional and is not initialized by default; the Django token flow
works without Firebase. To add Analytics for a viva/demo:

1. Install the FlutterFire CLI and log in to Firebase:
   `dart pub global activate flutterfire_cli`, then `firebase login`.
2. From the project root run `flutterfire configure` and select the Firebase
   project and platforms.
3. Add `firebase_core` and `firebase_analytics` with `flutter pub add`.
4. Initialize Firebase in `main()` with the generated
   `lib/firebase_options.dart` (`Firebase.initializeApp(options:
   DefaultFirebaseOptions.currentPlatform)`) before `runApp`.
5. Add a `FirebaseAnalytics` instance and log events such as login, article
   opens, and favorite changes.

Only the generated Firebase options file and the initialization/event calls
are optional; no Firebase configuration is required for the current app.

## Release APK

Configure `API_BASE_URL` for the network address your installed device can
reach, then run:

```shell
flutter build apk --release --dart-define=API_BASE_URL=https://your-api.example
```

The APK is written to
`build/app/outputs/flutter-apk/app-release.apk`. The current Android release
build uses the Flutter template's debug signing configuration; set up a private
release keystore before distributing the APK.
