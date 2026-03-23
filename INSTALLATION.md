# Installation Instructions

## Quick Start

### 1. Install Dependencies

The project has been updated with new dependencies (`http` and `dio`). You need to run the following command to install them:

```bash
flutter pub get
```

### 2. Run the Application

```bash
flutter run
```

### 3. Test the API Integration

Once the app is running, you can test it with these demo credentials:

- **Admin Access:**
  - Username: `admin`
  - Password: `admin123`

- **Editor Access:**
  - Username: `editor`
  - Password: `editor123`

- **Guest Access:**
  - Click "CONTINUE AS GUEST" button (read-only access)

## Troubleshooting

### Common Issues

#### Issue: "Target of URI doesn't exist: 'package:dio/dio.dart'"

**Solution:** Run `flutter pub get` to install the dio package.

#### Issue: "Undefined class 'Dio'"

**Solution:** Make sure you've installed the dependencies by running `flutter pub get`.

#### Issue: Connection timeout or network errors

**Solution:** 
1. Check your internet connection
2. Verify the API server is accessible: https://bulletinapi.rindra.org
3. Check if firewall is blocking the connection

#### Issue: 401 Unauthorized errors

**Solution:**
1. Verify your credentials are correct
2. Make sure you're using the correct demo credentials
3. Check if your account is active

## Features Implemented

### 1. Authentication
- ✅ User login with API
- ✅ User registration
- ✅ Token management (auto-refresh)
- ✅ Guest access (read-only mode)

### 2. Bulletin Display
- ✅ Load bulletins from API
- ✅ Display programs grouped by blocks
- ✅ Show coordinators
- ✅ Show announcements (with pinned support)
- ✅ Pull-to-refresh
- ✅ Loading states
- ✅ Error handling

### 3. UI Improvements
- ✅ Modern card-based design
- ✅ Gradient backgrounds
- ✅ Enhanced typography
- ✅ Better spacing and layout
- ✅ Improved form inputs
- ✅ Loading indicators
- ✅ Error messages

## API Endpoints Used

| Feature | Endpoint | Method |
|---------|----------|--------|
| Login | `/auth/login` | POST |
| Register | `/auth/register` | POST |
| Get User Info | `/auth/me` | GET |
| Get Bulletins | `/bulletins` | GET |
| Get Bulletin Detail | `/bulletins/{id}` | GET |

## Development Notes

### Project Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── user_model.dart          # User data model
│   │   └── bulletin_model.dart      # Bulletin & related models
│   └── services/
│       ├── api_service.dart         # Base API configuration
│       ├── auth_api_service.dart    # Authentication API
│       └── bulletin_api_service.dart # Bulletin API
├── features/
│   ├── auth/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   └── providers/
│   │   │       └── user_provider.dart
│   └── bulletin/
│       └── presentation/
│           └── screens/
│               └── bulletin_screen.dart
└── main.dart
```

### Key Components

1. **ApiService**: Singleton class that manages Dio instance, token injection, and auto-refresh
2. **AuthApiService**: Handles authentication-related API calls
3. **BulletinApiService**: Handles bulletin-related API calls
4. **UserProvider**: State management for user authentication
5. **UserModel**: Data model for user information
6. **BulletinModel**: Data model for bulletins and related data

### Authentication Flow

```
User enters credentials
    ↓
AuthApiService.login()
    ↓
Receive access_token and refresh_token
    ↓
Store tokens in ApiService
    ↓
AuthApiService.getCurrentUser()
    ↓
Receive user data
    ↓
Create UserModel from JSON
    ↓
Update UserProvider
    ↓
Navigate to home screen
```

### Token Refresh Flow

```
API request fails with 401
    ↓
Dio interceptor catches error
    ↓
Use refresh_token to get new access_token
    ↓
Update tokens in ApiService
    ↓
Retry original request with new token
    ↓
Success or clear tokens if refresh fails
```

## Next Steps

1. ✅ Install dependencies with `flutter pub get`
2. ✅ Run the app with `flutter run`
3. ✅ Test login with demo credentials
4. ⏳ Implement bulletin CRUD operations
5. ⏳ Add offline caching
6. ⏳ Implement volunteer management
7. ⏳ Add giving feature
8. ⏳ Implement push notifications

## Support

For issues or questions:
- Check the API documentation: https://bulletinapi.rindra.org/docs
- Review ReDoc: https://bulletinapi.rindra.org/redoc
- Check API Integration Summary: `API_INTEGRATION_SUMMARY.md`

## API Information

- **Base URL:** https://bulletinapi.rindra.org/api/v1
- **Swagger UI:** https://bulletinapi.rindra.org/docs
- **ReDoc:** https://bulletinapi.rindra.org/redoc
- **SSL:** Let's Encrypt (auto-renews daily at 3 AM)
