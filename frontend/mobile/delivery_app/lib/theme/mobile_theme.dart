import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';

/// 🎨 Thème Mobile-First avec Glassmorphism
/// 
/// Configuration complète du thème optimisé pour mobile
/// avec support dark/light mode et design glassmorphism moderne.
class MobileTheme {
  
  // ==========================================================================
  // 🌞 THÈME CLAIR
  // ==========================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      // Configuration de base
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Couleurs principales
      colorScheme: _lightColorScheme,
      
      // Couleurs de surface
      scaffoldBackgroundColor: AppColors.gray50,
      canvasColor: AppColors.gray50,
      cardColor: AppColors.cardBgLight,
      
      // AppBar
      appBarTheme: _lightAppBarTheme,
      
      // Navigation
      bottomNavigationBarTheme: _lightBottomNavTheme,
      navigationBarTheme: _lightNavigationBarTheme,
      
      // Boutons
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      floatingActionButtonTheme: _lightFabTheme,
      
      // Cartes et surfaces
      cardTheme: _lightCardTheme,
      
      // Champs de texte
      inputDecorationTheme: _lightInputTheme,
      
      // Texte
      textTheme: _textTheme,
      
      // Icônes
      iconTheme: _lightIconTheme,
      
      // Dividers
      dividerTheme: _lightDividerTheme,
      
      // Dialogs
      dialogTheme: _lightDialogTheme,
      
      // Bottom sheets
      bottomSheetTheme: _lightBottomSheetTheme,
      
      // Snackbars
      snackBarTheme: _lightSnackBarTheme,
      
      // Autres composants
      chipTheme: _lightChipTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      
      // Splash et highlight
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
      
