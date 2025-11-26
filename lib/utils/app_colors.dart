// TODO Implement this library.
// utils/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF1976D2);
  static const Color secondaryBlue = Color(0xFF42A5F5);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF0D47A1);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color skyBlue = Color(0xFF87CEEB);
  static const Color deepBlue = Color(0xFF1565C0);
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFFE8F5E8);
  static const Color darkGreen = Color(0xFF2E7D32);
  
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color lightOrange = Color(0xFFFFF3E0);
  static const Color darkOrange = Color(0xFFE65100);
  
  static const Color errorRed = Color(0xFFF44336);
  static const Color lightRed = Color(0xFFFFEBEE);
  static const Color darkRed = Color(0xFFC62828);
  
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color lightInfo = Color(0xFFE3F2FD);
  
  // Neutral Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFBDBDBD);
  
  // Background Colors
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFFEEEEEE);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);
  static const Color cardBorder = Color(0xFFE0E0E0);
  
  // Module Colors (for dashboard cards)
  static const Color noticeBlue = Color(0xFF2196F3);
  static const Color noticeBlueLight = Color(0xFFE3F2FD);
  
  static const Color maintenanceGreen = Color(0xFF4CAF50);
  static const Color maintenanceGreenLight = Color(0xFFE8F5E8);
  
  static const Color financeOrange = Color(0xFFFF9800);
  static const Color financeOrangeLight = Color(0xFFFFF3E0);
  
  static const Color memberPurple = Color(0xFF9C27B0);
  static const Color memberPurpleLight = Color(0xFFF3E5F5);
  
  // Admin Colors
  static const Color adminOrange = Color(0xFFFF6F00);
  static const Color adminOrangeLight = Color(0xFFFFF8E1);
  static const Color adminBadge = Color(0xFFFF5722);
  
  // Payment Colors
  static const Color upiGreen = Color(0xFF4CAF50);
  static const Color googlePayBlue = Color(0xFF4285F4);
  static const Color paytmBlue = Color(0xFF00BAF2);
  static const Color cashGrey = Color(0xFF795548);
  
  // Status Colors for different states
  static const Color activeBadge = Color(0xFF4CAF50);
  static const Color inactiveBadge = Color(0xFF9E9E9E);
  static const Color pendingBadge = Color(0xFFFF9800);
  static const Color urgentBadge = Color(0xFFF44336);
  static const Color completedBadge = Color(0xFF2196F3);

// class AppColors {
// static const Color primaryBlue = Color(0xFF1E4A73); // Removed duplicate
// static const Color lightBlue = Color(0xFF3B82C8);
static const Color white = Colors.white;
static const Color grey = Colors.grey;
static const Color darkGrey = Color(0xFF666666);
static const Color lightGrey = Color(0xFFF5F5F5);

static var primaryGradient;
// }
  
  // Gradients
  // static const LinearGradient primaryGradient = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment.bottomRight,
  //   colors: [primaryBlue, secondaryBlue],
  //   stops: [0.0, 1.0],
  // );
  
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
  );
  
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFE57373)],
  );
  
  // Admin specific gradients
  static const LinearGradient adminGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6F00), Color(0xFFFFB74D)],
  );
  
  // Financial gradients
  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
  );
  
  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF44336), Color(0xFFFF5722)],
  );
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderMedium = Color(0xFFBDBDBD);
  static const Color borderDark = Color(0xFF9E9E9E);
  
  // Input Field Colors
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocused = primaryBlue;
  static const Color inputError = errorRed;
  static const Color inputHint = Color(0xFF9E9E9E);
  
  // Button Colors
  static const Color buttonPrimary = primaryBlue;
  static const Color buttonSecondary = Color(0xFF6C757D);
  static const Color buttonSuccess = successGreen;
  static const Color buttonWarning = warningOrange;
  static const Color buttonDanger = errorRed;
  static const Color buttonInfo = infoBlue;
  static const Color buttonLight = Color(0xFFF8F9FA);
  static const Color buttonDark = Color(0xFF343A40);
  
  // Notification Colors
  static const Color notificationSuccess = Color(0xFF4CAF50);
  static const Color notificationError = Color(0xFFF44336);
  static const Color notificationWarning = Color(0xFFFF9800);
  static const Color notificationInfo = Color(0xFF2196F3);
  
  // Chart Colors (for financial charts and reports)
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];

  static var primaryColor;
  
  // Helper Methods
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Get color for payment status
  static Color getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return successGreen;
      case 'pending':
        return warningOrange;
      case 'overdue':
      case 'failed':
        return errorRed;
      case 'processing':
        return infoBlue;
      default:
        return textGrey;
    }
  }
  
  /// Get color for user role
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrator':
        return adminOrange;
      case 'user':
      case 'resident':
        return primaryBlue;
      case 'guest':
        return textGrey;
      default:
        return textSecondary;
    }
  }
  
  /// Get gradient for module cards
  static LinearGradient getModuleGradient(String module) {
    switch (module.toLowerCase()) {
      case 'notice':
      case 'communication':
        return blueGradient;
      case 'maintenance':
      case 'billing':
        return greenGradient;
      case 'finance':
      case 'account':
        return orangeGradient;
      case 'member':
      case 'resident':
        return purpleGradient;
      case 'admin':
        return adminGradient;
      default:
        return primaryGradient;
    }
  }
  
  /// Get background color for module cards
  static Color getModuleBackgroundColor(String module) {
    switch (module.toLowerCase()) {
      case 'notice':
      case 'communication':
        return noticeBlueLight;
      case 'maintenance':
      case 'billing':
        return maintenanceGreenLight;
      case 'finance':
      case 'account':
        return financeOrangeLight;
      case 'member':
      case 'resident':
        return memberPurpleLight;
      case 'admin':
        return adminOrangeLight;
      default:
        return lightBlue;
    }
  }
  
  /// Get icon color for modules
  static Color getModuleIconColor(String module) {
    switch (module.toLowerCase()) {
      case 'notice':
      case 'communication':
        return noticeBlue;
      case 'maintenance':
      case 'billing':
        return maintenanceGreen;
      case 'finance':
      case 'account':
        return financeOrange;
      case 'member':
      case 'resident':
        return memberPurple;
      case 'admin':
        return adminOrange;
      default:
        return primaryBlue;
    }
  }
  
  /// Get shadow color with custom opacity
  static BoxShadow getBoxShadow({
    Color color = shadowLight,
    double blurRadius = 10.0,
    double spreadRadius = 0.0,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxShadow(
      color: color,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
      offset: offset,
    );
  }
  
  /// Get material color swatch from primary color
  static MaterialColor get primarySwatch {
    return MaterialColor(
      primaryBlue.value,
      <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: primaryBlue,
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2),
        800: Color(0xFF1565C0),
        900: Color(0xFF0D47A1),
      },
    );
  }
}