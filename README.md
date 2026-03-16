# APIU Bulletin App

A digital companion for the APIU church community, reimagined as a modern, cross-platform mobile and web app built with Flutter. This application is designed to streamline service management, community engagement, and information dissemination, creating a single source of truth for all church-related activities.

---

## 📋 Core Features

### 1. The Living Sabbath Bulletin

-   **Dynamic Schedule:** A real-time timeline for Friday evening and Saturday services. Admins can instantly update service times, program items, and responsible personnel, ensuring the entire community has the most current information.
-   **Localized Sabbath Timings:** The app automatically calculates and displays accurate sunset times based on the user's **local timezone**, marking the sacred start and end of the holy day.
-   **Sabbath Moments:** At the beginning and end of each Sabbath, the app presents a special screen with a prayer, a devotional thought, or uplifting spiritual content to frame the holy hours.
-   **Transparent Personnel Grid:** A clear and organized view of who is leading each part of the service, from the main speaker and worship leaders to the ushers and AV team.
-   **Community Announcements:** A dedicated space for encouraging messages, important church notices, and community news.

### 2. Service & Volunteer Management

-   **Sabbath Duty Volunteer Applications:** Members can browse a list of open service roles for the upcoming Sabbath (e.g., Usher, Deacon, Music, AV Team) and submit an application to volunteer.
-   **Admin Approval Workflow:** Church leadership has a dashboard to review volunteer applications. They can approve or decline requests in real-time, ensuring all service positions are filled by willing hearts.

### 3. Visitor Engagement

-   **Easy Check-in:** Visitors can easily join the platform just by entering their name, lowering the barrier for first-time engagement.
-   **Admin Awareness:** Church leadership receives instant updates when new visitors arrive, enabling a warm and timely welcome.

### 4. Giving & Offerings

-   **Tithe Portal:** Clear, accessible information on church bank accounts and QR codes for easy, digital giving.
-   **Biblical Encouragement:** The section is integrated with scriptures focused on stewardship and the blessings of generosity.

### 5. AI-Powered Assistance

-   **Announcement Drafter:** Uses the Google Gemini API to help admins turn simple bullet points into warm, inviting, and well-written announcements.
-   **Sabbath Reminder Generator:** Creates uplifting and creative notifications to welcome the Sabbath, sent to all users who opt-in.

---

## 🎨 Design Philosophy

-   **Modern & Clean:** The UI is inspired by modern design trends, emphasizing clean lines, generous spacing, and a visually balanced layout.
-   **Typography:** We use `google_fonts` to create a strong visual hierarchy:
    -   **Poppins** for headings, giving a modern and bold feel.
    -   **Source Sans Pro** for body text, ensuring excellent readability.
-   **Color Palette:** The app features a switchable dark and light theme with a vibrant cyan (`#00C6FF`) as the primary accent, creating a visually engaging experience.
-   **Consistency:** A centralized `ThemeData` object in `main.dart` ensures that all components, from cards to buttons, share a consistent and polished look and feel.

---

## 🛠 Technical Architecture

-   **Framework & Language:** Built with **Flutter** and **Dart**, enabling a single, high-performance codebase for iOS, Android, and web.
-   **State Management:** **Provider** is used for its simplicity and effectiveness in managing app-wide state, such as theme changes.
-   **Navigation:** **go_router** provides a robust, declarative routing solution, perfect for handling complex navigation flows and deep linking.
-   **AI Integration:** The **Google Generative AI Dart SDK** is integrated to power all Gemini-based features, running securely and efficiently.
-   **Data Persistence:** The app currently uses in-memory data for rapid prototyping (`bulletin_data.dart`). It is architected to easily integrate with a local database like **Hive** or a backend service like **Firebase** for production.
-   **Future Integrations:** The architecture is prepared for future enhancements, including:
    -   `flutter_local_notifications` for Sabbath reminders.
    -   `qr_flutter` for displaying giving QR codes.

---

## 🧪 Code Quality & Testing

This project is committed to maintaining a high standard of code quality and reliability. Our testing strategy will include:

-   **Unit Tests:** For business logic, services, and state management classes.
-   **Widget Tests:** To verify the UI of individual widgets and ensure they respond correctly to user interaction and state changes.
-   **Integration Tests (Future):** To test complete user flows and interactions between different parts of the app.

---

## 📂 Project Structure

The codebase follows a **feature-first** architecture, where each feature is a self-contained module. This promotes separation of concerns and makes the project easier to scale.

```
lib/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── guest_screen.dart
│   │           └── login_screen.dart
│   ├── bulletin/
│   │   ├── data/
│   │   │   └── bulletin_data.dart
│   │   └── presentation/
│   │       ├── screens/
│   │       │   ├── bulletin_screen.dart
│   │       │   └── edit_bulletin_screen.dart
│   │       └── widgets/
│   │           └── bulletin_item_model.dart
│   ├── giving/
│   │   └── presentation/
│   │       └── screens/
│   │           └── giving_screen.dart
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_screen.dart
└── main.dart
```

---

## 🚀 Getting Started

### Demo Credentials

-   **Admin Access:** `username: admin`, `password: admin`
-   **Member Access:** Use any other credentials or the "Anonymous Login" for read-only access.

### Standard Flutter Setup

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/).
