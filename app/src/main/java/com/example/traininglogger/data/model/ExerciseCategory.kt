package com.example.traininglogger.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "exercise_categories")
data class ExerciseCategory(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String
)
