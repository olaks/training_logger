package com.example.traininglogger.ui.screens.exercises

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.*
import androidx.lifecycle.viewModelScope
import com.example.traininglogger.data.model.ExerciseCategory
import com.example.traininglogger.data.repository.TrainingRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class ExercisesViewModel(private val repository: TrainingRepository) : ViewModel() {

    val categories: StateFlow<List<ExerciseCategory>> = repository.getAllCategories()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    var searchQuery = mutableStateOf("")

    fun filteredCategories(all: List<ExerciseCategory>): List<ExerciseCategory> {
        val q = searchQuery.value.trim()
        return if (q.isBlank()) all else all.filter { it.name.contains(q, ignoreCase = true) }
    }

    fun addCategory(name: String) {
        if (name.isBlank()) return
        viewModelScope.launch { repository.insertCategory(name) }
    }

    fun deleteCategory(category: ExerciseCategory) {
        viewModelScope.launch { repository.deleteCategory(category) }
    }

    class Factory(private val repo: TrainingRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>) = ExercisesViewModel(repo) as T
    }
}
