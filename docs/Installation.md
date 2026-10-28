# Install Flutter and Dart, then validate Web4ui

Flutter includes the Dart SDK, so you only need to install Flutter once. These instructions will help you install the stable SDK on your own computer and run the formatting, analysis, and test checks for `auraecosystem/Web4ui`.

Since your earlier repository work used Windows paths, I’ll start with Windows 10/11 using PowerShell, then include Linux/macOS alternatives.

## 1. Install the prerequisites

On Windows, install Git and make sure you have enough disk space for the SDK and dependencies.

1. Install [Git for Windows](https://git-scm.com/download/win?utm_source=chatgpt.com).
2. Install [Visual Studio Code](https://code.visualstudio.com/?utm_source=chatgpt.com) if you want an editor.
3. Open PowerShell and check Git:

```
git --version
```

You do not need to install Dart separately.

## 2. Download the stable Flutter SDK

[Flutter Logo PNG, AI, EPS, CDR, PDF, SVG - iconLogoVector](https://images.openai.com/static-rsc-4/JJVkBOaM-yYkbvYZam7aPIuvHiVU4njZfHouWfgeqAs4Uj6x4OVIVHm-3e1Q6Qavb77MjHu6XA5VoxLR7gODyuYc3RqGIXXjI8CQlRhuN7F31OaTLwH5Wz9Ilr9kwRnz_EKsqe_UasTaBtp_9wo2uuks1HVZO2DBU7zVz8NuL0U?purpose=inline)

Flutter — official installation guide

Choose Windows and the stable release channel.

[Open Flutter installation instructions](https://docs.flutter.dev/install?utm_source=chatgpt.com)

Open

1. Follow the Windows installation instructions to download the stable Flutter SDK bundle.
2. Extract the SDK to a short path without spaces, for example:
   ```
   C:\src\flutter
   ```
   The executable should then be at:
   ```
   C:\src\flutter\bin\flutter.bat
   ```
3. Add this directory to your Windows Path environment variable:
   ```
   C:\src\flutter\bin
   ```
   To do that, search Windows for Edit environment variables for your account, open `Path`, select New, add the directory, and save.
4. Close and reopen PowerShell so it loads the updated path.

Avoid extracting Flutter into `C:\Program Files` or a protected Windows directory, where permissions can complicate SDK updates.

## 3. Verify Flutter and Dart

Run these commands in the new PowerShell window:

```
flutter --version
dart --version
flutter doctor
```

Expected results:

- `flutter --version` reports a Flutter stable release.
- `dart --version` reports a Dart SDK version.
- `flutter doctor` reports the health of your development environment.

Warnings about Android Studio or Android toolchains are not necessarily blockers for running Dart formatting and Flutter unit/widget tests. If `flutter` is not recognized, verify that `C:\src\flutter\bin` is in `Path`, reopen PowerShell, and try again.

## 4. Get the Web4ui repository

Open PowerShell and run:

```
git clone https://github.com/auraecosystem/Web4ui.git
cd Web4ui
```

To check the existing PR #11 changes without modifying `main`, fetch the PR into a separate local branch:

```
git fetch origin pull/11/head:review/pr-11
git switch review/pr-11
```

Confirm the checked-out branch and latest commit:

```
git branch --show-current
git log -1 --oneline
```

The branch should report `review/pr-11`. If GitHub no longer exposes PR #11, fetch the branch directly instead:

```
git fetch origin fix/flutter-workspace-build-v2
git switch --track origin/fix/flutter-workspace-build-v2
```

## 5. Install dependencies and run all checks

Run these commands from the `Web4ui` directory, in order.

A. Fetch dependencies

```
flutter pub get
```

This resolves the dependencies declared in `pubspec.yaml`.

B. Check Dart formatting

```
dart format --output=none --set-exit-if-changed lib test
```

This checks formatting without rewriting files. If it fails because files need formatting, fix them with:

```
dart format lib test
```

Then rerun the formatting check.

C. Run static analysis

```
flutter analyze
```

Fix reported errors and warnings as appropriate, then rerun the command.

D. Run tests

```
flutter test
```

This executes the project's Flutter tests, including widget tests.

## 6. Run the app (optional)

If the checks pass, start the Flutter app using:

```
flutter run -d windows
```

For this target, you may also need Visual Studio with the Desktop development with C++ workload installed. To see available targets, run:

```
flutter devices
```

## 7. Save and report the results

Use this command to see which files were changed by formatting:

```
git status --short
git diff --check
git diff
```

Formatting can modify files, so inspect the diff before committing. If you want to save verified fixes on the review branch:

```
git add lib test
git commit -m "Fix Dart formatting and validation"
```

This commits only the staged changes on your current branch. Do not merge into `main` as part of this validation.

## Alternative: Linux or macOS

Use the official [Flutter installation guide](https://docs.flutter.dev/install?utm_source=chatgpt.com) to install the stable SDK for your operating system, add its `bin` directory to `PATH`, and verify `flutter --version` and `dart --version`. Then use the same repository and validation commands above; the commands are the same in Bash.

## What to send me afterward

Paste the output of these four commands:

```
flutter --version
dart --version
flutter analyze
flutter test
```

If formatting fails, include its output too. I can use the actual errors to help repair Web4ui's existing PR branch without inventing test results or reintroducing the reverted metrics work.