      // Focus
      focusColor: AppColors.primary.withOpacity(0.12),
    );
  }
  
  // ==========================================================================
  // 🌙 THÈME SOMBRE
  // ==========================================================================
  
  static ThemeData get darkTheme {
    return ThemeData(
      // Configuration de base
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Couleurs principales
      colorScheme: _darkColorScheme,
      
      // Couleurs de surface
      scaffoldBackgroundColor: AppColors.gray900,
      canvasColor: AppColors.gray900,
      cardColor: AppColors.cardBgDark,
      
      // AppBar
      appBarTheme: _darkAppBarTheme,
      
      // Navigation
      bottomNavigationBarTheme: _darkBottomNavTheme,
      navigationBarTheme: _darkNavigationBarTheme,
      
      // Boutons
      elevatedButtonTheme: _elevatedButtonTheme,
      textButtonTheme: _textButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      floatingActionButtonTheme: _darkFabTheme,
      
      // Cartes et surfaces
      cardTheme: _darkCardTheme,
      
      // Champs de texte
      inputDecorationTheme: _darkInputTheme,
      
      // Texte
      textTheme: _textTheme,
      
      // Icônes
      iconTheme: _darkIconTheme,
      
      // Dividers
      dividerTheme: _darkDividerTheme,
      
      // Dialogs
      dialogTheme: _darkDialogTheme,
      
      // Bottom sheets
      bottomSheetTheme: _darkBottomSheetTheme,
      
      // Snackbars
      snackBarTheme: _darkSnackBarTheme,
      
      // Autres composants
      chipTheme: _darkChipTheme,
      switchTheme: _switchTheme,
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      
      // Splash et highlight
      splashColor: AppColors.primary.withOpacity(0.1),
      highlightColor: AppColors.primary.withOpacity(0.05),
      
      // Focus
      focusColor: AppColors.primary.withOpacity(0.12),
    );
  }
  
  // ==========================================================================
  // 🎨 SCHÉMAS DE COULEURS
  // ==========================================================================
  
  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    tertiary: AppColors.accent,
    onTertiary: Colors.white,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.gray50,
    onSurface: AppColors.textPrimary,
    background: AppColors.gray50,
    onBackground: AppColors.textPrimary,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.gray200,
  );
  
  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryLight,
    onPrimary: AppColors.gray900,
    secondary: AppColors.secondary,
    onSecondary: AppColors.gray900,
    tertiary: AppColors.accent,
    onTertiary: AppColors.gray900,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.gray800,
    onSurface: AppColors.textLight,
    background: AppColors.gray900,
    onBackground: AppColors.textLight,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.gray700,
  );
  
  // ==========================================================================
  // 📱 APP BAR THEMES
  // ==========================================================================
  
  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  );
  
  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textLight,
    titleTextStyle: TextStyle(
      color: AppColors.textLight,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(
      color: AppColors.textLight,
      size: 24,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
  
  // ==========================================================================
  // 🧭 NAVIGATION THEMES
  // ==========================================================================
  
  static BottomNavigationBarThemeData get _lightBottomNavTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBgLight,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray500,
      selectedLabelStyle: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.caption,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
  
  static BottomNavigationBarThemeData get _darkBottomNavTheme {
    return BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardBgDark,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.gray400,
      selectedLabelStyle: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: AppTextStyles.caption,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
  
  static NavigationBarThemeData get _lightNavigationBarTheme {
    return NavigationBarThemeData(
      backgroundColor: AppColors.cardBgLight,
      indicatorColor: AppColors.primary.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.caption.copyWith(
          color: AppColors.gray500,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.primary,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.gray500,
          size: 24,
        );
      }),
    );
  }
  
  static NavigationBarThemeData get _darkNavigationBarTheme {
    return NavigationBarThemeData(
      backgroundColor: AppColors.cardBgDark,
      indicatorColor: AppColors.primaryLight.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTextStyles.caption.copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTextStyles.caption.copyWith(
          color: AppColors.gray400,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.primaryLight,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.gray400,
          size: 24,
        );
      }),
    );
  }
  
  // ==========================================================================
  // 🔘 BUTTON THEMES
  // ==========================================================================
  
  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, MobileDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }
  
  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, MobileDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }
  
  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, MobileDimensions.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        side: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
        textStyle: AppTextStyles.buttonMedium,
      ),
    );
  }
  
  static FloatingActionButtonThemeData get _lightFabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
    );
  }
  
  static FloatingActionButtonThemeData get _darkFabTheme {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryLight,
      foregroundColor: AppColors.gray900,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
    );
  }
  
  // ==========================================================================
  // 🃏 CARD THEMES
  // ==========================================================================
  
  static CardThemeData get _lightCardTheme {
    return CardThemeData(
      color: AppColors.cardBgLight,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: BorderSide(
          color: AppColors.gray200.withOpacity(AppColors.glassBorderLightOpacity),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(AppSpacing.sm),
    );
  }
  
  static CardThemeData get _darkCardTheme {
    return CardThemeData(
      color: AppColors.cardBgDark,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: BorderSide(
          color: AppColors.gray700.withOpacity(AppColors.glassBorderDarkOpacity),
          width: 1,
        ),
      ),
      margin: const EdgeInsets.all(AppSpacing.sm),
    );
  }
  
  // ==========================================================================
  // ✏️ INPUT THEMES
  // ==========================================================================
  
  static InputDecorationTheme get _lightInputTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBgLight,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(
          color: AppColors.gray200.withOpacity(0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(
          color: AppColors.gray200.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
  
  static InputDecorationTheme get _darkInputTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBgDark,
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(
          color: AppColors.gray700.withOpacity(0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: BorderSide(
          color: AppColors.gray700.withOpacity(0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.primaryLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusMD,
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.gray400,
      ),
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.gray300,
      ),
    );
  }
  
  // ==========================================================================
  // 📝 TEXT THEME
  // ==========================================================================
  
  static TextTheme get _textTheme {
    return TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      displaySmall: AppTextStyles.h3,
      headlineLarge: AppTextStyles.h2,
      headlineMedium: AppTextStyles.h3,
      headlineSmall: AppTextStyles.h4,
      titleLarge: AppTextStyles.h3,
      titleMedium: AppTextStyles.h4,
      titleSmall: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.buttonMedium,
      labelMedium: AppTextStyles.label,
      labelSmall: AppTextStyles.caption,
    );
  }
  
  // ==========================================================================
  // 🎯 ICON THEMES
  // ==========================================================================
  
  static const IconThemeData _lightIconTheme = IconThemeData(
    color: AppColors.textPrimary,
    size: 24,
  );
  
  static const IconThemeData _darkIconTheme = IconThemeData(
    color: AppColors.textLight,
    size: 24,
  );
  
  // ==========================================================================
  // ➖ DIVIDER THEMES
  // ==========================================================================
  
  static const DividerThemeData _lightDividerTheme = DividerThemeData(
    color: AppColors.borderLight,
    thickness: 1,
    space: 1,
  );
  
  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.borderDark,
    thickness: 1,
    space: 1,
  );
  
  // ==========================================================================
  // 💬 DIALOG THEMES
  // ==========================================================================
  
  static DialogTheme get _lightDialogTheme {
    return DialogTheme(
      backgroundColor: AppColors.cardBgLight,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: BorderSide(
          color: AppColors.gray200.withOpacity(0.5),
        ),
      ),
      titleTextStyle: AppTextStyles.h3.copyWith(
        color: AppColors.textPrimary,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }
  
  static DialogTheme get _darkDialogTheme {
    return DialogTheme(
      backgroundColor: AppColors.cardBgDark,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: BorderSide(
          color: AppColors.gray700.withOpacity(0.3),
        ),
      ),
      titleTextStyle: AppTextStyles.h3.copyWith(
        color: AppColors.textLight,
      ),
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.gray300,
      ),
    );
  }
  
  // ==========================================================================
  // 📋 BOTTOM SHEET THEMES
  // ==========================================================================
  
  static BottomSheetThemeData get _lightBottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: AppColors.cardBgLight,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MobileDimensions.radiusLG),
        ),
      ),
    );
  }
  
  static BottomSheetThemeData get _darkBottomSheetTheme {
    return BottomSheetThemeData(
      backgroundColor: AppColors.cardBgDark,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MobileDimensions.radiusLG),
        ),
      ),
    );
  }
  
  // ==========================================================================
  // 🍞 SNACKBAR THEMES
  // ==========================================================================
  
  static SnackBarThemeData get _lightSnackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.gray800,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );
  }
  
  static SnackBarThemeData get _darkSnackBarTheme {
    return SnackBarThemeData(
      backgroundColor: AppColors.gray200,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.gray900,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );
  }
  
  // ==========================================================================
  // 🏷️ CHIP THEMES
  // ==========================================================================
  
  static ChipThemeData get _lightChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.gray100,
      selectedColor: AppColors.primary.withOpacity(0.12),
      disabledColor: AppColors.gray100.withOpacity(0.5),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textPrimary,
      ),
      secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSM,
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }
  
  static ChipThemeData get _darkChipTheme {
    return ChipThemeData(
      backgroundColor: AppColors.gray800,
      selectedColor: AppColors.primaryLight.withOpacity(0.12),
      disabledColor: AppColors.gray800.withOpacity(0.5),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textLight,
      ),
      secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(
        color: AppColors.primaryLight,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusSM,
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }
  
  // ==========================================================================
  // 🎛️ CONTROL THEMES
  // ==========================================================================
  
  static SwitchThemeData get _switchTheme {
    return SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return AppColors.gray300;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.gray400;
      }),
    );
  }
  
  static CheckboxThemeData get _checkboxTheme {
    return CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(Colors.white),
      side: const BorderSide(
        color: AppColors.gray400,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  static RadioThemeData get _radioTheme {
    return RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primary;
        }
        return AppColors.gray400;
      }),
    );
  }
}