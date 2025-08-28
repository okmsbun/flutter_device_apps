## 0.1.0

* First public release of `flutter_device_apps` (umbrella package).
* Exposes app-facing API for:

  * Listing installed apps (`listApps`)
  * Fetching single app details (`getApp`)
  * Launching apps (`openApp`)
  * (Optional) Listening to app changes via `appChanges` stream
* Android is the only supported platform (federated implementation via `flutter_device_apps_android`).
* Notes:

  * Queries launcher apps by default; does **not** request `QUERY_ALL_PACKAGES`.
  * Icons are optional (enable with `includeIcons`).
  * Event stream starts when there is at least one listener.
