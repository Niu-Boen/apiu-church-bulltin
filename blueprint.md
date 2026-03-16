# Project Blueprint: APIU Bulletin App

## 1. Overview

This document outlines the architecture, features, and design system for the APIU Bulletin App, a modern, cross-platform application built with Flutter. The app aims to provide a centralized hub for church announcements, events, and other relevant information, with a special focus on a clean, intuitive, and visually appealing user experience.

## 2. Core Features

- **Role-Based Access Control:** The app distinguishes between two primary user roles:
  - **Admin:** Can create, edit, and delete bulletin items. Has full access to all app features.
  - **User/Guest:** Can view bulletin items and other public content. Has read-only access.
- **Anonymous Login:** Guests can access the app anonymously after acknowledging a visitor notice. This provides a low-friction entry point for casual users.
- **Dynamic Bulletin Board:** A real-time bulletin board displaying announcements, schedules, and events. Admins can manage this content dynamically.
- **Giving & Tithes Information:** A dedicated section providing information and links for giving and tithes.
- **Modern UI/UX:** A visually polished interface inspired by modern design trends (e.g., TopTop, Xiaomi Auto), featuring a dark mode, custom fonts, and animated interactions.

## 3. Design System & Theming

The app employs a centralized and modern design system defined in `main.dart` to ensure a consistent and high-quality visual identity.

### 3.1. Colors

- **Primary Color:** `#00C6FF` (A vibrant cyan, used for highlights, buttons, and primary actions).
- **Secondary Color:** `#007BFF` (A strong blue, used for secondary highlights and accents).
- **Dark Mode Palette:**
  - **Background:** `#121212` (A deep, neutral black).
  - **Cards/Components:** `#1E1E1E` (A slightly lighter shade for elevated surfaces).
  - **Borders:** `Colors.grey.shade800`.
- **Light Mode Palette:**
  - **Background:** `#F7F9FC` (A clean, light grey).
  - **Cards/Components:** `Colors.white`.

### 3.2. Typography

We use the `google_fonts` package to enhance readability and visual hierarchy:

- **Headings (Poppins):** A modern, geometric sans-serif font used for titles and major headings (`displayLarge`, `headlineMedium`, `titleLarge`). Its bold and clean lines draw attention to key information.
- **Body Text (Source Sans Pro):** A humanist sans-serif font chosen for its excellent readability in UI contexts. It's used for paragraphs and detailed text (`bodyLarge`, `bodyMedium`).

### 3.3. Component Styles

- **Cards (`CardTheme`):**
  - **Dark Mode:** Feature a subtle border (`Colors.grey.shade800`) and a `color` of `#1E1E1E` to create a floating effect over the dark background.
  - **Light Mode:** Use a soft elevation and a pure white background.
  - **Shape:** All cards use a `RoundedRectangleBorder` with a `borderRadius` of `16`, creating a soft, modern look.
- **Buttons (`ElevatedButtonThemeData`):**
  - Styled with a `borderRadius` of `12` and generous padding for a comfortable tap target.
  - Use the primary color for the background, creating a strong call to action.
- **Input Fields (`InputDecorationTheme`):**
  - Feature a `filled` style with no border, giving them a clean, modern appearance that blends seamlessly with the card-based layout.
  - The fill color matches the card color of the current theme.

## 4. Architecture & Navigation

- **State Management:** `ChangeNotifier` and `Provider` are used for managing app-wide state, such as the current theme.
- **Routing:** `go_router` is used for declarative navigation, providing a robust and type-safe way to handle routes, parameters, and transitions.
- **Feature-First Structure:** The project is organized by features (e.g., `auth`, `bulletin`, `home`), with each feature having its own `presentation` (screens, widgets), `data`, and `domain` layers.

## 5. Current Plan & Action Steps

**Objective:** Overhaul the app's UI and improve the guest login experience.

**Steps Taken:**

1.  **Dependency Added:** Added `google_fonts` to `pubspec.yaml`.
2.  **Theme Revamped:**
    - Created a new, modern `ThemeData` for both light and dark modes in `main.dart`.
    - Implemented a `ThemeProvider` to allow users to toggle between themes.
    - Applied the new themes and fonts across the application.
3.  **Login Screen Enhanced:**
    - Renamed "Guest Login" to "Anonymous Login".
    - Implemented a visitor notice `AlertDialog` to inform users about read-only access.
    - Redesigned the UI with a radial gradient background, a new logo, and improved form styling.
4.  **Core Screens Beautified:**
    - **Home Screen:** Redesigned feature cards into a `GridView` and restyled the Sabbath card with a gradient and shadow for a premium look.
    - **Bulletin Screen:** Redesigned bulletin item cards for better readability and alignment with the new design system. Added an empty state view.
5.  **Blueprint Updated:** This document has been updated to reflect all the new changes.
