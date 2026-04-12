# Training Logger

A climbing and strength training logger for Android, iOS, and Linux.

---

## Features

**Exercise tracking**
- Log weight, reps, and/or time per set with tap-to-type or +/− steppers
- RPE (Rate of Perceived Exertion) 1–10 with descriptive labels (Easy → Max)
- Rest timer starts automatically after saving a set; configurable 1 / 2 / 3 / 5 min presets

**Climbing grade logging**
- Mark any exercise as *climbing type* — logs a grade instead of weight/reps
- Supports Font (3 → 8C+) and V-scale (VB → V17), auto-detected from logged data
- Pre-populated Bouldering group: Max Boulder, Flash, Onsight, Moonboard, Kilter Board

**Progress graphs**
- Per-exercise line charts: Max Weight, Est. 1RM (Epley), Total Volume, Total Reps, Total Time
- Climbing exercises show a Best Grade trend with grade labels on the y-axis

**Personal records**
- Gold star on any set that equals the all-time best for that exercise
- Works for weight, reps, time, and climbing grade

**Workout planning**
- Create reusable **Workouts** (named sets of exercises, with optional target reps)
- Create **Plans** that assign workouts to weekdays or specific dates
- Home screen shows today's planned exercises and how many sets have been logged

**Daily log**
- Navigate by day with ← / → arrows or the calendar picker
- Session note per day — tap to write free text
- Body weight entry per day

**Exercise library**
- 30+ pre-populated exercises across 9 groups: Bouldering, Finger Strength, Power, Power Endurance, Endurance, Movement, Antagonist, General Strength, Core
- Add custom exercises and groups; attach a photo to any exercise

**Themes**
- Four accent colours: Forest (green), Ocean (blue), Dusk (purple), Ember (orange)

**Data portability**
- Export / import a full JSON backup
- Import history from FitNotes CSV export

---

## Usage

### Logging a set

1. Open the **Home** screen and tap a planned exercise, or go to **Exercises** and tap any exercise.
2. Adjust weight, reps, and time with the **+/−** buttons — tap the number to type directly.
3. Optionally set **RPE** (your effort level for the set).
4. Tap **SAVE**. A rest timer starts automatically; tap the duration chips to change it.
5. Repeat for each set. All sets logged today appear at the bottom of the screen.

### Logging a climbing set

1. Open a Bouldering exercise (or any exercise, then tap **⋮ → Set as climbing**).
2. Scroll through the grade list with **+/−**.
3. Set RPE and tap **SAVE**.

### Planning workouts

1. **Plans tab → + New workout** → give it a name → **+ Add exercises**.
2. **Plans tab → + New plan** → assign workouts to weekdays or specific dates.
3. The Home screen now shows those exercises automatically on the scheduled days.

### Viewing progress

- Open any exercise → **GRAPH** tab.
- Use the chips to switch metrics. Climbing exercises show grade progression automatically.
- **HISTORY** tab shows all sets grouped by date; a gold star marks personal records.

### Backing up / migrating data

1. **Exercises tab → ⋮ → Export backup** — saves a `.json` file.
2. On the new device: **Exercises tab → ⋮ → Import backup** — duplicates are skipped automatically.
3. To import from **FitNotes**: **Exercises ⋮ → Import FitNotes CSV**.

---

## Install

| Platform | How |
|----------|-----|
| **Android** | [Releases](../../releases/latest) → download `training-logger.apk` → open it on your phone |
| **Linux desktop** | [Releases](../../releases/latest) → download `training-logger-linux.zip` → extract → run `bundle/training_logger` |
| **iPhone / iPad** | Open **https://olaks.github.io/training_logger/** in **Safari** → Share → **Add to Home Screen** |
| **Web browser** | Open **https://olaks.github.io/training_logger/** in any browser |

> **Android first install:** allow *Install from unknown sources* in Settings → Security if prompted.  
> **iOS:** must use Safari — Chrome/Firefox on iOS cannot install PWAs.  
> **Linux:** requires GTK3 (`libgtk-3-0`), which is installed by default on most desktop distros.

---

## App source

The app lives in [`flutter_app/`](flutter_app/).  
See [`flutter_app/README.md`](flutter_app/README.md) for developer setup, local build instructions, and data transfer (export/import).
