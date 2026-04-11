package com.example.traininglogger.ui.theme

import androidx.compose.material3.*
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary          = GreenHoldLight,
    onPrimary        = SlateDark,
    primaryContainer = GreenHold,
    onPrimaryContainer = ChalkWhite,
    secondary        = SubtleText,
    background       = SlateDark,
    surface          = SlateCard,
    surfaceVariant   = SlateCardAlt,
    onBackground     = OnDarkText,
    onSurface        = OnDarkText,
    onSurfaceVariant = SubtleText,
    error            = CrimsonRed
)

@Composable
fun TrainingLoggerTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        typography = Typography,
        content = content
    )
}
