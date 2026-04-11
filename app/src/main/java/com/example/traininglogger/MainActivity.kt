package com.example.traininglogger

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import com.example.traininglogger.ui.navigation.AppNavigation
import com.example.traininglogger.ui.theme.TrainingLoggerTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TrainingLoggerTheme {
                AppNavigation()
            }
        }
    }
}
