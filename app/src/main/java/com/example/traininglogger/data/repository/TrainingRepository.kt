package com.example.traininglogger.data.repository

import com.example.traininglogger.data.db.dao.ExerciseCategoryDao
import com.example.traininglogger.data.db.dao.WorkoutSetDao
import com.example.traininglogger.data.model.ExerciseCategory
import com.example.traininglogger.data.model.WorkoutSet
import kotlinx.coroutines.flow.Flow

class TrainingRepository(
    private val categoryDao: ExerciseCategoryDao,
    private val setDao: WorkoutSetDao
) {
    fun getAllCategories(): Flow<List<ExerciseCategory>> = categoryDao.getAllCategories()

    suspend fun getCategoryById(id: Int): ExerciseCategory? = categoryDao.getById(id)

    suspend fun insertCategory(name: String) = categoryDao.insert(ExerciseCategory(name = name.trim()))

    suspend fun deleteCategory(category: ExerciseCategory) = categoryDao.delete(category)

    fun getSetsForDay(dateStr: String): Flow<List<WorkoutSet>> = setDao.getSetsForDay(dateStr)

    fun getSetsForCategory(categoryId: Int): Flow<List<WorkoutSet>> = setDao.getSetsForCategory(categoryId)

    fun getAllWorkoutDates(): Flow<List<String>> = setDao.getAllWorkoutDates()

    suspend fun insertSet(set: WorkoutSet): Long = setDao.insert(set)

    suspend fun deleteSet(set: WorkoutSet) = setDao.delete(set)
}
