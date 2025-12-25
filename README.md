# Campus Grid 🎓

A peer-to-peer learning platform for university students to share and discover academic resources.

## 📱 About

Campus Grid is a Flutter-based mobile application that enables students to:
- Share notes, assignments, and study materials
- Browse resources by department, degree, and subject
- Search for specific academic content
- Save favorite resources to a personal library
- Like and engage with helpful content
- Download study materials for offline access

## ✨ Features

- **Authentication**: Email/password signup and Google Sign-In
- **Resource Management**: Create, edit, delete, and view academic notes
- **File Upload**: Support for PDF, DOC, DOCX, PPT, and PPTX files via Cloudinary
- **Search**: Global search with debouncing across degrees, subjects, and notes
- **Library**: Personal collection of saved resources with instant filtering
- **Downloads**: Download attached files with progress tracking
- **Profile**: User statistics (notes uploaded, likes received, saved items)
- **Edit Profile**: Update display name and email (manual signup users)
- **Organized Navigation**: Browse by Department → Degree → Subject → Notes

## 🛠️ Tech Stack

- **Framework**: Flutter 3.9.2+ with Dart
- **Backend**: Firebase (Authentication, Firestore)
- **Storage**: Cloudinary (25GB free tier)
- **Navigation**: GoRouter with StatefulShellRoute
- **State Management**: Basic setState
- **File Handling**: file_picker, dio, path_provider
- **UI Components**: Material 3 Design

## 📦 Dependencies

```yaml
- firebase_core: ^4.3.0
- firebase_auth: ^6.1.3
- cloud_firestore: ^6.1.0
- go_router: ^17.0.1
- google_sign_in: ^7.2.0
- cloudinary_public: ^0.23.1
- dio: ^5.9.0
- file_picker: ^10.3.8
- flutter_svg: ^2.0.7
- font_awesome_flutter: ^10.12.0
