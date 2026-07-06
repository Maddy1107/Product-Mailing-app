# Product Mail - Flutter Product Selector App

A modern, responsive, and cross-platform Flutter application built to streamline product status reporting for field agents and teams. The app allows users to search and select products from a local database, customize reports based on whether items are "Required" or "Received", and immediately generate a structured email report or copy the draft to their clipboard.

---

## 📸 Screen Preview

### Startup Welcome & Name Setup
Upon first opening the application, the user is greeted with a setup dialog to configure their profile name. This name is used to sign off the emails.

![Startup Name Setup Dialog](screenshots/01_name_prompt.png)

---

## ✨ Key Features

- **👤 User Profile Customization**
  - Prompted for name entry on first startup (NamePromptDialog), which is persisted locally using `shared_preferences`.
  - Profile initials are dynamically calculated and shown as a custom avatar.
  - Ability to change/edit the user name directly from the profile dropdown menu on the top AppBar.
  
- **🔍 Fast Product Catalog Search**
  - Loads a list of products from a local JSON database (`assets/product_list.json`).
  - Implements real-time search filtering on the product catalog.
  
- **📦 Interactive Selection System**
  - Smooth animation transitions (`AnimatedSwitcher`, slide & fade curves) when selecting and deselecting products.
  - Keeps track of selection states, dynamically removing items from the available list when selected and restoring them upon removal.
  
- **✉️ Dynamic Mail Composer**
  - Toggles between **Required** (green themed) and **Received** (orange themed) reporting modes.
  - Auto-formats the email subject and body dynamically:
    - Lists all selected products sequentially in a numbered layout.
    - Tailors sign-off greetings using the saved user profile name.
  
- **⚡ Action Integration**
  - **Copy Content**: Copies the formatted email template to the clipboard in one click.
  - **Send Email**: Automatically opens the device's native mail app (`url_launcher` via `mailto:`) pre-populated with the subject and body.

---

## 🛠️ Architecture & Directory Layout

The codebase follows a modular structure separated into controllers, pages, custom dialogs, and UI widgets:

```
product_selector_app/
├── assets/
│   ├── icon/                      # App launcher icons
│   └── product_list.json          # Pre-loaded product list database
├── lib/
│   ├── controllers/
│   │   └── product_controller.dart # Handles loading, filtering, and selection state
│   ├── dialogs/
│   │   ├── mail_preview_dialog.dart # Renders the email preview and triggers copy/mailto actions
│   │   └── name_prompt_dialog.dart  # Prompts user to input and save their name
│   ├── pages/
│   │   └── home_page.dart         # Main layout containing the dashboard UI
│   ├── widgets/
│   │   ├── available_products_list.dart
│   │   ├── product_list_item.dart
│   │   ├── product_search_bar.dart
│   │   └── selected_products_section.dart
│   └── main.dart                  # App configuration & Entry point (Material 3 Dark Theme)
├── pubspec.yaml                   # Flutter dependencies configuration
└── analysis_options.yaml          # Code styling/lint configuration rules
```

---

## 🚀 Getting Started

### Prerequisites
Make sure you have [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Installation

1. Clone or navigate to the repository folder:
   ```bash
   cd Product-Mailing-app/product_selector_app
   ```

2. Fetch the required Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Ensure you have connected devices or configured desktop platforms:
   ```bash
   flutter devices
   ```

---

## 💻 Running the App

Run the project on your preferred target device:

#### Run on Windows Desktop
```bash
flutter run -d windows
```

#### Run on Web (Google Chrome)
```bash
flutter run -d chrome
```

#### Run Web Server (Headless/Network)
```bash
flutter run -d web-server --web-port 8080 --web-hostname 127.0.0.1
```

#### Run on Android/iOS
```bash
flutter run
```

---

## 📦 Dependencies Used

- **`shared_preferences`**: Persists the user name locally across app launches.
- **`url_launcher`**: Launches external mail app via `mailto:` protocol.
- **`cupertino_icons`**: Material design icons integration.
- **`flutter_launcher_icons`**: Generates multi-platform launcher icons.
