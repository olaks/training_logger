package com.example.traininglogger.ui.screens.home

import androidx.lifecycle.*
import androidx.lifecycle.viewModelScope
import com.example.traininglogger.data.model.ExerciseCategory
import com.example.traininglogger.data.model.WorkoutSet
import com.example.traininglogger.data.repository.TrainingRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.*
import java.time.LocalDate
import java.time.format.DateTimeFormatter

class HomeViewModel(private val repository: TrainingRepository) : ViewModel() {

    private val fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd")

    private val _selectedDate = MutableStateFlow(LocalDate.now())
    val selectedDate: StateFlow<LocalDate> = _selectedDate.asStateFlow()

    val datesWithWorkouts: StateFlow<Set<String>> = repository.getAllWorkoutDates()
        .map { it.toSet() }
        .stateIn(viewModelScope, SharingStarted.Lazily, emptySet())

    @OptIn(ExperimentalCoroutinesApi::class)
    val setsForDay: StateFlow<List<WorkoutSet>> = _selectedDate
        .flatMapLatest { repository.getSetsForDay(it.format(fmt)) }
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val categories: StateFlow<List<ExerciseCategory>> = repository.getAllCategories()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    fun selectDate(date: LocalDate) { _selectedDate.value = date }
    fun prevDay() { _selectedDate.value = _selectedDate.value.minusDays(1) }
    fun nextDay() { _selectedDate.value = _selectedDate.value.plusDays(1) }

    fun selectedDateStr(): String = _selectedDate.value.format(fmt)

    class Factory(private val repo: TrainingRepository) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>) = HomeViewModel(repo) as T
    }
}
