# Usability improvements — remaining items

These are follow-up improvements identified during the UX review of the workout logging flow. Items 1-4 have been implemented.

## 5. Climbing grade picker is too slow

**Problem:** Font scale has ~24 grades, V-scale ~19. The stepper requires tapping one grade at a time. Going from V0 to V10 is 10+ taps.

**Approach:** Replace the +/- stepper with a scrollable wheel picker (e.g., `ListWheelScrollView` or a `CupertinoPicker`-style widget). Keep the +/- buttons for fine adjustment, but allow flick-scrolling through the grade list.

**Files:** `track_tab.dart` (`_buildClimbingInputs`)

## 6. Home screen FAB could be smarter

**Problem:** The `+` FAB navigates to the Exercises tab, which is identical to tapping the bottom nav. No shortcut to start logging a planned exercise.

**Approach:** If workouts are planned for today, the FAB opens a bottom sheet listing unstarted planned exercises (tap one to go straight to its Track tab). If nothing is planned, keep current behavior (go to Exercises).

**Files:** `home_screen.dart` (FAB `onPressed`), new `_QuickPickSheet` widget

## 7. Show workout targets on the Track tab

**Problem:** If a workout specifies "3x5" for an exercise, the Track tab doesn't surface this. The user has to check the Home screen to know how many sets are expected.

**Approach:** Look up `WorkoutExercises` for the current category + date's planned workout. Display a subtle "Target: 3 x 5 reps — 2 of 3 done" label above or below the SAVE button.

**Files:** `track_tab.dart`, new provider or query to fetch target for a given (categoryId, dateStr) pair via the plan/workout chain

## 8. Custom rest timer duration

**Problem:** Only 4 fixed presets (1/2/3/5 min). 90 seconds is a common hypertrophy rest interval but isn't available.

**Approach:** Add a long-press on the rest timer duration area to open a small dialog where the user types a custom number of seconds. Store the custom value alongside the presets. The `RestTimerNotifier` already supports arbitrary durations via `setDurationAndRestart`.

**Files:** `track_tab.dart` (`_RestTimerWidget`), optionally persist last-used duration in `SharedPreferences`

## 9. Calendar shows planned workout days

**Problem:** Calendar bottom sheet only marks days with logged sets (dots). Days with planned workouts but no logged sets are invisible.

**Approach:** Query `PlanWorkouts` to derive which future dates have a workout scheduled (weekday-based plans expand to dates in the visible month). Show a different marker (e.g., hollow dot or ring) for planned-but-not-logged days vs filled dot for logged days.

**Files:** `home_screen.dart` (`_CalendarSheet`), new provider to compute planned dates for a given month

## 10. Session summary

**Problem:** After finishing a workout there's no summary — total sets, total volume, workout duration. The user has no "done" signal.

**Approach:** Add a collapsible summary card at the top of the Home screen's exercise list for the selected day (only when sets exist). Show: total sets, total volume (weight x reps summed), number of exercises, and time span (first set timestamp to last).

**Files:** `home_screen.dart`, compute summary from `setsForDayProvider`
