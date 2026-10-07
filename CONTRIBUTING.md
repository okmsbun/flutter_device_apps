# Contributing

Bug reports and feature requests for all three packages belong in
[flutter_device_apps issues](https://github.com/okmsbun/flutter_device_apps/issues).
Small fixes can go straight to a pull request.

Fork the relevant repository, create a branch, and open your PR against `develop`.
Describe what changed and how you checked it. Maintainers handle `develop` → `main`.

For this Flutter package, use a Flutter SDK matching `pubspec.yaml` and run:

```sh
flutter pub get
dart format .
flutter analyze
flutter test
```

Android implementation changes belong in
[flutter_device_apps_android](https://github.com/okmsbun/flutter_device_apps_android).
API contract and model changes belong in
[flutter_device_apps_platform_interface](https://github.com/okmsbun/flutter_device_apps_platform_interface).
