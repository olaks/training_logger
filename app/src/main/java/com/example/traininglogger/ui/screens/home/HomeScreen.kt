package com.example.traininglogger.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.traininglogger.TrainingApp
import com.example.traininglogger.data.model.WorkoutSet
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.time.format.TextStyle as JTextStyle
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    contentPadding: PaddingValues,
    onOpenExercise: (Int, String) -> Unit
) {
    val app = LocalContext.current.applicationContext as TrainingApp
    val vm: HomeViewModel = viewModel(factory = HomeViewModel.Factory(app.repository))

    val selectedDate by vm.selectedDate.collectAsState()
    val setsForDay   by vm.setsForDay.collectAsState()
    val datesWithWo  by vm.datesWithWorkouts.collectAsState()
    val categories   by vm.categories.collectAsState()

    var showCalendar by remember { mutableStateOf(false) }

    val dayLabel = remember(selectedDate) {
        val today = LocalDate.now()
        when (selectedDate) {
            today            -> "Today"
            today.minusDays(1) -> "Yesterday"
            today.plusDays(1)  -> "Tomorrow"
            else -> selectedDate.format(DateTimeFormatter.ofPattern("EEE, MMM d"))
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(contentPadding)
    ) {
        // ── Day navigation bar ──────────────────────────────────────────────
        Surface(shadowElevation = 2.dp) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 4.dp, vertical = 8.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                IconButton(onClick = { vm.prevDay() }) {
                    Icon(Icons.Default.ChevronLeft, contentDescription = "Previous day")
                }
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.clickable { showCalendar = true }
                ) {
                    Text(
                        text = dayLabel,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Icon(
                        Icons.Default.CalendarMonth,
                        contentDescription = "Pick date",
                        modifier = Modifier.size(18.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                }
                IconButton(onClick = { vm.nextDay() }) {
                    Icon(Icons.Default.ChevronRight, contentDescription = "Next day")
                }
            }
        }

        // ── Workout list for selected day ───────────────────────────────────
        if (setsForDay.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .weight(1f),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        Icons.Default.FitnessCenter,
                        contentDescription = null,
                        modifier = Modifier.size(64.dp),
                        tint = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.2f)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        "Workout Log Empty",
                        style = MaterialTheme.typography.bodyLarge,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                    // "Start New Workout" navigates to Exercises tab — handled via FAB
                }
            }
        } else {
            val grouped = setsForDay.groupBy { it.categoryId }
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f),
                contentPadding = PaddingValues(12.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                grouped.forEach { (catId, sets) ->
                    val catName = categories.find { it.id == catId }?.name ?: "Unknown"
                    item(key = catId) {
                        DayExerciseCard(
                            name  = catName,
                            sets  = sets,
                            onClick = { onOpenExercise(catId, vm.selectedDateStr()) }
                        )
                    }
                }
            }
        }
    }

    // ── Calendar date picker ────────────────────────────────────────────────
    if (showCalendar) {
        DatePickerDialog(
            onDismissRequest = { showCalendar = false },
            confirmButton = {}
        ) {
            CalendarPicker(
                selectedDate     = selectedDate,
                datesWithWorkouts = datesWithWo,
                onDateSelected   = { date ->
                    vm.selectDate(date)
                    showCalendar = false
                }
            )
        }
    }
}

// ── Exercise card shown on the home day view ────────────────────────────────
@Composable
fun DayExerciseCard(name: String, sets: List<WorkoutSet>, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(name, style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.SemiBold)
                Text(
                    "${sets.size} set${if (sets.size != 1) "s" else ""}",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary
                )
            }
            Spacer(modifier = Modifier.height(4.dp))
            sets.forEachIndexed { i, set ->
                Text(
                    "  Set ${i + 1}:  ${formatSet(set)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.7f)
                )
            }
        }
    }
}

