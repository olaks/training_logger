package com.example.traininglogger.data.db.dao

import androidx.room.*
import com.example.traininglogger.data.model.ExerciseCategory
import kotlinx.coroutines.flow.Flow

@Dao
interface ExerciseCategoryDao {
    @Query("SELECT * FROM exercise_categories ORDER BY name ASC")
    fun getAllCategories(): Flow<List<ExerciseCategory>>

    @Query("SELECT * FROM exercise_categories WHERE id = :id")
    suspend fun getById(id: Int): ExerciseCategory?

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(category: ExerciseCategory): Long

    @Delete
    suspend fun delete(category: ExerciseCategory)
}
