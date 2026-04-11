package com.example.traininglogger.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.FitnessCenter
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.navigation.*
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.*
import com.example.traininglogger.ui.screens.detail.ExerciseDetailScreen
import com.example.traininglogger.ui.screens.exercises.ExercisesScreen
import com.example.traininglogger.ui.screens.home.HomeScreen
import java.time.LocalDate
import java.time.format.DateTimeFormatter

sealed class Screen(val route: String, val label: String, val icon: ImageVector) {
    object Home      : Screen("home", "Home", Icons.Default.CalendarMonth)
    object Exercises : Screen("exercises", "Exercises", Icons.Default.FitnessCenter)
}

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val bottomScreens = listOf(Screen.Home, Screen.Exercises)
    val today = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd"))

    Scaffold(
        bottomBar = {
            NavigationBar {
                val backStack by navController.currentBackStackEntryAsState()
                val current = backStack?.destination
                bottomScreens.forEach { screen ->
                    NavigationBarItem(
                        icon  = { Icon(screen.icon, contentDescription = screen.label) },
                        label = { Text(screen.label) },
                        selected = current?.hierarchy?.any { it.route == screen.route } == true,
                        onClick = {
                            navController.navigate(screen.route) {
                                popUpTo(navController.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        }
                    )
                }
            }
        }
    ) { padding ->
        NavHost(navController = navController, startDestination = Screen.Home.route) {
            composable(Screen.Home.route) {
                HomeScreen(
                    contentPadding = padding,
                    onOpenExercise = { categoryId, dateStr ->
                        navController.navigate("exercise_detail/$categoryId/$dateStr")
                    }
                )
            }
            composable(Screen.Exercises.route) {
                ExercisesScreen(
                    contentPadding = padding,
                    onExerciseClick = { categoryId ->
                        navController.navigate("exercise_detail/$categoryId/$today")
                    }
                )
            }
            composable(
                route = "exercise_detail/{categoryId}/{dateStr}",
                arguments = listOf(
                    navArgument("categoryId") { type = NavType.IntType },
                    navArgument("dateStr")    { type = NavType.StringType }
                )
            ) { back ->
                val categoryId = back.arguments?.getInt("categoryId") ?: return@composable
                val dateStr    = back.arguments?.getString("dateStr") ?: today
                ExerciseDetailScreen(
                    categoryId = categoryId,
                    dateStr    = dateStr,
                    onBack     = { navController.popBackStack() }
                )
            }
        }
    }
}
