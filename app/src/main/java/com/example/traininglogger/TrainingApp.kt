package com.example.traininglogger

import android.app.Application
import com.example.traininglogger.data.db.AppDatabase
import com.example.traininglogger.data.repository.TrainingRepository

class TrainingApp : Application() {
    val database by lazy { AppDatabase.getDatabase(this) }
    val repository by lazy {
        TrainingRepository(
            database.exerciseCategoryDao(),
            database.workoutSetDao()
        )
    }
}
