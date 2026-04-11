package com.example.traininglogger.data.db.dao

import androidx.room.*
import com.example.traininglogger.data.model.WorkoutSet
import kotlinx.coroutines.flow.Flow

@Dao
interface WorkoutSetDao {
    @Query("SELECT * FROM workout_sets WHERE dateStr = :dateStr ORDER BY timestamp ASC")
    fun getSetsForDay(dateStr: String): Flow<List<WorkoutSet>>

    @Query("SELECT * FROM workout_sets WHERE categoryId = :categoryId ORDER BY dateStr DESC, timestamp ASC")
    fun getSetsForCategory(categoryId: Int): Flow<List<WorkoutSet>>

    @Query("SELECT DISTINCT dateStr FROM workout_sets ORDER BY dateStr ASC")
    fun getAllWorkoutDates(): Flow<List<String>>

    @Insert
    suspend fun insert(set: WorkoutSet): Long

    @Delete
    suspend fun delete(set: WorkoutSet)
}
