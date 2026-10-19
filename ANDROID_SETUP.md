# Android setup notes

Create the platform scaffolding with `flutter create .` from this directory if the `android/` folder is not present.

Then edit `android/app/src/main/AndroidManifest.xml`:
- Set the application label to `SNJ Devfolio`.
- Keep the default Flutter activity configuration unless you have a specific reason to change it.

No permissions are required for the current features. The app launches external URLs and the user's email app.
