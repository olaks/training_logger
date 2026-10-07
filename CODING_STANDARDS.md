# Coding standards

Rules a review checks the diff against. Each says what to do and why; the
why decides the cases the rule doesn't spell out.

## Database

**Deletes clear their children and hand back a snapshot.** Foreign keys are
enforced, so a delete removes every row that points at what it deletes, inside
one transaction, and returns a snapshot (`DeletedPlan`, `DeletedWorkout`,
`DeletedPhase`, …) that the matching `restore*` puts back exactly, ids
included. That snapshot is the whole undo mechanism: a new child table means
extending the snapshot and its restore.

**Names match ignoring case, first match winning.** Exercises, workouts and
plans are not unique in the schema, so a lookup by name lowercases both sides
and takes the first row rather than assuming there is one. A rename refuses a
name already taken (`DuplicateNameException`), because duplicates are what
make an import ambiguous.

**Imports build their lookups before the loop.** A backup holds thousands of
rows inside one transaction: load each "already here" set once up front, match
in memory, and insert children with `batch`. A statement count that grows with
the row count is the smell — `test/backup_test.dart` counts them for the plan
log.

## Migrations

**A migration test starts from the generated schema of the version it
upgrades.** Open `SchemaVerifier(GeneratedHelper()).schemaAt(N)`, seed it with
raw SQL, and migrate. A fresh database rewound with `PRAGMA user_version` only
looks old until the next schema change adds a column it already has.

## Widgets

**An undo that outlives its widget goes through the database it captured.**
`showUndoSnackBar` lives on the app-level messenger, so its UNDO can be tapped
after the screen or dialog that offered it has closed, when that widget's
`ref` throws. Read `ref.read(dbProvider)` before the delete and undo through
it. A screen that stays mounted (a bottom-nav tab) can keep using `ref`.
