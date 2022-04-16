// maps
import 'package:flutter/material.dart';
import 'package:trufi_core/base/blocs/theme/theme_cubit.dart';
const urlsrouteFeedbackUrl =
    'https://trufifeedback.z15.web.core.windows.net/route.html';

// Colors

Color hintTextColor(ThemeData theme) =>
    ThemeCubit.isDarkMode(theme) ? Colors.grey[400]! : Colors.grey[700]!;

Color titleColor(ThemeData theme) =>
    ThemeCubit.isDarkMode(theme) ? Colors.white : theme.colorScheme.secondary;
