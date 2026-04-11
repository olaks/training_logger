package com.example.traininglogger.ui.screens.detail

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.traininglogger.TrainingApp
import com.example.traininglogger.data.model.WorkoutSet
import com.example.traininglogger.ui.screens.home.formatSet
import com.example.traininglogger.ui.screens.home.formatTime
import java.time.LocalDate
import java.time.format.DateTimeFormatter

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ExerciseDetailScreen(
    categoryId: Int,
    dateStr: String,
    onBack: () -> Unit
) {
    val app = LocalContext.current.applicationContext as TrainingApp
    val vm: ExerciseDetailViewModel = viewModel(
        key     = "detail_${categoryId}_$dateStr",
        factory = ExerciseDetailViewModel.Factory(app.repository, categoryId, dateStr)
    )

    val category  by vm.category.collectAsState()
    val allSets   by vm.allSets.collectAsState()
    val todaySets by vm.todaySets.collectAsState()
    var tab       by remember { mutableStateOf(0) }

    val displayDate = remember(dateStr) {
        try { LocalDate.parse(dateStr).format(DateTimeFormatter.ofPattern("MMM d")) }
        catch (_: Exception) { dateStr }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(category?.name ?: "Exercise", fontWeight = FontWeight.Bold)
                        if (tab == 0) Text(displayDate, style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.primary)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            TabRow(selectedTabIndex = tab) {
                listOf("TRACK", "HISTORY", "GRAPH").forEachIndexed { i, label ->
                    Tab(
                        selected  = tab == i,
                        onClick   = { tab = i },
                        text      = { Text(label, fontSize = 13.sp, fontWeight = FontWeight.SemiBold) }
                    )
                }
            }

            when (tab) {
                0 -> TrackTab(vm = vm, todaySets = todaySets)
                1 -> HistoryTab(sets = allSets, onDelete = { vm.deleteSet(it) })
                2 -> GraphTab(sets = allSets)
            }
        }
    }
}

// ─── TRACK tab ────────────────────────────────────────────────────────────────
@Composable
private fun TrackTab(vm: ExerciseDetailViewModel, todaySets: List<WorkoutSet>) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(horizontal = 24.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Weight stepper
        StepperRow(
            label    = "WEIGHT (kg)",
            value    = formatFloat(vm.weightKg.value),
            onDecrement = { vm.decrementWeight() },
            onIncrement = { vm.incrementWeight() }
        )
        HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f))

        // Reps stepper
        StepperRow(
            label    = "REPS",
            value    = vm.reps.value.toString(),
            onDecrement = { vm.decrementReps() },
            onIncrement = { vm.incrementReps() }
        )
        HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.08f))

        // Time stepper
        StepperRow(
            label    = "TIME",
            value    = if (vm.timeSecs.value == 0) "0s" else formatTime(vm.timeSecs.value),
            onDecrement = { vm.decrementTime() },
            onIncrement = { vm.incrementTime() }
        )

        Spacer(Modifier.height(8.dp))

        // Save / Clear buttons
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Button(
                onClick  = { vm.saveSet() },
                modifier = Modifier.weight(1f),
                colors   = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                Text("SAVE", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }
            OutlinedButton(
                onClick  = { vm.clearInputs() },
                modifier = Modifier.weight(1f)
            ) {
                Text("CLEAR", fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }
        }

        // Sets logged today
        if (todaySets.isNotEmpty()) {
            HorizontalDivider(color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.12f))
            Text(
                "Logged today",
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f)
            )
            todaySets.forEachIndexed { i, set ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Set ${i + 1}", style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.5f))
                    Text(formatSet(set), style = MaterialTheme.typography.bodyMedium)
                }
            }
        }
    }
}

