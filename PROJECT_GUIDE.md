# Coffeeist Project Guide

This document provides an overview of all files and directories in the Coffeeist project, explaining their purpose and function.

> **Note:** This is a reference guide that should be updated whenever files are added, modified, or removed from the project.

## Main App Files

| File | Description |
|------|-------------|
| `Coffeeist/CoffeeistApp.swift` | The entry point and setup file for the app. Configures Firebase and sets up the initial view structure. |
| `Coffeeist/ContentView.swift` | The main screen users see when opening the app, showing the date, greeting, and buttons to add new preparations. |
| `Coffeeist/TimelineView.swift` | The feed/history view that displays all previous coffee preparations in a timeline similar to Strava. |
| `Coffeeist/PreparationFormView.swift` | The form interface where users input all details about their coffee preparation (equipment, settings, etc.). |
| `Coffeeist/RatingInputView.swift` | The custom rating slider component used to score coffee preparations. |

## Data Model

| File | Description |
|------|-------------|
| `Coffeeist/CoffeePreparation.swift` | Defines the data structure for coffee preparations, including all fields like grind size, timing, weights, and ratings. |
| `Coffeeist/PreparationDataManager.swift` | Manages the state of preparation data, handles saving and loading preparations. |

## Firebase Integration

| File | Description |
|------|-------------|
| `Coffeeist/GoogleService-Info.plist` | Firebase configuration file containing API keys and settings needed to connect to Firebase services. |
| `Coffeeist/Services/FirebaseService.swift` | Handles all communication with Firebase Firestore for storing and retrieving coffee preparations. |
| `Coffeeist/Services/MockDatabaseService.swift` | A simulated database service for testing and SwiftUI previews without requiring Firebase connection. |
| `Coffeeist/Services/StorageService.swift` | Manages uploading and retrieving images to/from Firebase Storage. |

## Supporting Files

| File | Description |
|------|-------------|
| `Coffeeist/Info.plist` | Contains app configuration, permissions, and settings required by iOS. |
| `Coffeeist/Assets.xcassets/` | Directory containing all images, icons, and visual assets used in the app. |
| `Coffeeist/Views/` | Directory containing additional UI components and screens. |
| `Coffeeist/Views/LoadingView.swift` | Loading indicator view displayed during network operations. |
| `Coffeeist/Utilities/` | Directory containing helper functions and utility code. |
| `Coffeeist/Utilities/AlertItem.swift` | Manages alert messages displayed to users. |

## Project Management

| File | Description |
|------|-------------|
| `.gitignore` | Specifies files that should not be tracked by Git version control. |
| `README.md` | Overview documentation about the project, including setup instructions. |
| `PrivacyPolicy.md` | The app's privacy policy for users and App Store submission. |
| `Coffeeist.xcodeproj/` | Xcode project files that define how to build the app. |
| `.github/workflows/ios.yml` | GitHub Actions workflow configuration for continuous integration testing. |
| `CoffeeistTests/` | Directory containing unit tests for the app's logic. |
| `CoffeeistUITests/` | Directory containing UI tests that simulate user interactions with the app. |

## How to Use This Guide

When adding new files:
1. Add an entry to the appropriate section in this document
2. Include a brief description of the file's purpose
3. Update any cross-references if needed

When removing files:
1. Remove the corresponding entry from this document
2. Update any cross-references

When substantially changing a file's purpose:
1. Update the description to reflect the new purpose 