// ── Mini calendar picker ────────────────────────────────────────────────────
@Composable
fun CalendarPicker(
    selectedDate: LocalDate,
    datesWithWorkouts: Set<String>,
    onDateSelected: (LocalDate) -> Unit
) {
    var month by remember { mutableStateOf(YearMonth.from(selectedDate)) }
    val fmt   = DateTimeFormatter.ofPattern("yyyy-MM-dd")
    val today = LocalDate.now()

    Column(modifier = Modifier.padding(8.dp)) {
        // Month header
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = { month = month.minusMonths(1) }) {
                Icon(Icons.Default.ChevronLeft, contentDescription = "Prev month")
            }
            Text(
                "${month.month.getDisplayName(JTextStyle.FULL, Locale.getDefault())} ${month.year}",
                style = MaterialTheme.typography.titleSmall,
                fontWeight = FontWeight.Bold
            )
            IconButton(onClick = { month = month.plusMonths(1) }) {
                Icon(Icons.Default.ChevronRight, contentDescription = "Next month")
            }
        }

        // Weekday headers
        Row(modifier = Modifier.fillMaxWidth()) {
            listOf("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su").forEach {
                Text(
                    it,
                    modifier = Modifier.weight(1f),
                    textAlign = TextAlign.Center,
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
                )
            }
        }

        Spacer(Modifier.height(4.dp))

        val startOffset = month.atDay(1).dayOfWeek.value - 1  // Mon=0
        val daysInMonth = month.lengthOfMonth()
        val rows = (startOffset + daysInMonth + 6) / 7

        for (row in 0 until rows) {
            Row(Modifier.fillMaxWidth()) {
                for (col in 0 until 7) {
                    val day = row * 7 + col - startOffset + 1
                    if (day < 1 || day > daysInMonth) {
                        Box(Modifier.weight(1f).aspectRatio(1f))
                    } else {
                        val date    = month.atDay(day)
                        val dateStr = date.format(fmt)
                        CalendarDay(
                            day          = day,
                            isSelected   = date == selectedDate,
                            isToday      = date == today,
                            hasWorkout   = dateStr in datesWithWorkouts,
                            onClick      = { onDateSelected(date) },
                            modifier     = Modifier.weight(1f)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CalendarDay(
    day: Int,
    isSelected: Boolean,
    isToday: Boolean,
    hasWorkout: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val bg = when {
        isSelected -> MaterialTheme.colorScheme.primary
        isToday    -> MaterialTheme.colorScheme.primaryContainer
        else       -> androidx.compose.ui.graphics.Color.Transparent
    }
    val fg = when {
        isSelected -> MaterialTheme.colorScheme.onPrimary
        isToday    -> MaterialTheme.colorScheme.onPrimaryContainer
        else       -> MaterialTheme.colorScheme.onSurface
    }
    val dotColor = if (isSelected) MaterialTheme.colorScheme.onPrimary
                   else MaterialTheme.colorScheme.primary

    Box(
        modifier = modifier
            .aspectRatio(1f)
            .padding(2.dp)
            .clip(CircleShape)
            .background(bg)
            .clickable(onClick = onClick),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                "$day",
                color = fg,
                fontSize = 13.sp,
                fontWeight = if (isSelected || isToday) FontWeight.Bold else FontWeight.Normal
            )
            if (hasWorkout) {
                Box(
                    Modifier
                        .size(4.dp)
                        .clip(CircleShape)
                        .background(dotColor)
                )
            }
        }
    }
}

// ── Shared formatting helpers ────────────────────────────────────────────────
fun formatSet(set: WorkoutSet): String {
    val parts = buildList {
        set.weightKg?.let { add("${if (it == it.toLong().toFloat()) it.toInt() else it} kg") }
        set.reps?.let { add("$it reps") }
        set.timeSecs?.let { add(formatTime(it)) }
    }
    return if (parts.isEmpty()) "–" else parts.joinToString("  ·  ")
}

fun formatTime(secs: Int): String {
    val m = secs / 60; val s = secs % 60
    return if (m > 0) "${m}m ${s}s" else "${s}s"
}
