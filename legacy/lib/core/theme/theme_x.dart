import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_type.dart';

/// Terse access to the three token families a widget actually needs.
extension ThemeX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.patra;

  DevText get devText =>
      Theme.of(this).extension<DevText>() ?? DevText.of(AppColors.patra);

  TextTheme get type => Theme.of(this).textTheme;
}
