package com.example.traininglogger.ui.screens.detail

import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.*
import androidx.lifecycle.viewModelScope
import com.example.traininglogger.data.model.ExerciseCategory
import com.example.traininglogger.data.model.WorkoutSet
import com.example.traininglogger.data.repository.TrainingRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class ExerciseDetailViewModel(
    private val repository: TrainingRepository,
    val categoryId: Int,
    val dateStr: String
) : ViewModel() {

    private val _category = MutableStateFlow<ExerciseCategory?>(null)
    val category: StateFlow<ExerciseCategory?> = _category.asStateFlow()

    // All sets ever logged for this exercise (for history + graph)
    val allSets: StateFlow<List<WorkoutSet>> = repository.getSetsForCategory(categoryId)
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Sets logged today (shown below TRACK inputs)
    val todaySets: StateFlow<List<WorkoutSet>> = repository.getSetsForDay(dateStr)
        .map { it.filter { s -> s.categoryId == categoryId } }
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    // Stepper state (mutable Compose state — survives recomposition)
    var weightKg  = mutableStateOf(0f)
    var reps      = mutableStateOf(0)
    var timeSecs  = mutableStateOf(0)

    init {
        viewModelScope.launch { _category.value = repository.getCategoryById(categoryId) }
    }

    fun incrementWeight(step: Float = 1f) { weightKg.value = (weightKg.value + step).coerceAtLeast(0f) }
    fun decrementWeight(step: Float = 1f) { weightKg.value = (weightKg.value - step).coerceAtLeast(0f) }
    fun incrementReps()  { reps.value = (reps.value + 1).coerceAtLeast(0) }
    fun decrementReps()  { reps.value = (reps.value - 1).coerceAtLeast(0) }
    fun incrementTime(step: Int = 5) { timeSecs.value = (timeSecs.value + step).coerceAtLeast(0) }
    fun decrementTime(step: Int = 5) { timeSecs.value = (timeSecs.value - step).coerceAtLeast(0) }

    fun saveSet() {
        val w = weightKg.value.takeIf { it > 0 }
        val r = reps.value.takeIf { it > 0 }
        val t = timeSecs.value.takeIf { it > 0 }
        if (w == null && r == null && t == null) return
        viewModelScope.launch {
            repository.insertSet(WorkoutSet(
                categoryId = categoryId,
                dateStr    = dateStr,
                weightKg   = w,
                reps       = r,
                timeSecs   = t
            ))
        }
    }

    fun clearInputs() {
        weightKg.value = 0f
        reps.value     = 0
        timeSecs.value = 0
    }

    fun deleteSet(set: WorkoutSet) {
        viewModelScope.launch { repository.deleteSet(set) }
    }

    class Factory(
        private val repo: TrainingRepository,
        private val categoryId: Int,
        private val dateStr: String
    ) : ViewModelProvider.Factory {
        @Suppress("UNCHECKED_CAST")
        override fun <T : ViewModel> create(modelClass: Class<T>) =
            ExerciseDetailViewModel(repo, categoryId, dateStr) as T
    }
}
