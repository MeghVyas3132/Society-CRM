# Society-CRM

A comprehensive Community Relationship Management system built with Flutter and Firebase, designed to streamline residential society operations and member management.

## Overview

Society-CRM is a cross-platform mobile and web application that enables residential societies to manage members, handle billing, process maintenance requests, send community notices, and maintain effective communication channels between administrators and residents.

## Features

### User Management
- User registration and authentication with email/password
- Role-based access control (Member, Admin, Super Admin)
- Persistent user data with Firebase Firestore
- Profile management and account settings
- Secure logout functionality

### Admin Features
- Admin dashboard with role-based controls
- Create and broadcast notices to all residents
- Set notice priority levels (Low, Medium, High)
- View member and resident information
- Community communication management

### Resident Features
- View all community notices in real-time
- Account and profile management
- Finance and billing information access
- Maintenance request viewing
- Communication dashboard

### Technical Features
- Multi-platform support (Android, iOS, Web, Windows, macOS, Linux)
- Firebase Authentication for secure login
- Cloud Firestore for real-time data synchronization
- Firebase Cloud Storage for file management
- Docker containerization for web deployment
- Nginx reverse proxy for web hosting
- Responsive UI design

## Technology Stack

### Frontend
- Flutter 3.10.0+
- Dart 3.0.0+

### Backend
- Firebase Authentication (Email/Password)
- Cloud Firestore (Real-time Database)
- Firebase Cloud Storage
- Firebase Cloud Messaging

### Deployment
- Docker with multi-stage builds
- Nginx (Alpine)
- Debian (Builder stage)

## Getting Started

### Prerequisites
- Flutter SDK: 3.10.0 or higher
- Dart SDK: 3.0.0 or higher
- Firebase project with authentication and Firestore enabled
- Docker and Docker Compose (for web deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yashvii1807/Society-CRM.git
cd Society-CRM
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Place your `google-services.json` in `android/app/`
   - Place your Firebase configuration in `lib/firebase_options.dart`
   - Update `ios/Runner/GoogleService-Info.plist` for iOS builds

4. Run the application:

For Android:
```bash
flutter run -d android
```

For iOS:
```bash
flutter run -d ios
```

For Web:
```bash
flutter run -d web
```

For Windows:
```bash
flutter run -d windows
```

### Docker Deployment

Build and run the containerized web application:

```bash
docker-compose build mysociety-web
docker-compose up -d mysociety-web
```

Access the application at `http://localhost:8080`

## Admin Registration

The application supports three user roles:

1. **Member**: Regular resident with limited access
2. **Admin**: Can create notices and manage residents (Code: ADMIN2025)
3. **Super Admin**: Full administrative privileges (Code: SUPERADMIN2025)

During registration, enter the appropriate admin code to register with admin privileges.

## Project Structure

```
Society-CRM/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── firebase_options.dart     # Firebase configuration
│   ├── config/
│   │   └── routes.dart           # Route configuration
│   ├── models/
│   │   └── user_model.dart       # User data model
│   ├── screens/
│   │   ├── auth_wrapper.dart     # Auth state management
│   │   ├── login_screen.dart     # Login interface
│   │   ├── register_screen.dart  # Registration interface
│   │   ├── dashboard_screen.dart # Member dashboard
│   │   ├── profile_screen.dart   # User profile
│   │   ├── admin/
│   │   │   ├── dashboard/
│   │   │   └── notices/
│   │   └── ...
│   ├── services/
│   │   ├── firebase_auth_service.dart   # Authentication
│   │   ├── database_service.dart        # Firestore operations
│   │   ├── storage_service.dart         # File storage
│   │   └── messaging_service.dart       # Push notifications
│   ├── utils/
│   │   └── ...
│   └── widgets/
│       └── ...
├── android/                  # Android-specific code
├── ios/                      # iOS-specific code
├── web/                      # Web-specific files
├── windows/                  # Windows-specific code
├── macos/                    # macOS-specific code
├── linux/                    # Linux-specific code
├── test/                     # Unit and widget tests
├── Dockerfile                # Docker configuration
├── docker-compose.yml        # Docker Compose configuration
├── nginx.conf                # Nginx configuration
├── pubspec.yaml              # Flutter dependencies
└── README.md                 # This file
```

## Configuration

### Firebase Setup

1. Create a Firebase project at https://firebase.google.com
2. Enable Authentication with Email/Password
3. Create a Firestore database in test mode
4. Set Firestore security rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

5. Download and configure your service account credentials

### Environment Variables

Create a `.env` file in the project root (if needed for specific configurations):
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

## Data Models

### User Model
```
- uid: string (Firebase UID)
- email: string
- name: string
- role: string (member/admin/super_admin)
- phone: string
- address: string
- unit: string
- createdAt: timestamp
- updatedAt: timestamp
```

### Notice Model
```
- id: string
- title: string
- message: string
- priority: string (low/medium/high)
- createdBy: string (Admin UID)
- createdAt: timestamp
- type: string
```

## API Endpoints

The application uses Firebase services directly without traditional REST endpoints. Communication occurs through:

- Firebase Authentication SDK
- Firestore Real-time Listeners
- Firebase Cloud Storage
- Firebase Cloud Messaging

## Troubleshooting

### Application Loading Indefinitely
- Verify Firebase credentials are correctly configured
- Check internet connectivity
- Ensure Firestore rules allow read access

### Authentication Failures
- Verify Firebase Authentication is enabled
- Check email/password combination
- Confirm user account exists in Firebase Console

### Docker Build Failures
- Ensure Docker and Docker Compose are installed
- Check disk space availability
- Verify internet connectivity for dependency downloads

### Web Deployment Issues
- Verify Nginx configuration in `nginx.conf`
- Check port 8080 availability
- Review Docker logs: `docker-compose logs mysociety-app`

## Security Considerations

- All user data is encrypted in transit via HTTPS
- Firebase provides authentication token management
- Firestore security rules restrict data access to authenticated users
- Sensitive information is handled by Firebase services
- Docker containers run with minimal privileges

## Performance Optimization

- Flutter's ahead-of-time (AOT) compilation ensures fast startup
- Firestore indexes optimize query performance
- Real-time listeners minimize data transfer
- Docker multi-stage builds reduce image size
- Nginx caching reduces server load

## Testing

Run unit and widget tests:

```bash
flutter test
```

## Contributing

Contributions are welcome. Please follow these guidelines:
1. Create a new branch for your feature
2. Ensure code follows Flutter and Dart best practices
3. Write tests for new functionality
4. Submit a pull request with detailed description

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Support

For issues, questions, or feature requests, please open an issue on the GitHub repository at https://github.com/MeghVyas3132/Society-CRM

## Changelog

### Version 1.0.0
- Initial release with core features
- Firebase integration complete
- Admin panel functionality
- Notice system implemented
- Docker containerization
- Cross-platform support

## Author
Megh Vyas

## Acknowledgments

- Flutter framework and community
- Firebase services documentation
- Docker best practices
