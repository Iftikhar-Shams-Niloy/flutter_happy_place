import 'package:flutter/material.dart';

class MyAppColors {
  static const seedGreen = Color.fromARGB(255, 238, 172, 95);
  static const accentPurple = Color.fromARGB(255, 154, 109, 216);
  static const lightPurple = Color.fromARGB(255, 212, 181, 255);
}

class MyAppScheme {
  static final lightScheme = ColorScheme.fromSeed(
    seedColor: MyAppColors.seedGreen,
    brightness: Brightness.light,
    secondary: MyAppColors.lightPurple,
  );

  static final darkScheme = ColorScheme.fromSeed(
    seedColor: MyAppColors.seedGreen,
    brightness: Brightness.dark,
    secondary: MyAppColors.accentPurple,
  );
}

//* <----- TEXT THEME ----->
class MyAppTextTheme {
  static final light = TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: MyAppScheme.lightScheme.secondary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: MyAppScheme.lightScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: MyAppScheme.lightScheme.onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: MyAppScheme.lightScheme.onSurface,
    ),
  );

  static final dark = TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: MyAppScheme.darkScheme.secondary,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: MyAppScheme.darkScheme.onSurface,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: MyAppScheme.darkScheme.onSurface,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      color: MyAppScheme.darkScheme.onSurface,
    ),
  );
}

class MyAppTheme {
  static final lightTheme = ThemeData.from(colorScheme: MyAppScheme.lightScheme)
      .copyWith(
        //!   <----- Core text and color ----->
        textTheme: MyAppTextTheme.light,
        scaffoldBackgroundColor: MyAppScheme.lightScheme.surfaceDim,

        //!   <----- AppBar ----->
        appBarTheme: AppBarTheme(
          backgroundColor: MyAppScheme.lightScheme.primary,
          foregroundColor: MyAppScheme.lightScheme.onPrimary,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: MyAppTextTheme.light.titleLarge,
        ),

        //!   <----- Buttons ----->
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyAppScheme.lightScheme.primary,
            foregroundColor: MyAppScheme.lightScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyAppScheme.lightScheme.primary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: MyAppScheme.lightScheme.primary,
            side: BorderSide(color: MyAppScheme.lightScheme.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        //!   <----- Floating action button ----->
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: MyAppScheme.lightScheme.secondary,
          foregroundColor: MyAppScheme.lightScheme.onSecondary,
        ),

        //!   <----- Cards ----->
        cardTheme: CardThemeData(
          color: MyAppScheme.lightScheme.surface,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        //!   <----- Inputs ----->
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MyAppScheme.lightScheme.surfaceContainerHighest.withValues(
            alpha: 0.6,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyAppScheme.lightScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: MyAppScheme.lightScheme.primary,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(color: MyAppScheme.lightScheme.onSurface),
        ),

        //!   <----- Icons ----->
        iconTheme: IconThemeData(
          color: MyAppScheme.lightScheme.onSurface,
          size: 20,
        ),

        //!   <----- Bottom navigation ----->
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: MyAppScheme.lightScheme.surface,
          selectedItemColor: MyAppScheme.lightScheme.primary,
          unselectedItemColor: MyAppScheme.lightScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          showUnselectedLabels: true,
          elevation: 8,
        ),

        //!   <----- Snackbars ----->
        snackBarTheme: SnackBarThemeData(
          backgroundColor: MyAppScheme.lightScheme.surface,
          contentTextStyle: MyAppTextTheme.light.bodyMedium,
          actionTextColor: MyAppScheme.lightScheme.primary,
        ),

        //!   <----- Dividers ----->
        dividerTheme: DividerThemeData(
          color: MyAppScheme.lightScheme.outline,
          thickness: 1,
        ),

        //!   <----- Chips ----->
        chipTheme: ChipThemeData(
          backgroundColor: MyAppScheme.lightScheme.surfaceContainerHighest,
          selectedColor: MyAppScheme.lightScheme.primary.withValues(
            alpha: 0.12,
          ),
          labelStyle: MyAppTextTheme.light.bodySmall!,
          secondaryLabelStyle: MyAppTextTheme.light.bodySmall!,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          brightness: Brightness.light,
        ),

        //!   <----- Toggle buttons ----->
        toggleButtonsTheme: ToggleButtonsThemeData(
          color: MyAppScheme.lightScheme.onSurface,
          selectedColor: MyAppScheme.lightScheme.onPrimary,
          fillColor: MyAppScheme.lightScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),

        //! <----- Sliders ----->
        sliderTheme: SliderThemeData(
          activeTrackColor: MyAppScheme.lightScheme.primary,
          inactiveTrackColor: MyAppScheme.lightScheme.onSurface.withValues(
            alpha: 0.2,
          ),
          thumbColor: MyAppScheme.lightScheme.primary,
        ),

        //! <----- Switches ----->
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(
            MyAppScheme.lightScheme.primary,
          ),
          trackColor: WidgetStateProperty.all(
            MyAppScheme.lightScheme.primary.withValues(alpha: 0.5),
          ),
        ),

