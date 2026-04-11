package com.example.traininglogger.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "workout_sets")
data class WorkoutSet(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val categoryId: Int,
    val dateStr: String,                          // "yyyy-MM-dd"
    val timestamp: Long = System.currentTimeMillis(),
    val weightKg: Float? = null,
    val reps: Int? = null,
    val timeSecs: Int? = null
)
