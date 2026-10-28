git add .vscode/
git commit -m "Add VSCode configurations"
git push
flutter pub get
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter test
flutter run