        //! <----- Tooltips ----->
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: MyAppScheme.lightScheme.onSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: MyAppTextTheme.light.bodySmall,
        ),

        //!   <----- Progress indicators ----->
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: MyAppScheme.lightScheme.primary,
        ),

        //!   <----- Scrollbar ----->
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(
            MyAppScheme.lightScheme.outline,
          ),
        ),

        //!   <----- Popup menus ----->
        popupMenuTheme: PopupMenuThemeData(
          color: MyAppScheme.lightScheme.surface,
          textStyle: MyAppTextTheme.light.bodyMedium,
        ),
      );

  static final darkTheme = ThemeData.from(colorScheme: MyAppScheme.darkScheme)
      .copyWith(
        //!   <----- Core text and color ----->
        textTheme: MyAppTextTheme.dark,
        scaffoldBackgroundColor: MyAppScheme.darkScheme.surfaceBright,

        //!   <----- AppBar ----->
        appBarTheme: AppBarTheme(
          backgroundColor: MyAppScheme.darkScheme.primary,
          foregroundColor: MyAppScheme.darkScheme.onPrimary,
          elevation: 1,
          centerTitle: true,
          titleTextStyle: MyAppTextTheme.dark.titleLarge,
        ),

        //!   <----- Buttons ----->
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MyAppScheme.darkScheme.primary,
            foregroundColor: MyAppScheme.darkScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: MyAppScheme.darkScheme.primary,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: MyAppScheme.darkScheme.primary,
            side: BorderSide(color: MyAppScheme.darkScheme.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        //!   <----- Floating action button ----->
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: MyAppScheme.darkScheme.secondary,
          foregroundColor: MyAppScheme.darkScheme.onSecondary,
        ),

        //!   <----- Cards ----->
        cardTheme: CardThemeData(
          color: MyAppScheme.darkScheme.surface,
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        //!   <----- Inputs ----->
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: MyAppScheme.darkScheme.surfaceContainerHighest.withValues(
            alpha: 0.2,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: MyAppScheme.darkScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: MyAppScheme.darkScheme.primary,
              width: 2,
            ),
          ),
          labelStyle: TextStyle(color: MyAppScheme.darkScheme.onSurface),
        ),

        //!   <----- Icons ----->
        iconTheme: IconThemeData(
          color: MyAppScheme.darkScheme.onSurface,
          size: 20,
        ),

        //!   <----- Bottom navigation ----->
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: MyAppScheme.darkScheme.surface,
          selectedItemColor: MyAppScheme.darkScheme.primary,
          unselectedItemColor: MyAppScheme.darkScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          showUnselectedLabels: true,
          elevation: 8,
        ),

        //!   <----- Snackbars ----->
        snackBarTheme: SnackBarThemeData(
          backgroundColor: MyAppScheme.darkScheme.surface,
          contentTextStyle: MyAppTextTheme.dark.bodyMedium,
          actionTextColor: MyAppScheme.darkScheme.primary,
        ),

        //!   <----- Dividers ----->
        dividerTheme: DividerThemeData(
          color: MyAppScheme.darkScheme.outline,
          thickness: 1,
        ),

        //!   <----- Chips ----->
        chipTheme: ChipThemeData(
          backgroundColor: MyAppScheme.darkScheme.surfaceContainerHighest,
          selectedColor: MyAppScheme.darkScheme.primary.withValues(alpha: 0.12),
          labelStyle: MyAppTextTheme.dark.bodySmall!,
          secondaryLabelStyle: MyAppTextTheme.dark.bodySmall!,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          brightness: Brightness.dark,
        ),

        //!   <----- Toggle buttons ----->
        toggleButtonsTheme: ToggleButtonsThemeData(
          color: MyAppScheme.darkScheme.onSurface,
          selectedColor: MyAppScheme.darkScheme.onPrimary,
          fillColor: MyAppScheme.darkScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),

        //!   <----- Sliders ----->
        sliderTheme: SliderThemeData(
          activeTrackColor: MyAppScheme.darkScheme.primary,
          inactiveTrackColor: MyAppScheme.darkScheme.onSurface.withValues(
            alpha: 0.2,
          ),
          thumbColor: MyAppScheme.darkScheme.primary,
        ),

        //!   <----- Switches ----->
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(MyAppScheme.darkScheme.primary),
          trackColor: WidgetStateProperty.all(
            MyAppScheme.darkScheme.primary.withValues(alpha: 0.5),
          ),
        ),

        //!   <----- Tooltips ----->
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: MyAppScheme.darkScheme.onSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: MyAppTextTheme.dark.bodySmall,
        ),

        //!   <----- Progress indicators ----->
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: MyAppScheme.darkScheme.primary,
        ),

        //!   <----- Scrollbar ----->
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(MyAppScheme.darkScheme.outline),
        ),

        //!   <----- Popup menus ----->
        popupMenuTheme: PopupMenuThemeData(
          color: MyAppScheme.darkScheme.surface,
          textStyle: MyAppTextTheme.dark.bodyMedium,
        ),
      );
}
