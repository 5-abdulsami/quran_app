import 'package:flutter/widgets.dart';

/// Closes the on-screen keyboard. Used as every text field's `onTapOutside`,
/// so tapping anywhere else dismisses it (Flutter only does this on desktop
/// by default).
void dismissKeyboard([PointerDownEvent? _]) =>
    FocusManager.instance.primaryFocus?.unfocus();
