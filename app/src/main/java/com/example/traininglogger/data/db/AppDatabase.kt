package com.example.traininglogger.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.traininglogger.data.db.dao.ExerciseCategoryDao
import com.example.traininglogger.data.db.dao.WorkoutSetDao
import com.example.traininglogger.data.model.ExerciseCategory
import com.example.traininglogger.data.model.WorkoutSet

@Database(
    entities = [ExerciseCategory::class, WorkoutSet::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun exerciseCategoryDao(): ExerciseCategoryDao
    abstract fun workoutSetDao(): WorkoutSetDao

    companion object {
        @Volatile private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context): AppDatabase =
            INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "training_logger.db"
                ).build().also { INSTANCE = it }
            }
    }
}