@Composable
private fun StepperRow(
    label: String,
    value: String,
    onDecrement: () -> Unit,
    onIncrement: () -> Unit
) {
    Column {
        Text(
            label,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary,
            letterSpacing = 1.sp
        )
        Spacer(Modifier.height(6.dp))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween,
            modifier = Modifier.fillMaxWidth()
        ) {
            FilledTonalIconButton(
                onClick  = onDecrement,
                modifier = Modifier.size(52.dp)
            ) {
                Text("−", fontSize = 22.sp, fontWeight = FontWeight.Light)
            }

            Text(
                value,
                style      = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.SemiBold,
                textAlign  = TextAlign.Center,
                modifier   = Modifier.weight(1f)
            )

            FilledTonalIconButton(
                onClick  = onIncrement,
                modifier = Modifier.size(52.dp)
            ) {
                Text("+", fontSize = 22.sp, fontWeight = FontWeight.Light)
            }
        }
    }
}

private fun formatFloat(f: Float): String =
    if (f == f.toLong().toFloat()) f.toInt().toString()
    else String.format("%.1f", f)

// ─── HISTORY tab ─────────────────────────────────────────────────────────────
@Composable
private fun HistoryTab(sets: List<WorkoutSet>, onDelete: (WorkoutSet) -> Unit) {
    if (sets.isEmpty()) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("No sets logged yet.", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f))
        }
        return
    }

    val grouped = sets.groupBy { it.dateStr }.entries.sortedByDescending { it.key }
    val dateFmt = DateTimeFormatter.ofPattern("EEE, MMM d yyyy")

    LazyColumn(
        contentPadding = PaddingValues(12.dp),
        verticalArrangement = Arrangement.spacedBy(4.dp)
    ) {
        grouped.forEach { (dateStr, daySets) ->
            item {
                val display = try { LocalDate.parse(dateStr).format(dateFmt) } catch (_: Exception) { dateStr }
                Text(
                    display,
                    style = MaterialTheme.typography.labelLarge,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.padding(top = 12.dp, bottom = 4.dp)
                )
            }
            items(daySets, key = { it.id }) { set ->
                HistorySetRow(set = set, index = daySets.indexOf(set), onDelete = { onDelete(set) })
            }
        }
    }
}

@Composable
private fun HistorySetRow(set: WorkoutSet, index: Int, onDelete: () -> Unit) {
    var confirm by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors   = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 12.dp, vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                "Set ${index + 1}",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.45f),
                modifier = Modifier.width(52.dp)
            )
            Text(
                formatSet(set),
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.weight(1f)
            )
            IconButton(onClick = { confirm = true }, modifier = Modifier.size(32.dp)) {
                Icon(Icons.Default.Delete, "Delete", tint = MaterialTheme.colorScheme.error.copy(alpha = 0.6f),
                    modifier = Modifier.size(18.dp))
            }
        }
    }

    if (confirm) {
        AlertDialog(
            onDismissRequest = { confirm = false },
            text = { Text("Delete this set?") },
            confirmButton = {
                TextButton(onClick = { onDelete(); confirm = false }) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = { TextButton(onClick = { confirm = false }) { Text("Cancel") } }
        )
    }
}

