# How to Install Flutter on Windows

Follow these steps to set up Flutter and get the "Hostel Smart Leave" app running.

## 1. Install Git
Flutter requires Git for many operations.
1. Download Git from [git-scm.com](https://git-scm.com/download/win).
2. Run the installer and keep the default settings.
3. Open a terminal and type `git --version` to confirm it's installed.

## 2. Download the Flutter SDK
1. Go to the [Flutter Windows install page](https://docs.flutter.dev/get-started/install/windows).
2. Download the latest stable version (a `.zip` file).
3. Extract the `.zip` file to a permanent folder (e.g., `C:\src\flutter`). 
   > [!IMPORTANT]
   > Do **not** install Flutter in a path that contains special characters or spaces, or in `C:\Program Files`.

## 3. Update Your Path
1. In the Windows Start Search bar, type `env` and select **Edit the system environment variables**.
2. Click **Environment Variables**.
3. Under **User variables**, find the `Path` variable and click **Edit**.
4. Click **New** and add the full path to the `bin` folder (e.g., `C:\src\flutter\bin`).
5. Click **OK** on all windows.

## 3. Verify Installation
1. Open a **new** terminal (Command Prompt or PowerShell).
2. Run the command: `flutter doctor`
3. This will check for missing dependencies (like Android Studio or Git).

## 4. Run the Project
Once `flutter` is working in your terminal:
1. Come back to this chat and tell me the path where you installed it.
2. I will then run:
   ```bash
   cd frontend
   flutter create . --platforms=android
   flutter run
   ```

> [!TIP]
> If you have **Android Studio** installed, make sure to install the "Flutter" and "Dart" plugins from the Marketplace!
