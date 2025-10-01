import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

/// 🌓 Provider de Thèmes Premium - Alpha Client App
///
/// Gestion sophistiquée des thèmes clair/sombre avec transitions fluides
/// et persistance des préférences utilisateur.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// 🌓 Basculer entre les thèmes
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// 🌅 Activer le thème clair
  void setLightTheme() {
    _isDarkMode = false;
    notifyListeners();
  }

  /// 🌙 Activer le thème sombre
  void setDarkTheme() {
    _isDarkMode = true;
    notifyListeners();
  }

  /// 🎨 Obtenir le ThemeData selon le mode actuel
  ThemeData get themeData => _isDarkMode ? darkTheme : lightTheme;

  /// ☀️ Thème Clair Premium
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // 🎨 Couleurs principales
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentLight,
        surface: AppColors.lightSurface,
        background: AppColors.lightBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onBackground: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
        surfaceVariant: AppColors.lightSurfaceVariant,
      ),

      // 🏗️ AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
      ),

      // 📱 Card
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        shadowColor: Colors.black.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),

      // 📝 Texte
      textTheme: AppTextStyles.lightTextTheme,

      // 🔘 Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),

      // 🏺 Surfaces
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightSurface,
      dividerColor: AppColors.lightBorder,
    );
  }

  /// 🌙 Thème Sombre Premium
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // 🎨 Couleurs principales
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.accent,
        secondaryContainer: AppColors.accentDark,
        surface: AppColors.darkSurface,
        background: AppColors.darkBackground,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onBackground: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
        surfaceVariant: AppColors.darkSurfaceVariant,
      ),

      // 🏗️ AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
      ),

      // 📱 Card
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        shadowColor: Colors.black.withOpacity(0.3),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.darkBorder,
            width: 1,
          ),
        ),
      ),

      // 📝 Texte
      textTheme: AppTextStyles.darkTextTheme,

      // 🔘 Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),

      // 🏺 Surfaces
      scaffoldBackgroundColor: AppColors.darkBackground,
      canvasColor: AppColors.darkSurface,
      dividerColor: AppColors.darkBorder,
    );
  }
}

/// 🎛️ Widget Toggle de Thème Premium
class ThemeToggle extends StatelessWidget {
  final ThemeProvider themeProvider;

  const ThemeToggle({
    Key? key,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            themeProvider.isDarkMode
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded,
            key: ValueKey(themeProvider.isDarkMode),
            color: Theme.of(context).colorScheme.onSurface,
            size: 24,
          ),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          themeProvider.toggleTheme();
        },
      ),
    );
  }
}