// ─── GRAPH tab ────────────────────────────────────────────────────────────────
@Composable
private fun GraphTab(sets: List<WorkoutSet>) {
    if (sets.isEmpty()) {
        Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("No data to display.", color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f))
        }
        return
    }

    // Choose primary metric
    val hasWeight = sets.any { it.weightKg != null && it.weightKg > 0 }
    val hasReps   = sets.any { it.reps != null && it.reps > 0 }
    val hasTime   = sets.any { it.timeSecs != null && it.timeSecs > 0 }

    val grouped = sets.groupBy { it.dateStr }
    val dates   = grouped.keys.sorted()

    data class Point(val date: String, val value: Float)

    val (metricLabel, points) = when {
        hasWeight -> "Max Weight (kg)" to dates.map { d ->
            Point(d, grouped[d]!!.mapNotNull { it.weightKg }.maxOrNull() ?: 0f)
        }
        hasReps -> "Total Reps" to dates.map { d ->
            Point(d, grouped[d]!!.sumOf { it.reps ?: 0 }.toFloat())
        }
        else -> "Total Time" to dates.map { d ->
            Point(d, grouped[d]!!.sumOf { it.timeSecs ?: 0 }.toFloat())
        }
    }

    // Capture colors before canvas lambda
    val primaryColor  = MaterialTheme.colorScheme.primary
    val onSurface     = MaterialTheme.colorScheme.onSurface
    val gridColor     = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.1f)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            metricLabel,
            style = MaterialTheme.typography.titleSmall,
            fontWeight = FontWeight.SemiBold,
            color = MaterialTheme.colorScheme.primary
        )

        Spacer(Modifier.height(4.dp))

        if (points.size < 2) {
            Text(
                "Log more sessions to see a progress graph.",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
            )
        }

        Spacer(Modifier.height(8.dp))

        Canvas(
            modifier = Modifier
                .fillMaxWidth()
                .height(240.dp)
        ) {
            if (points.isEmpty()) return@Canvas

            val padL = 56.dp.toPx(); val padR = 16.dp.toPx()
            val padT = 12.dp.toPx(); val padB = 36.dp.toPx()
            val w    = size.width - padL - padR
            val h    = size.height - padT - padB

            val minV  = points.minOf { it.value }
            val maxV  = points.maxOf { it.value }
            val range = (maxV - minV).takeIf { it > 0f } ?: 1f

            fun xAt(i: Int) = padL + i * (w / (points.size - 1).coerceAtLeast(1))
            fun yAt(v: Float) = padT + h - (v - minV) / range * h

            // Grid + Y labels
            val nGrid = 4
            for (gi in 0..nGrid) {
                val y = padT + gi * (h / nGrid)
                drawLine(gridColor, Offset(padL, y), Offset(padL + w, y), strokeWidth = 1.dp.toPx())
                val v = maxV - gi * (range / nGrid)
                drawYLabel(v, metricLabel, x = 4.dp.toPx(), y = y + 4.dp.toPx(), color = onSurface.copy(alpha = 0.55f))
            }

            // Line segments
            if (points.size >= 2) {
                for (i in 0 until points.size - 1) {
                    drawLine(
                        color       = primaryColor,
                        start       = Offset(xAt(i), yAt(points[i].value)),
                        end         = Offset(xAt(i + 1), yAt(points[i + 1].value)),
                        strokeWidth = 2.5.dp.toPx()
                    )
                }
            }

            // Dots + X labels
            val step = if (points.size > 8) (points.size / 6).coerceAtLeast(1) else 1
            points.forEachIndexed { i, pt ->
                val x = xAt(i); val y = yAt(pt.value)
                drawCircle(primaryColor, radius = 4.5.dp.toPx(), center = Offset(x, y))
                drawCircle(Color.Black.copy(alpha = 0.4f), radius = 2.dp.toPx(), center = Offset(x, y))
                if (i % step == 0 || i == points.size - 1) {
                    val label = pt.date.substring(5) // "MM-DD"
                    drawXLabel(label, x = x, y = size.height - 4.dp.toPx(), color = onSurface.copy(alpha = 0.55f))
                }
            }
        }
    }
}

private fun DrawScope.drawYLabel(value: Float, metricLabel: String, x: Float, y: Float, color: Color) {
    val text = if (metricLabel.contains("Time"))
        formatTime(value.toInt())
    else if (value == value.toLong().toFloat()) value.toInt().toString()
    else String.format("%.1f", value)

    drawContext.canvas.nativeCanvas.drawText(
        text, x, y,
        android.graphics.Paint().apply {
            this.color  = color.toArgb()
            textSize    = 10.dp.toPx()
            isAntiAlias = true
        }
    )
}

private fun DrawScope.drawXLabel(label: String, x: Float, y: Float, color: Color) {
    drawContext.canvas.nativeCanvas.drawText(
        label, x - 14.dp.toPx(), y,
        android.graphics.Paint().apply {
            this.color  = color.toArgb()
            textSize    = 9.dp.toPx()
            isAntiAlias = true
        }
    )
}
