// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $WorkoutsTable extends Workouts with TableInfo<$WorkoutsTable, Workout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  @override
  List<GeneratedColumn> get $columns => [id, name, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workouts';
  @override
  VerificationContext validateIntegrity(Insertable<Workout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Workout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Workout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
    );
  }

  @override
  $WorkoutsTable createAlias(String alias) {
    return $WorkoutsTable(attachedDatabase, alias);
  }
}

class Workout extends DataClass implements Insertable<Workout> {
  final int id;
  final String name;
  final String notes;
  const Workout({required this.id, required this.name, required this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutsCompanion(
      id: Value(id),
      name: Value(name),
      notes: Value(notes),
    );
  }

  factory Workout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Workout(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String>(notes),
    };
  }

  Workout copyWith({int? id, String? name, String? notes}) => Workout(
        id: id ?? this.id,
        name: name ?? this.name,
        notes: notes ?? this.notes,
      );
  Workout copyWithCompanion(WorkoutsCompanion data) {
    return Workout(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Workout(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Workout &&
          other.id == this.id &&
          other.name == this.name &&
          other.notes == this.notes);
}

class WorkoutsCompanion extends UpdateCompanion<Workout> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> notes;
  const WorkoutsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Workout> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutsCompanion copyWith(
      {Value<int>? id, Value<String>? name, Value<String>? notes}) {
    return WorkoutsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $ExerciseCategoriesTable extends ExerciseCategories
    with TableInfo<$ExerciseCategoriesTable, ExerciseCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupNameMeta =
      const VerificationMeta('groupName');
  @override
  late final GeneratedColumn<String> groupName = GeneratedColumn<String>(
      'group_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _exerciseTypeMeta =
      const VerificationMeta('exerciseType');
  @override
  late final GeneratedColumn<int> exerciseType = GeneratedColumn<int>(
      'exercise_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, groupName, description, exerciseType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_categories';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group_name')) {
      context.handle(_groupNameMeta,
          groupName.isAcceptableOrUnknown(data['group_name']!, _groupNameMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('exercise_type')) {
      context.handle(
          _exerciseTypeMeta,
          exerciseType.isAcceptableOrUnknown(
              data['exercise_type']!, _exerciseTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      groupName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_name']),
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      exerciseType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}exercise_type'])!,
    );
  }

  @override
  $ExerciseCategoriesTable createAlias(String alias) {
    return $ExerciseCategoriesTable(attachedDatabase, alias);
  }
}

class ExerciseCategory extends DataClass
    implements Insertable<ExerciseCategory> {
  final int id;
  final String name;
  final String? groupName;
  final String? description;
  final int exerciseType;
  const ExerciseCategory(
      {required this.id,
      required this.name,
      this.groupName,
      this.description,
      required this.exerciseType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || groupName != null) {
      map['group_name'] = Variable<String>(groupName);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['exercise_type'] = Variable<int>(exerciseType);
    return map;
  }

  ExerciseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      groupName: groupName == null && nullToAbsent
          ? const Value.absent()
          : Value(groupName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      exerciseType: Value(exerciseType),
    );
  }

  factory ExerciseCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      groupName: serializer.fromJson<String?>(json['groupName']),
      description: serializer.fromJson<String?>(json['description']),
      exerciseType: serializer.fromJson<int>(json['exerciseType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'groupName': serializer.toJson<String?>(groupName),
      'description': serializer.toJson<String?>(description),
      'exerciseType': serializer.toJson<int>(exerciseType),
    };
  }

  ExerciseCategory copyWith(
          {int? id,
          String? name,
          Value<String?> groupName = const Value.absent(),
          Value<String?> description = const Value.absent(),
          int? exerciseType}) =>
      ExerciseCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        groupName: groupName.present ? groupName.value : this.groupName,
        description: description.present ? description.value : this.description,
        exerciseType: exerciseType ?? this.exerciseType,
      );
  ExerciseCategory copyWithCompanion(ExerciseCategoriesCompanion data) {
    return ExerciseCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      groupName: data.groupName.present ? data.groupName.value : this.groupName,
      description:
          data.description.present ? data.description.value : this.description,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('description: $description, ')
          ..write('exerciseType: $exerciseType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, groupName, description, exerciseType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.groupName == this.groupName &&
          other.description == this.description &&
          other.exerciseType == this.exerciseType);
}

class ExerciseCategoriesCompanion extends UpdateCompanion<ExerciseCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> groupName;
  final Value<String?> description;
  final Value<int> exerciseType;
  const ExerciseCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.groupName = const Value.absent(),
    this.description = const Value.absent(),
    this.exerciseType = const Value.absent(),
  });
  ExerciseCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.groupName = const Value.absent(),
    this.description = const Value.absent(),
    this.exerciseType = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ExerciseCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? groupName,
    Expression<String>? description,
    Expression<int>? exerciseType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (groupName != null) 'group_name': groupName,
      if (description != null) 'description': description,
      if (exerciseType != null) 'exercise_type': exerciseType,
    });
  }

  ExerciseCategoriesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? groupName,
      Value<String?>? description,
      Value<int>? exerciseType}) {
    return ExerciseCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      groupName: groupName ?? this.groupName,
      description: description ?? this.description,
      exerciseType: exerciseType ?? this.exerciseType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (groupName.present) {
      map['group_name'] = Variable<String>(groupName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<int>(exerciseType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('groupName: $groupName, ')
          ..write('description: $description, ')
          ..write('exerciseType: $exerciseType')
          ..write(')'))
        .toString();
  }
}

class $WorkoutExercisesTable extends WorkoutExercises
    with TableInfo<$WorkoutExercisesTable, WorkoutExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _targetSetsMeta =
      const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
      'target_sets', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetRepsMeta =
      const VerificationMeta('targetReps');
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
      'target_reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetRpeMeta =
      const VerificationMeta('targetRpe');
  @override
  late final GeneratedColumn<int> targetRpe = GeneratedColumn<int>(
      'target_rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, workoutId, categoryId, targetSets, targetReps, targetRpe, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_exercises';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutExercise> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
          _targetSetsMeta,
          targetSets.isAcceptableOrUnknown(
              data['target_sets']!, _targetSetsMeta));
    }
    if (data.containsKey('target_reps')) {
      context.handle(
          _targetRepsMeta,
          targetReps.isAcceptableOrUnknown(
              data['target_reps']!, _targetRepsMeta));
    }
    if (data.containsKey('target_rpe')) {
      context.handle(_targetRpeMeta,
          targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutExercise(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      targetSets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_sets']),
      targetReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_reps']),
      targetRpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_rpe']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $WorkoutExercisesTable createAlias(String alias) {
    return $WorkoutExercisesTable(attachedDatabase, alias);
  }
}

class WorkoutExercise extends DataClass implements Insertable<WorkoutExercise> {
  final int id;
  final int workoutId;
  final int categoryId;
  final int? targetSets;
  final int? targetReps;
  final int? targetRpe;
  final int sortOrder;
  const WorkoutExercise(
      {required this.id,
      required this.workoutId,
      required this.categoryId,
      this.targetSets,
      this.targetReps,
      this.targetRpe,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['workout_id'] = Variable<int>(workoutId);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || targetSets != null) {
      map['target_sets'] = Variable<int>(targetSets);
    }
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<int>(targetRpe);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  WorkoutExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutExercisesCompanion(
      id: Value(id),
      workoutId: Value(workoutId),
      categoryId: Value(categoryId),
      targetSets: targetSets == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSets),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
      sortOrder: Value(sortOrder),
    );
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutExercise(
      id: serializer.fromJson<int>(json['id']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      targetSets: serializer.fromJson<int?>(json['targetSets']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      targetRpe: serializer.fromJson<int?>(json['targetRpe']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'workoutId': serializer.toJson<int>(workoutId),
      'categoryId': serializer.toJson<int>(categoryId),
      'targetSets': serializer.toJson<int?>(targetSets),
      'targetReps': serializer.toJson<int?>(targetReps),
      'targetRpe': serializer.toJson<int?>(targetRpe),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  WorkoutExercise copyWith(
          {int? id,
          int? workoutId,
          int? categoryId,
          Value<int?> targetSets = const Value.absent(),
          Value<int?> targetReps = const Value.absent(),
          Value<int?> targetRpe = const Value.absent(),
          int? sortOrder}) =>
      WorkoutExercise(
        id: id ?? this.id,
        workoutId: workoutId ?? this.workoutId,
        categoryId: categoryId ?? this.categoryId,
        targetSets: targetSets.present ? targetSets.value : this.targetSets,
        targetReps: targetReps.present ? targetReps.value : this.targetReps,
        targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  WorkoutExercise copyWithCompanion(WorkoutExercisesCompanion data) {
    return WorkoutExercise(
      id: data.id.present ? data.id.value : this.id,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      targetSets:
          data.targetSets.present ? data.targetSets.value : this.targetSets,
      targetReps:
          data.targetReps.present ? data.targetReps.value : this.targetReps,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercise(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, workoutId, categoryId, targetSets, targetReps, targetRpe, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutExercise &&
          other.id == this.id &&
          other.workoutId == this.workoutId &&
          other.categoryId == this.categoryId &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.targetRpe == this.targetRpe &&
          other.sortOrder == this.sortOrder);
}

class WorkoutExercisesCompanion extends UpdateCompanion<WorkoutExercise> {
  final Value<int> id;
  final Value<int> workoutId;
  final Value<int> categoryId;
  final Value<int?> targetSets;
  final Value<int?> targetReps;
  final Value<int?> targetRpe;
  final Value<int> sortOrder;
  const WorkoutExercisesCompanion({
    this.id = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  WorkoutExercisesCompanion.insert({
    this.id = const Value.absent(),
    required int workoutId,
    required int categoryId,
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : workoutId = Value(workoutId),
        categoryId = Value(categoryId);
  static Insertable<WorkoutExercise> custom({
    Expression<int>? id,
    Expression<int>? workoutId,
    Expression<int>? categoryId,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<int>? targetRpe,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workoutId != null) 'workout_id': workoutId,
      if (categoryId != null) 'category_id': categoryId,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  WorkoutExercisesCompanion copyWith(
      {Value<int>? id,
      Value<int>? workoutId,
      Value<int>? categoryId,
      Value<int?>? targetSets,
      Value<int?>? targetReps,
      Value<int?>? targetRpe,
      Value<int>? sortOrder}) {
    return WorkoutExercisesCompanion(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      categoryId: categoryId ?? this.categoryId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetRpe: targetRpe ?? this.targetRpe,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<int>(targetRpe.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutExercisesCompanion(')
          ..write('id: $id, ')
          ..write('workoutId: $workoutId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, Plan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _cycleDaysMeta =
      const VerificationMeta('cycleDays');
  @override
  late final GeneratedColumn<int> cycleDays = GeneratedColumn<int>(
      'cycle_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(8));
  @override
  List<GeneratedColumn> get $columns => [id, name, active, cycleDays];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(Insertable<Plan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('cycle_days')) {
      context.handle(_cycleDaysMeta,
          cycleDays.isAcceptableOrUnknown(data['cycle_days']!, _cycleDaysMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      cycleDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cycle_days'])!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class Plan extends DataClass implements Insertable<Plan> {
  final int id;
  final String name;
  final bool active;
  final int cycleDays;
  const Plan(
      {required this.id,
      required this.name,
      required this.active,
      required this.cycleDays});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['active'] = Variable<bool>(active);
    map['cycle_days'] = Variable<int>(cycleDays);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      name: Value(name),
      active: Value(active),
      cycleDays: Value(cycleDays),
    );
  }

  factory Plan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plan(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      active: serializer.fromJson<bool>(json['active']),
      cycleDays: serializer.fromJson<int>(json['cycleDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'active': serializer.toJson<bool>(active),
      'cycleDays': serializer.toJson<int>(cycleDays),
    };
  }

  Plan copyWith({int? id, String? name, bool? active, int? cycleDays}) => Plan(
        id: id ?? this.id,
        name: name ?? this.name,
        active: active ?? this.active,
        cycleDays: cycleDays ?? this.cycleDays,
      );
  Plan copyWithCompanion(PlansCompanion data) {
    return Plan(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      active: data.active.present ? data.active.value : this.active,
      cycleDays: data.cycleDays.present ? data.cycleDays.value : this.cycleDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plan(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('cycleDays: $cycleDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, active, cycleDays);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plan &&
          other.id == this.id &&
          other.name == this.name &&
          other.active == this.active &&
          other.cycleDays == this.cycleDays);
}

class PlansCompanion extends UpdateCompanion<Plan> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> active;
  final Value<int> cycleDays;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.active = const Value.absent(),
    this.cycleDays = const Value.absent(),
  });
  PlansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.active = const Value.absent(),
    this.cycleDays = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Plan> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? active,
    Expression<int>? cycleDays,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (active != null) 'active': active,
      if (cycleDays != null) 'cycle_days': cycleDays,
    });
  }

  PlansCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<bool>? active,
      Value<int>? cycleDays}) {
    return PlansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      cycleDays: cycleDays ?? this.cycleDays,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (cycleDays.present) {
      map['cycle_days'] = Variable<int>(cycleDays.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('active: $active, ')
          ..write('cycleDays: $cycleDays')
          ..write(')'))
        .toString();
  }
}

class $PlanWorkoutsTable extends PlanWorkouts
    with TableInfo<$PlanWorkoutsTable, PlanWorkout> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanWorkoutsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plans (id)'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, workoutId, dateStr, weekday];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_workouts';
  @override
  VerificationContext validateIntegrity(Insertable<PlanWorkout> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    }
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanWorkout map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanWorkout(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str']),
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday']),
    );
  }

  @override
  $PlanWorkoutsTable createAlias(String alias) {
    return $PlanWorkoutsTable(attachedDatabase, alias);
  }
}

class PlanWorkout extends DataClass implements Insertable<PlanWorkout> {
  final int id;
  final int planId;
  final int workoutId;
  final String? dateStr;
  final int? weekday;
  const PlanWorkout(
      {required this.id,
      required this.planId,
      required this.workoutId,
      this.dateStr,
      this.weekday});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['workout_id'] = Variable<int>(workoutId);
    if (!nullToAbsent || dateStr != null) {
      map['date_str'] = Variable<String>(dateStr);
    }
    if (!nullToAbsent || weekday != null) {
      map['weekday'] = Variable<int>(weekday);
    }
    return map;
  }

  PlanWorkoutsCompanion toCompanion(bool nullToAbsent) {
    return PlanWorkoutsCompanion(
      id: Value(id),
      planId: Value(planId),
      workoutId: Value(workoutId),
      dateStr: dateStr == null && nullToAbsent
          ? const Value.absent()
          : Value(dateStr),
      weekday: weekday == null && nullToAbsent
          ? const Value.absent()
          : Value(weekday),
    );
  }

  factory PlanWorkout.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanWorkout(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      dateStr: serializer.fromJson<String?>(json['dateStr']),
      weekday: serializer.fromJson<int?>(json['weekday']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'workoutId': serializer.toJson<int>(workoutId),
      'dateStr': serializer.toJson<String?>(dateStr),
      'weekday': serializer.toJson<int?>(weekday),
    };
  }

  PlanWorkout copyWith(
          {int? id,
          int? planId,
          int? workoutId,
          Value<String?> dateStr = const Value.absent(),
          Value<int?> weekday = const Value.absent()}) =>
      PlanWorkout(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        workoutId: workoutId ?? this.workoutId,
        dateStr: dateStr.present ? dateStr.value : this.dateStr,
        weekday: weekday.present ? weekday.value : this.weekday,
      );
  PlanWorkout copyWithCompanion(PlanWorkoutsCompanion data) {
    return PlanWorkout(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanWorkout(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateStr: $dateStr, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, workoutId, dateStr, weekday);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanWorkout &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.workoutId == this.workoutId &&
          other.dateStr == this.dateStr &&
          other.weekday == this.weekday);
}

class PlanWorkoutsCompanion extends UpdateCompanion<PlanWorkout> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> workoutId;
  final Value<String?> dateStr;
  final Value<int?> weekday;
  const PlanWorkoutsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.dateStr = const Value.absent(),
    this.weekday = const Value.absent(),
  });
  PlanWorkoutsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int workoutId,
    this.dateStr = const Value.absent(),
    this.weekday = const Value.absent(),
  })  : planId = Value(planId),
        workoutId = Value(workoutId);
  static Insertable<PlanWorkout> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? workoutId,
    Expression<String>? dateStr,
    Expression<int>? weekday,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (workoutId != null) 'workout_id': workoutId,
      if (dateStr != null) 'date_str': dateStr,
      if (weekday != null) 'weekday': weekday,
    });
  }

  PlanWorkoutsCompanion copyWith(
      {Value<int>? id,
      Value<int>? planId,
      Value<int>? workoutId,
      Value<String?>? dateStr,
      Value<int?>? weekday}) {
    return PlanWorkoutsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      workoutId: workoutId ?? this.workoutId,
      dateStr: dateStr ?? this.dateStr,
      weekday: weekday ?? this.weekday,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanWorkoutsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('workoutId: $workoutId, ')
          ..write('dateStr: $dateStr, ')
          ..write('weekday: $weekday')
          ..write(')'))
        .toString();
  }
}

class $PlanPhasesTable extends PlanPhases
    with TableInfo<$PlanPhasesTable, PlanPhase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanPhasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plans (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lengthPassesMeta =
      const VerificationMeta('lengthPasses');
  @override
  late final GeneratedColumn<int> lengthPasses = GeneratedColumn<int>(
      'length_passes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _deloadEveryMeta =
      const VerificationMeta('deloadEvery');
  @override
  late final GeneratedColumn<int> deloadEvery = GeneratedColumn<int>(
      'deload_every', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, sortOrder, name, lengthPasses, deloadEvery];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_phases';
  @override
  VerificationContext validateIntegrity(Insertable<PlanPhase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('length_passes')) {
      context.handle(
          _lengthPassesMeta,
          lengthPasses.isAcceptableOrUnknown(
              data['length_passes']!, _lengthPassesMeta));
    } else if (isInserting) {
      context.missing(_lengthPassesMeta);
    }
    if (data.containsKey('deload_every')) {
      context.handle(
          _deloadEveryMeta,
          deloadEvery.isAcceptableOrUnknown(
              data['deload_every']!, _deloadEveryMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanPhase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanPhase(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lengthPasses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}length_passes'])!,
      deloadEvery: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deload_every']),
    );
  }

  @override
  $PlanPhasesTable createAlias(String alias) {
    return $PlanPhasesTable(attachedDatabase, alias);
  }
}

class PlanPhase extends DataClass implements Insertable<PlanPhase> {
  final int id;
  final int planId;
  final int sortOrder;
  final String name;
  final int lengthPasses;
  final int? deloadEvery;
  const PlanPhase(
      {required this.id,
      required this.planId,
      required this.sortOrder,
      required this.name,
      required this.lengthPasses,
      this.deloadEvery});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['name'] = Variable<String>(name);
    map['length_passes'] = Variable<int>(lengthPasses);
    if (!nullToAbsent || deloadEvery != null) {
      map['deload_every'] = Variable<int>(deloadEvery);
    }
    return map;
  }

  PlanPhasesCompanion toCompanion(bool nullToAbsent) {
    return PlanPhasesCompanion(
      id: Value(id),
      planId: Value(planId),
      sortOrder: Value(sortOrder),
      name: Value(name),
      lengthPasses: Value(lengthPasses),
      deloadEvery: deloadEvery == null && nullToAbsent
          ? const Value.absent()
          : Value(deloadEvery),
    );
  }

  factory PlanPhase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanPhase(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      name: serializer.fromJson<String>(json['name']),
      lengthPasses: serializer.fromJson<int>(json['lengthPasses']),
      deloadEvery: serializer.fromJson<int?>(json['deloadEvery']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'name': serializer.toJson<String>(name),
      'lengthPasses': serializer.toJson<int>(lengthPasses),
      'deloadEvery': serializer.toJson<int?>(deloadEvery),
    };
  }

  PlanPhase copyWith(
          {int? id,
          int? planId,
          int? sortOrder,
          String? name,
          int? lengthPasses,
          Value<int?> deloadEvery = const Value.absent()}) =>
      PlanPhase(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        sortOrder: sortOrder ?? this.sortOrder,
        name: name ?? this.name,
        lengthPasses: lengthPasses ?? this.lengthPasses,
        deloadEvery: deloadEvery.present ? deloadEvery.value : this.deloadEvery,
      );
  PlanPhase copyWithCompanion(PlanPhasesCompanion data) {
    return PlanPhase(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      name: data.name.present ? data.name.value : this.name,
      lengthPasses: data.lengthPasses.present
          ? data.lengthPasses.value
          : this.lengthPasses,
      deloadEvery:
          data.deloadEvery.present ? data.deloadEvery.value : this.deloadEvery,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanPhase(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('lengthPasses: $lengthPasses, ')
          ..write('deloadEvery: $deloadEvery')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, sortOrder, name, lengthPasses, deloadEvery);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanPhase &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.sortOrder == this.sortOrder &&
          other.name == this.name &&
          other.lengthPasses == this.lengthPasses &&
          other.deloadEvery == this.deloadEvery);
}

class PlanPhasesCompanion extends UpdateCompanion<PlanPhase> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> sortOrder;
  final Value<String> name;
  final Value<int> lengthPasses;
  final Value<int?> deloadEvery;
  const PlanPhasesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.name = const Value.absent(),
    this.lengthPasses = const Value.absent(),
    this.deloadEvery = const Value.absent(),
  });
  PlanPhasesCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    this.sortOrder = const Value.absent(),
    required String name,
    required int lengthPasses,
    this.deloadEvery = const Value.absent(),
  })  : planId = Value(planId),
        name = Value(name),
        lengthPasses = Value(lengthPasses);
  static Insertable<PlanPhase> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? sortOrder,
    Expression<String>? name,
    Expression<int>? lengthPasses,
    Expression<int>? deloadEvery,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (name != null) 'name': name,
      if (lengthPasses != null) 'length_passes': lengthPasses,
      if (deloadEvery != null) 'deload_every': deloadEvery,
    });
  }

  PlanPhasesCompanion copyWith(
      {Value<int>? id,
      Value<int>? planId,
      Value<int>? sortOrder,
      Value<String>? name,
      Value<int>? lengthPasses,
      Value<int?>? deloadEvery}) {
    return PlanPhasesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      sortOrder: sortOrder ?? this.sortOrder,
      name: name ?? this.name,
      lengthPasses: lengthPasses ?? this.lengthPasses,
      deloadEvery: deloadEvery ?? this.deloadEvery,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lengthPasses.present) {
      map['length_passes'] = Variable<int>(lengthPasses.value);
    }
    if (deloadEvery.present) {
      map['deload_every'] = Variable<int>(deloadEvery.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanPhasesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('name: $name, ')
          ..write('lengthPasses: $lengthPasses, ')
          ..write('deloadEvery: $deloadEvery')
          ..write(')'))
        .toString();
  }
}

class $PhaseSessionsTable extends PhaseSessions
    with TableInfo<$PhaseSessionsTable, PhaseSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhaseSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _phaseIdMeta =
      const VerificationMeta('phaseId');
  @override
  late final GeneratedColumn<int> phaseId = GeneratedColumn<int>(
      'phase_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plan_phases (id)'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
      'day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns =>
      [id, phaseId, workoutId, sortOrder, day];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phase_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<PhaseSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phase_id')) {
      context.handle(_phaseIdMeta,
          phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta));
    } else if (isInserting) {
      context.missing(_phaseIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    } else if (isInserting) {
      context.missing(_workoutIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhaseSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      phaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phase_id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day'])!,
    );
  }

  @override
  $PhaseSessionsTable createAlias(String alias) {
    return $PhaseSessionsTable(attachedDatabase, alias);
  }
}

class PhaseSession extends DataClass implements Insertable<PhaseSession> {
  final int id;
  final int phaseId;
  final int workoutId;
  final int sortOrder;
  final int day;
  const PhaseSession(
      {required this.id,
      required this.phaseId,
      required this.workoutId,
      required this.sortOrder,
      required this.day});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phase_id'] = Variable<int>(phaseId);
    map['workout_id'] = Variable<int>(workoutId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['day'] = Variable<int>(day);
    return map;
  }

  PhaseSessionsCompanion toCompanion(bool nullToAbsent) {
    return PhaseSessionsCompanion(
      id: Value(id),
      phaseId: Value(phaseId),
      workoutId: Value(workoutId),
      sortOrder: Value(sortOrder),
      day: Value(day),
    );
  }

  factory PhaseSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhaseSession(
      id: serializer.fromJson<int>(json['id']),
      phaseId: serializer.fromJson<int>(json['phaseId']),
      workoutId: serializer.fromJson<int>(json['workoutId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      day: serializer.fromJson<int>(json['day']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phaseId': serializer.toJson<int>(phaseId),
      'workoutId': serializer.toJson<int>(workoutId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'day': serializer.toJson<int>(day),
    };
  }

  PhaseSession copyWith(
          {int? id, int? phaseId, int? workoutId, int? sortOrder, int? day}) =>
      PhaseSession(
        id: id ?? this.id,
        phaseId: phaseId ?? this.phaseId,
        workoutId: workoutId ?? this.workoutId,
        sortOrder: sortOrder ?? this.sortOrder,
        day: day ?? this.day,
      );
  PhaseSession copyWithCompanion(PhaseSessionsCompanion data) {
    return PhaseSession(
      id: data.id.present ? data.id.value : this.id,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      day: data.day.present ? data.day.value : this.day,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSession(')
          ..write('id: $id, ')
          ..write('phaseId: $phaseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, phaseId, workoutId, sortOrder, day);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhaseSession &&
          other.id == this.id &&
          other.phaseId == this.phaseId &&
          other.workoutId == this.workoutId &&
          other.sortOrder == this.sortOrder &&
          other.day == this.day);
}

class PhaseSessionsCompanion extends UpdateCompanion<PhaseSession> {
  final Value<int> id;
  final Value<int> phaseId;
  final Value<int> workoutId;
  final Value<int> sortOrder;
  final Value<int> day;
  const PhaseSessionsCompanion({
    this.id = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.day = const Value.absent(),
  });
  PhaseSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int phaseId,
    required int workoutId,
    this.sortOrder = const Value.absent(),
    this.day = const Value.absent(),
  })  : phaseId = Value(phaseId),
        workoutId = Value(workoutId);
  static Insertable<PhaseSession> custom({
    Expression<int>? id,
    Expression<int>? phaseId,
    Expression<int>? workoutId,
    Expression<int>? sortOrder,
    Expression<int>? day,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phaseId != null) 'phase_id': phaseId,
      if (workoutId != null) 'workout_id': workoutId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (day != null) 'day': day,
    });
  }

  PhaseSessionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? phaseId,
      Value<int>? workoutId,
      Value<int>? sortOrder,
      Value<int>? day}) {
    return PhaseSessionsCompanion(
      id: id ?? this.id,
      phaseId: phaseId ?? this.phaseId,
      workoutId: workoutId ?? this.workoutId,
      sortOrder: sortOrder ?? this.sortOrder,
      day: day ?? this.day,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<int>(phaseId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSessionsCompanion(')
          ..write('id: $id, ')
          ..write('phaseId: $phaseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('day: $day')
          ..write(')'))
        .toString();
  }
}

class $PhaseExerciseTargetsTable extends PhaseExerciseTargets
    with TableInfo<$PhaseExerciseTargetsTable, PhaseExerciseTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhaseExerciseTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _phaseIdMeta =
      const VerificationMeta('phaseId');
  @override
  late final GeneratedColumn<int> phaseId = GeneratedColumn<int>(
      'phase_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plan_phases (id)'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _targetRpeMeta =
      const VerificationMeta('targetRpe');
  @override
  late final GeneratedColumn<int> targetRpe = GeneratedColumn<int>(
      'target_rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetSetsMeta =
      const VerificationMeta('targetSets');
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
      'target_sets', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _targetRepsMeta =
      const VerificationMeta('targetReps');
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
      'target_reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, phaseId, categoryId, targetRpe, targetSets, targetReps];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phase_exercise_targets';
  @override
  VerificationContext validateIntegrity(
      Insertable<PhaseExerciseTarget> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('phase_id')) {
      context.handle(_phaseIdMeta,
          phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta));
    } else if (isInserting) {
      context.missing(_phaseIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('target_rpe')) {
      context.handle(_targetRpeMeta,
          targetRpe.isAcceptableOrUnknown(data['target_rpe']!, _targetRpeMeta));
    }
    if (data.containsKey('target_sets')) {
      context.handle(
          _targetSetsMeta,
          targetSets.isAcceptableOrUnknown(
              data['target_sets']!, _targetSetsMeta));
    }
    if (data.containsKey('target_reps')) {
      context.handle(
          _targetRepsMeta,
          targetReps.isAcceptableOrUnknown(
              data['target_reps']!, _targetRepsMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhaseExerciseTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseExerciseTarget(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      phaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phase_id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      targetRpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_rpe']),
      targetSets: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_sets']),
      targetReps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}target_reps']),
    );
  }

  @override
  $PhaseExerciseTargetsTable createAlias(String alias) {
    return $PhaseExerciseTargetsTable(attachedDatabase, alias);
  }
}

class PhaseExerciseTarget extends DataClass
    implements Insertable<PhaseExerciseTarget> {
  final int id;
  final int phaseId;
  final int categoryId;
  final int? targetRpe;
  final int? targetSets;
  final int? targetReps;
  const PhaseExerciseTarget(
      {required this.id,
      required this.phaseId,
      required this.categoryId,
      this.targetRpe,
      this.targetSets,
      this.targetReps});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['phase_id'] = Variable<int>(phaseId);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || targetRpe != null) {
      map['target_rpe'] = Variable<int>(targetRpe);
    }
    if (!nullToAbsent || targetSets != null) {
      map['target_sets'] = Variable<int>(targetSets);
    }
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    return map;
  }

  PhaseExerciseTargetsCompanion toCompanion(bool nullToAbsent) {
    return PhaseExerciseTargetsCompanion(
      id: Value(id),
      phaseId: Value(phaseId),
      categoryId: Value(categoryId),
      targetRpe: targetRpe == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRpe),
      targetSets: targetSets == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSets),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
    );
  }

  factory PhaseExerciseTarget.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhaseExerciseTarget(
      id: serializer.fromJson<int>(json['id']),
      phaseId: serializer.fromJson<int>(json['phaseId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      targetRpe: serializer.fromJson<int?>(json['targetRpe']),
      targetSets: serializer.fromJson<int?>(json['targetSets']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'phaseId': serializer.toJson<int>(phaseId),
      'categoryId': serializer.toJson<int>(categoryId),
      'targetRpe': serializer.toJson<int?>(targetRpe),
      'targetSets': serializer.toJson<int?>(targetSets),
      'targetReps': serializer.toJson<int?>(targetReps),
    };
  }

  PhaseExerciseTarget copyWith(
          {int? id,
          int? phaseId,
          int? categoryId,
          Value<int?> targetRpe = const Value.absent(),
          Value<int?> targetSets = const Value.absent(),
          Value<int?> targetReps = const Value.absent()}) =>
      PhaseExerciseTarget(
        id: id ?? this.id,
        phaseId: phaseId ?? this.phaseId,
        categoryId: categoryId ?? this.categoryId,
        targetRpe: targetRpe.present ? targetRpe.value : this.targetRpe,
        targetSets: targetSets.present ? targetSets.value : this.targetSets,
        targetReps: targetReps.present ? targetReps.value : this.targetReps,
      );
  PhaseExerciseTarget copyWithCompanion(PhaseExerciseTargetsCompanion data) {
    return PhaseExerciseTarget(
      id: data.id.present ? data.id.value : this.id,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      targetRpe: data.targetRpe.present ? data.targetRpe.value : this.targetRpe,
      targetSets:
          data.targetSets.present ? data.targetSets.value : this.targetSets,
      targetReps:
          data.targetReps.present ? data.targetReps.value : this.targetReps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhaseExerciseTarget(')
          ..write('id: $id, ')
          ..write('phaseId: $phaseId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, phaseId, categoryId, targetRpe, targetSets, targetReps);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhaseExerciseTarget &&
          other.id == this.id &&
          other.phaseId == this.phaseId &&
          other.categoryId == this.categoryId &&
          other.targetRpe == this.targetRpe &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps);
}

class PhaseExerciseTargetsCompanion
    extends UpdateCompanion<PhaseExerciseTarget> {
  final Value<int> id;
  final Value<int> phaseId;
  final Value<int> categoryId;
  final Value<int?> targetRpe;
  final Value<int?> targetSets;
  final Value<int?> targetReps;
  const PhaseExerciseTargetsCompanion({
    this.id = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.targetRpe = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
  });
  PhaseExerciseTargetsCompanion.insert({
    this.id = const Value.absent(),
    required int phaseId,
    required int categoryId,
    this.targetRpe = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
  })  : phaseId = Value(phaseId),
        categoryId = Value(categoryId);
  static Insertable<PhaseExerciseTarget> custom({
    Expression<int>? id,
    Expression<int>? phaseId,
    Expression<int>? categoryId,
    Expression<int>? targetRpe,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (phaseId != null) 'phase_id': phaseId,
      if (categoryId != null) 'category_id': categoryId,
      if (targetRpe != null) 'target_rpe': targetRpe,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
    });
  }

  PhaseExerciseTargetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? phaseId,
      Value<int>? categoryId,
      Value<int?>? targetRpe,
      Value<int?>? targetSets,
      Value<int?>? targetReps}) {
    return PhaseExerciseTargetsCompanion(
      id: id ?? this.id,
      phaseId: phaseId ?? this.phaseId,
      categoryId: categoryId ?? this.categoryId,
      targetRpe: targetRpe ?? this.targetRpe,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<int>(phaseId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (targetRpe.present) {
      map['target_rpe'] = Variable<int>(targetRpe.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhaseExerciseTargetsCompanion(')
          ..write('id: $id, ')
          ..write('phaseId: $phaseId, ')
          ..write('categoryId: $categoryId, ')
          ..write('targetRpe: $targetRpe, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps')
          ..write(')'))
        .toString();
  }
}

class $PlanEventsTable extends PlanEvents
    with TableInfo<$PlanEventsTable, PlanEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plans (id)'));
  static const VerificationMeta _phaseIdMeta =
      const VerificationMeta('phaseId');
  @override
  late final GeneratedColumn<int> phaseId = GeneratedColumn<int>(
      'phase_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES plan_phases (id)'));
  static const VerificationMeta _workoutIdMeta =
      const VerificationMeta('workoutId');
  @override
  late final GeneratedColumn<int> workoutId = GeneratedColumn<int>(
      'workout_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES workouts (id)'));
  static const VerificationMeta _passMeta = const VerificationMeta('pass');
  @override
  late final GeneratedColumn<int> pass = GeneratedColumn<int>(
      'pass', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
      'day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _closesDayMeta =
      const VerificationMeta('closesDay');
  @override
  late final GeneratedColumn<bool> closesDay = GeneratedColumn<bool>(
      'closes_day', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("closes_day" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<PlanEventKind, int> kind =
      GeneratedColumn<int>('kind', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PlanEventKind>($PlanEventsTable.$converterkind);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        planId,
        phaseId,
        workoutId,
        pass,
        day,
        closesDay,
        dateStr,
        timestamp,
        kind
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_events';
  @override
  VerificationContext validateIntegrity(Insertable<PlanEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('phase_id')) {
      context.handle(_phaseIdMeta,
          phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta));
    } else if (isInserting) {
      context.missing(_phaseIdMeta);
    }
    if (data.containsKey('workout_id')) {
      context.handle(_workoutIdMeta,
          workoutId.isAcceptableOrUnknown(data['workout_id']!, _workoutIdMeta));
    }
    if (data.containsKey('pass')) {
      context.handle(
          _passMeta, pass.isAcceptableOrUnknown(data['pass']!, _passMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    }
    if (data.containsKey('closes_day')) {
      context.handle(_closesDayMeta,
          closesDay.isAcceptableOrUnknown(data['closes_day']!, _closesDayMeta));
    }
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}plan_id'])!,
      phaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}phase_id'])!,
      workoutId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}workout_id']),
      pass: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pass']),
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day']),
      closesDay: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}closes_day'])!,
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      kind: $PlanEventsTable.$converterkind.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}kind'])!),
    );
  }

  @override
  $PlanEventsTable createAlias(String alias) {
    return $PlanEventsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PlanEventKind, int, int> $converterkind =
      const EnumIndexConverter<PlanEventKind>(PlanEventKind.values);
}

class PlanEvent extends DataClass implements Insertable<PlanEvent> {
  final int id;
  final int planId;
  final int phaseId;
  final int? workoutId;
  final int? pass;
  final int? day;
  final bool closesDay;
  final String dateStr;
  final int timestamp;
  final PlanEventKind kind;
  const PlanEvent(
      {required this.id,
      required this.planId,
      required this.phaseId,
      this.workoutId,
      this.pass,
      this.day,
      required this.closesDay,
      required this.dateStr,
      required this.timestamp,
      required this.kind});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['phase_id'] = Variable<int>(phaseId);
    if (!nullToAbsent || workoutId != null) {
      map['workout_id'] = Variable<int>(workoutId);
    }
    if (!nullToAbsent || pass != null) {
      map['pass'] = Variable<int>(pass);
    }
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<int>(day);
    }
    map['closes_day'] = Variable<bool>(closesDay);
    map['date_str'] = Variable<String>(dateStr);
    map['timestamp'] = Variable<int>(timestamp);
    {
      map['kind'] = Variable<int>($PlanEventsTable.$converterkind.toSql(kind));
    }
    return map;
  }

  PlanEventsCompanion toCompanion(bool nullToAbsent) {
    return PlanEventsCompanion(
      id: Value(id),
      planId: Value(planId),
      phaseId: Value(phaseId),
      workoutId: workoutId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutId),
      pass: pass == null && nullToAbsent ? const Value.absent() : Value(pass),
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      closesDay: Value(closesDay),
      dateStr: Value(dateStr),
      timestamp: Value(timestamp),
      kind: Value(kind),
    );
  }

  factory PlanEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanEvent(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      phaseId: serializer.fromJson<int>(json['phaseId']),
      workoutId: serializer.fromJson<int?>(json['workoutId']),
      pass: serializer.fromJson<int?>(json['pass']),
      day: serializer.fromJson<int?>(json['day']),
      closesDay: serializer.fromJson<bool>(json['closesDay']),
      dateStr: serializer.fromJson<String>(json['dateStr']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      kind: $PlanEventsTable.$converterkind
          .fromJson(serializer.fromJson<int>(json['kind'])),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'phaseId': serializer.toJson<int>(phaseId),
      'workoutId': serializer.toJson<int?>(workoutId),
      'pass': serializer.toJson<int?>(pass),
      'day': serializer.toJson<int?>(day),
      'closesDay': serializer.toJson<bool>(closesDay),
      'dateStr': serializer.toJson<String>(dateStr),
      'timestamp': serializer.toJson<int>(timestamp),
      'kind':
          serializer.toJson<int>($PlanEventsTable.$converterkind.toJson(kind)),
    };
  }

  PlanEvent copyWith(
          {int? id,
          int? planId,
          int? phaseId,
          Value<int?> workoutId = const Value.absent(),
          Value<int?> pass = const Value.absent(),
          Value<int?> day = const Value.absent(),
          bool? closesDay,
          String? dateStr,
          int? timestamp,
          PlanEventKind? kind}) =>
      PlanEvent(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        phaseId: phaseId ?? this.phaseId,
        workoutId: workoutId.present ? workoutId.value : this.workoutId,
        pass: pass.present ? pass.value : this.pass,
        day: day.present ? day.value : this.day,
        closesDay: closesDay ?? this.closesDay,
        dateStr: dateStr ?? this.dateStr,
        timestamp: timestamp ?? this.timestamp,
        kind: kind ?? this.kind,
      );
  PlanEvent copyWithCompanion(PlanEventsCompanion data) {
    return PlanEvent(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      workoutId: data.workoutId.present ? data.workoutId.value : this.workoutId,
      pass: data.pass.present ? data.pass.value : this.pass,
      day: data.day.present ? data.day.value : this.day,
      closesDay: data.closesDay.present ? data.closesDay.value : this.closesDay,
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      kind: data.kind.present ? data.kind.value : this.kind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanEvent(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('phaseId: $phaseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('pass: $pass, ')
          ..write('day: $day, ')
          ..write('closesDay: $closesDay, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, phaseId, workoutId, pass, day,
      closesDay, dateStr, timestamp, kind);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanEvent &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.phaseId == this.phaseId &&
          other.workoutId == this.workoutId &&
          other.pass == this.pass &&
          other.day == this.day &&
          other.closesDay == this.closesDay &&
          other.dateStr == this.dateStr &&
          other.timestamp == this.timestamp &&
          other.kind == this.kind);
}

class PlanEventsCompanion extends UpdateCompanion<PlanEvent> {
  final Value<int> id;
  final Value<int> planId;
  final Value<int> phaseId;
  final Value<int?> workoutId;
  final Value<int?> pass;
  final Value<int?> day;
  final Value<bool> closesDay;
  final Value<String> dateStr;
  final Value<int> timestamp;
  final Value<PlanEventKind> kind;
  const PlanEventsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.workoutId = const Value.absent(),
    this.pass = const Value.absent(),
    this.day = const Value.absent(),
    this.closesDay = const Value.absent(),
    this.dateStr = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.kind = const Value.absent(),
  });
  PlanEventsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required int phaseId,
    this.workoutId = const Value.absent(),
    this.pass = const Value.absent(),
    this.day = const Value.absent(),
    this.closesDay = const Value.absent(),
    required String dateStr,
    required int timestamp,
    required PlanEventKind kind,
  })  : planId = Value(planId),
        phaseId = Value(phaseId),
        dateStr = Value(dateStr),
        timestamp = Value(timestamp),
        kind = Value(kind);
  static Insertable<PlanEvent> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<int>? phaseId,
    Expression<int>? workoutId,
    Expression<int>? pass,
    Expression<int>? day,
    Expression<bool>? closesDay,
    Expression<String>? dateStr,
    Expression<int>? timestamp,
    Expression<int>? kind,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (phaseId != null) 'phase_id': phaseId,
      if (workoutId != null) 'workout_id': workoutId,
      if (pass != null) 'pass': pass,
      if (day != null) 'day': day,
      if (closesDay != null) 'closes_day': closesDay,
      if (dateStr != null) 'date_str': dateStr,
      if (timestamp != null) 'timestamp': timestamp,
      if (kind != null) 'kind': kind,
    });
  }

  PlanEventsCompanion copyWith(
      {Value<int>? id,
      Value<int>? planId,
      Value<int>? phaseId,
      Value<int?>? workoutId,
      Value<int?>? pass,
      Value<int?>? day,
      Value<bool>? closesDay,
      Value<String>? dateStr,
      Value<int>? timestamp,
      Value<PlanEventKind>? kind}) {
    return PlanEventsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      phaseId: phaseId ?? this.phaseId,
      workoutId: workoutId ?? this.workoutId,
      pass: pass ?? this.pass,
      day: day ?? this.day,
      closesDay: closesDay ?? this.closesDay,
      dateStr: dateStr ?? this.dateStr,
      timestamp: timestamp ?? this.timestamp,
      kind: kind ?? this.kind,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<int>(phaseId.value);
    }
    if (workoutId.present) {
      map['workout_id'] = Variable<int>(workoutId.value);
    }
    if (pass.present) {
      map['pass'] = Variable<int>(pass.value);
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (closesDay.present) {
      map['closes_day'] = Variable<bool>(closesDay.value);
    }
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (kind.present) {
      map['kind'] =
          Variable<int>($PlanEventsTable.$converterkind.toSql(kind.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanEventsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('phaseId: $phaseId, ')
          ..write('workoutId: $workoutId, ')
          ..write('pass: $pass, ')
          ..write('day: $day, ')
          ..write('closesDay: $closesDay, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('kind: $kind')
          ..write(')'))
        .toString();
  }
}

class $ExerciseImagesTable extends ExerciseImages
    with TableInfo<$ExerciseImagesTable, ExerciseImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
      'data', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [categoryId, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_images';
  @override
  VerificationContext validateIntegrity(Insertable<ExerciseImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  ExerciseImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseImage(
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $ExerciseImagesTable createAlias(String alias) {
    return $ExerciseImagesTable(attachedDatabase, alias);
  }
}

class ExerciseImage extends DataClass implements Insertable<ExerciseImage> {
  final int categoryId;
  final Uint8List data;
  const ExerciseImage({required this.categoryId, required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<int>(categoryId);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  ExerciseImagesCompanion toCompanion(bool nullToAbsent) {
    return ExerciseImagesCompanion(
      categoryId: Value(categoryId),
      data: Value(data),
    );
  }

  factory ExerciseImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseImage(
      categoryId: serializer.fromJson<int>(json['categoryId']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<int>(categoryId),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  ExerciseImage copyWith({int? categoryId, Uint8List? data}) => ExerciseImage(
        categoryId: categoryId ?? this.categoryId,
        data: data ?? this.data,
      );
  ExerciseImage copyWithCompanion(ExerciseImagesCompanion data) {
    return ExerciseImage(
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseImage(')
          ..write('categoryId: $categoryId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseImage &&
          other.categoryId == this.categoryId &&
          $driftBlobEquality.equals(other.data, this.data));
}

class ExerciseImagesCompanion extends UpdateCompanion<ExerciseImage> {
  final Value<int> categoryId;
  final Value<Uint8List> data;
  const ExerciseImagesCompanion({
    this.categoryId = const Value.absent(),
    this.data = const Value.absent(),
  });
  ExerciseImagesCompanion.insert({
    this.categoryId = const Value.absent(),
    required Uint8List data,
  }) : data = Value(data);
  static Insertable<ExerciseImage> custom({
    Expression<int>? categoryId,
    Expression<Uint8List>? data,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (data != null) 'data': data,
    });
  }

  ExerciseImagesCompanion copyWith(
      {Value<int>? categoryId, Value<Uint8List>? data}) {
    return ExerciseImagesCompanion(
      categoryId: categoryId ?? this.categoryId,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseImagesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timeSecsMeta =
      const VerificationMeta('timeSecs');
  @override
  late final GeneratedColumn<int> timeSecs = GeneratedColumn<int>(
      'time_secs', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
      'rpe', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wallAngleMeta =
      const VerificationMeta('wallAngle');
  @override
  late final GeneratedColumn<int> wallAngle = GeneratedColumn<int>(
      'wall_angle', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _climbNameMeta =
      const VerificationMeta('climbName');
  @override
  late final GeneratedColumn<String> climbName = GeneratedColumn<String>(
      'climb_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        categoryId,
        dateStr,
        timestamp,
        weightKg,
        reps,
        timeSecs,
        rpe,
        grade,
        wallAngle,
        climbName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(Insertable<WorkoutSet> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('time_secs')) {
      context.handle(_timeSecsMeta,
          timeSecs.isAcceptableOrUnknown(data['time_secs']!, _timeSecsMeta));
    }
    if (data.containsKey('rpe')) {
      context.handle(
          _rpeMeta, rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta));
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    }
    if (data.containsKey('wall_angle')) {
      context.handle(_wallAngleMeta,
          wallAngle.isAcceptableOrUnknown(data['wall_angle']!, _wallAngleMeta));
    }
    if (data.containsKey('climb_name')) {
      context.handle(_climbNameMeta,
          climbName.isAcceptableOrUnknown(data['climb_name']!, _climbNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id'])!,
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps']),
      timeSecs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_secs']),
      rpe: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rpe']),
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade']),
      wallAngle: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}wall_angle']),
      climbName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}climb_name']),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final int id;
  final int categoryId;
  final String dateStr;
  final int timestamp;
  final double? weightKg;
  final int? reps;
  final int? timeSecs;
  final int? rpe;
  final String? grade;
  final int? wallAngle;
  final String? climbName;
  const WorkoutSet(
      {required this.id,
      required this.categoryId,
      required this.dateStr,
      required this.timestamp,
      this.weightKg,
      this.reps,
      this.timeSecs,
      this.rpe,
      this.grade,
      this.wallAngle,
      this.climbName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category_id'] = Variable<int>(categoryId);
    map['date_str'] = Variable<String>(dateStr);
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || timeSecs != null) {
      map['time_secs'] = Variable<int>(timeSecs);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || grade != null) {
      map['grade'] = Variable<String>(grade);
    }
    if (!nullToAbsent || wallAngle != null) {
      map['wall_angle'] = Variable<int>(wallAngle);
    }
    if (!nullToAbsent || climbName != null) {
      map['climb_name'] = Variable<String>(climbName);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      dateStr: Value(dateStr),
      timestamp: Value(timestamp),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      timeSecs: timeSecs == null && nullToAbsent
          ? const Value.absent()
          : Value(timeSecs),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      grade:
          grade == null && nullToAbsent ? const Value.absent() : Value(grade),
      wallAngle: wallAngle == null && nullToAbsent
          ? const Value.absent()
          : Value(wallAngle),
      climbName: climbName == null && nullToAbsent
          ? const Value.absent()
          : Value(climbName),
    );
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      dateStr: serializer.fromJson<String>(json['dateStr']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      reps: serializer.fromJson<int?>(json['reps']),
      timeSecs: serializer.fromJson<int?>(json['timeSecs']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      grade: serializer.fromJson<String?>(json['grade']),
      wallAngle: serializer.fromJson<int?>(json['wallAngle']),
      climbName: serializer.fromJson<String?>(json['climbName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'dateStr': serializer.toJson<String>(dateStr),
      'timestamp': serializer.toJson<int>(timestamp),
      'weightKg': serializer.toJson<double?>(weightKg),
      'reps': serializer.toJson<int?>(reps),
      'timeSecs': serializer.toJson<int?>(timeSecs),
      'rpe': serializer.toJson<int?>(rpe),
      'grade': serializer.toJson<String?>(grade),
      'wallAngle': serializer.toJson<int?>(wallAngle),
      'climbName': serializer.toJson<String?>(climbName),
    };
  }

  WorkoutSet copyWith(
          {int? id,
          int? categoryId,
          String? dateStr,
          int? timestamp,
          Value<double?> weightKg = const Value.absent(),
          Value<int?> reps = const Value.absent(),
          Value<int?> timeSecs = const Value.absent(),
          Value<int?> rpe = const Value.absent(),
          Value<String?> grade = const Value.absent(),
          Value<int?> wallAngle = const Value.absent(),
          Value<String?> climbName = const Value.absent()}) =>
      WorkoutSet(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        dateStr: dateStr ?? this.dateStr,
        timestamp: timestamp ?? this.timestamp,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        reps: reps.present ? reps.value : this.reps,
        timeSecs: timeSecs.present ? timeSecs.value : this.timeSecs,
        rpe: rpe.present ? rpe.value : this.rpe,
        grade: grade.present ? grade.value : this.grade,
        wallAngle: wallAngle.present ? wallAngle.value : this.wallAngle,
        climbName: climbName.present ? climbName.value : this.climbName,
      );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      timeSecs: data.timeSecs.present ? data.timeSecs.value : this.timeSecs,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      grade: data.grade.present ? data.grade.value : this.grade,
      wallAngle: data.wallAngle.present ? data.wallAngle.value : this.wallAngle,
      climbName: data.climbName.present ? data.climbName.value : this.climbName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('timeSecs: $timeSecs, ')
          ..write('rpe: $rpe, ')
          ..write('grade: $grade, ')
          ..write('wallAngle: $wallAngle, ')
          ..write('climbName: $climbName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, dateStr, timestamp, weightKg,
      reps, timeSecs, rpe, grade, wallAngle, climbName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.dateStr == this.dateStr &&
          other.timestamp == this.timestamp &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.timeSecs == this.timeSecs &&
          other.rpe == this.rpe &&
          other.grade == this.grade &&
          other.wallAngle == this.wallAngle &&
          other.climbName == this.climbName);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> dateStr;
  final Value<int> timestamp;
  final Value<double?> weightKg;
  final Value<int?> reps;
  final Value<int?> timeSecs;
  final Value<int?> rpe;
  final Value<String?> grade;
  final Value<int?> wallAngle;
  final Value<String?> climbName;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dateStr = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.timeSecs = const Value.absent(),
    this.rpe = const Value.absent(),
    this.grade = const Value.absent(),
    this.wallAngle = const Value.absent(),
    this.climbName = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String dateStr,
    required int timestamp,
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.timeSecs = const Value.absent(),
    this.rpe = const Value.absent(),
    this.grade = const Value.absent(),
    this.wallAngle = const Value.absent(),
    this.climbName = const Value.absent(),
  })  : categoryId = Value(categoryId),
        dateStr = Value(dateStr),
        timestamp = Value(timestamp);
  static Insertable<WorkoutSet> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? dateStr,
    Expression<int>? timestamp,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? timeSecs,
    Expression<int>? rpe,
    Expression<String>? grade,
    Expression<int>? wallAngle,
    Expression<String>? climbName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (dateStr != null) 'date_str': dateStr,
      if (timestamp != null) 'timestamp': timestamp,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (timeSecs != null) 'time_secs': timeSecs,
      if (rpe != null) 'rpe': rpe,
      if (grade != null) 'grade': grade,
      if (wallAngle != null) 'wall_angle': wallAngle,
      if (climbName != null) 'climb_name': climbName,
    });
  }

  WorkoutSetsCompanion copyWith(
      {Value<int>? id,
      Value<int>? categoryId,
      Value<String>? dateStr,
      Value<int>? timestamp,
      Value<double?>? weightKg,
      Value<int?>? reps,
      Value<int?>? timeSecs,
      Value<int?>? rpe,
      Value<String?>? grade,
      Value<int?>? wallAngle,
      Value<String?>? climbName}) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      dateStr: dateStr ?? this.dateStr,
      timestamp: timestamp ?? this.timestamp,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      timeSecs: timeSecs ?? this.timeSecs,
      rpe: rpe ?? this.rpe,
      grade: grade ?? this.grade,
      wallAngle: wallAngle ?? this.wallAngle,
      climbName: climbName ?? this.climbName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (timeSecs.present) {
      map['time_secs'] = Variable<int>(timeSecs.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (wallAngle.present) {
      map['wall_angle'] = Variable<int>(wallAngle.value);
    }
    if (climbName.present) {
      map['climb_name'] = Variable<String>(climbName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('dateStr: $dateStr, ')
          ..write('timestamp: $timestamp, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('timeSecs: $timeSecs, ')
          ..write('rpe: $rpe, ')
          ..write('grade: $grade, ')
          ..write('wallAngle: $wallAngle, ')
          ..write('climbName: $climbName')
          ..write(')'))
        .toString();
  }
}

class $DayNotesTable extends DayNotes with TableInfo<$DayNotesTable, DayNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DayNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dateStr, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'day_notes';
  @override
  VerificationContext validateIntegrity(Insertable<DayNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateStr};
  @override
  DayNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayNote(
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
    );
  }

  @override
  $DayNotesTable createAlias(String alias) {
    return $DayNotesTable(attachedDatabase, alias);
  }
}

class DayNote extends DataClass implements Insertable<DayNote> {
  final String dateStr;
  final String note;
  const DayNote({required this.dateStr, required this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_str'] = Variable<String>(dateStr);
    map['note'] = Variable<String>(note);
    return map;
  }

  DayNotesCompanion toCompanion(bool nullToAbsent) {
    return DayNotesCompanion(
      dateStr: Value(dateStr),
      note: Value(note),
    );
  }

  factory DayNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayNote(
      dateStr: serializer.fromJson<String>(json['dateStr']),
      note: serializer.fromJson<String>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateStr': serializer.toJson<String>(dateStr),
      'note': serializer.toJson<String>(note),
    };
  }

  DayNote copyWith({String? dateStr, String? note}) => DayNote(
        dateStr: dateStr ?? this.dateStr,
        note: note ?? this.note,
      );
  DayNote copyWithCompanion(DayNotesCompanion data) {
    return DayNote(
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayNote(')
          ..write('dateStr: $dateStr, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateStr, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayNote &&
          other.dateStr == this.dateStr &&
          other.note == this.note);
}

class DayNotesCompanion extends UpdateCompanion<DayNote> {
  final Value<String> dateStr;
  final Value<String> note;
  final Value<int> rowid;
  const DayNotesCompanion({
    this.dateStr = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DayNotesCompanion.insert({
    required String dateStr,
    required String note,
    this.rowid = const Value.absent(),
  })  : dateStr = Value(dateStr),
        note = Value(note);
  static Insertable<DayNote> custom({
    Expression<String>? dateStr,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateStr != null) 'date_str': dateStr,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DayNotesCompanion copyWith(
      {Value<String>? dateStr, Value<String>? note, Value<int>? rowid}) {
    return DayNotesCompanion(
      dateStr: dateStr ?? this.dateStr,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DayNotesCompanion(')
          ..write('dateStr: $dateStr, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BodyWeightsTable extends BodyWeights
    with TableInfo<$BodyWeightsTable, BodyWeight> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BodyWeightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateStrMeta =
      const VerificationMeta('dateStr');
  @override
  late final GeneratedColumn<String> dateStr = GeneratedColumn<String>(
      'date_str', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kgMeta = const VerificationMeta('kg');
  @override
  late final GeneratedColumn<double> kg = GeneratedColumn<double>(
      'kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dateStr, kg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'body_weights';
  @override
  VerificationContext validateIntegrity(Insertable<BodyWeight> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_str')) {
      context.handle(_dateStrMeta,
          dateStr.isAcceptableOrUnknown(data['date_str']!, _dateStrMeta));
    } else if (isInserting) {
      context.missing(_dateStrMeta);
    }
    if (data.containsKey('kg')) {
      context.handle(_kgMeta, kg.isAcceptableOrUnknown(data['kg']!, _kgMeta));
    } else if (isInserting) {
      context.missing(_kgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateStr};
  @override
  BodyWeight map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BodyWeight(
      dateStr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_str'])!,
      kg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}kg'])!,
    );
  }

  @override
  $BodyWeightsTable createAlias(String alias) {
    return $BodyWeightsTable(attachedDatabase, alias);
  }
}

class BodyWeight extends DataClass implements Insertable<BodyWeight> {
  final String dateStr;
  final double kg;
  const BodyWeight({required this.dateStr, required this.kg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_str'] = Variable<String>(dateStr);
    map['kg'] = Variable<double>(kg);
    return map;
  }

  BodyWeightsCompanion toCompanion(bool nullToAbsent) {
    return BodyWeightsCompanion(
      dateStr: Value(dateStr),
      kg: Value(kg),
    );
  }

  factory BodyWeight.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BodyWeight(
      dateStr: serializer.fromJson<String>(json['dateStr']),
      kg: serializer.fromJson<double>(json['kg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateStr': serializer.toJson<String>(dateStr),
      'kg': serializer.toJson<double>(kg),
    };
  }

  BodyWeight copyWith({String? dateStr, double? kg}) => BodyWeight(
        dateStr: dateStr ?? this.dateStr,
        kg: kg ?? this.kg,
      );
  BodyWeight copyWithCompanion(BodyWeightsCompanion data) {
    return BodyWeight(
      dateStr: data.dateStr.present ? data.dateStr.value : this.dateStr,
      kg: data.kg.present ? data.kg.value : this.kg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeight(')
          ..write('dateStr: $dateStr, ')
          ..write('kg: $kg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateStr, kg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BodyWeight &&
          other.dateStr == this.dateStr &&
          other.kg == this.kg);
}

class BodyWeightsCompanion extends UpdateCompanion<BodyWeight> {
  final Value<String> dateStr;
  final Value<double> kg;
  final Value<int> rowid;
  const BodyWeightsCompanion({
    this.dateStr = const Value.absent(),
    this.kg = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BodyWeightsCompanion.insert({
    required String dateStr,
    required double kg,
    this.rowid = const Value.absent(),
  })  : dateStr = Value(dateStr),
        kg = Value(kg);
  static Insertable<BodyWeight> custom({
    Expression<String>? dateStr,
    Expression<double>? kg,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateStr != null) 'date_str': dateStr,
      if (kg != null) 'kg': kg,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BodyWeightsCompanion copyWith(
      {Value<String>? dateStr, Value<double>? kg, Value<int>? rowid}) {
    return BodyWeightsCompanion(
      dateStr: dateStr ?? this.dateStr,
      kg: kg ?? this.kg,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateStr.present) {
      map['date_str'] = Variable<String>(dateStr.value);
    }
    if (kg.present) {
      map['kg'] = Variable<double>(kg.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BodyWeightsCompanion(')
          ..write('dateStr: $dateStr, ')
          ..write('kg: $kg, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InspirationsTable extends Inspirations
    with TableInfo<$InspirationsTable, Inspiration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InspirationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
      'category_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES exercise_categories (id)'));
  static const VerificationMeta _addedAtMeta =
      const VerificationMeta('addedAt');
  @override
  late final GeneratedColumn<int> addedAt = GeneratedColumn<int>(
      'added_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, url, notes, categoryId, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inspirations';
  @override
  VerificationContext validateIntegrity(Insertable<Inspiration> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('added_at')) {
      context.handle(_addedAtMeta,
          addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta));
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Inspiration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Inspiration(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}category_id']),
      addedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}added_at'])!,
    );
  }

  @override
  $InspirationsTable createAlias(String alias) {
    return $InspirationsTable(attachedDatabase, alias);
  }
}

class Inspiration extends DataClass implements Insertable<Inspiration> {
  final int id;
  final String title;
  final String url;
  final String? notes;
  final int? categoryId;
  final int addedAt;
  const Inspiration(
      {required this.id,
      required this.title,
      required this.url,
      this.notes,
      this.categoryId,
      required this.addedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['added_at'] = Variable<int>(addedAt);
    return map;
  }

  InspirationsCompanion toCompanion(bool nullToAbsent) {
    return InspirationsCompanion(
      id: Value(id),
      title: Value(title),
      url: Value(url),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      addedAt: Value(addedAt),
    );
  }

  factory Inspiration.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Inspiration(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      notes: serializer.fromJson<String?>(json['notes']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      addedAt: serializer.fromJson<int>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'notes': serializer.toJson<String?>(notes),
      'categoryId': serializer.toJson<int?>(categoryId),
      'addedAt': serializer.toJson<int>(addedAt),
    };
  }

  Inspiration copyWith(
          {int? id,
          String? title,
          String? url,
          Value<String?> notes = const Value.absent(),
          Value<int?> categoryId = const Value.absent(),
          int? addedAt}) =>
      Inspiration(
        id: id ?? this.id,
        title: title ?? this.title,
        url: url ?? this.url,
        notes: notes.present ? notes.value : this.notes,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        addedAt: addedAt ?? this.addedAt,
      );
  Inspiration copyWithCompanion(InspirationsCompanion data) {
    return Inspiration(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      notes: data.notes.present ? data.notes.value : this.notes,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Inspiration(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, url, notes, categoryId, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Inspiration &&
          other.id == this.id &&
          other.title == this.title &&
          other.url == this.url &&
          other.notes == this.notes &&
          other.categoryId == this.categoryId &&
          other.addedAt == this.addedAt);
}

class InspirationsCompanion extends UpdateCompanion<Inspiration> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> url;
  final Value<String?> notes;
  final Value<int?> categoryId;
  final Value<int> addedAt;
  const InspirationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.notes = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  InspirationsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String url,
    this.notes = const Value.absent(),
    this.categoryId = const Value.absent(),
    required int addedAt,
  })  : title = Value(title),
        url = Value(url),
        addedAt = Value(addedAt);
  static Insertable<Inspiration> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? notes,
    Expression<int>? categoryId,
    Expression<int>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (notes != null) 'notes': notes,
      if (categoryId != null) 'category_id': categoryId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  InspirationsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? url,
      Value<String?>? notes,
      Value<int?>? categoryId,
      Value<int>? addedAt}) {
    return InspirationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InspirationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('notes: $notes, ')
          ..write('categoryId: $categoryId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WorkoutsTable workouts = $WorkoutsTable(this);
  late final $ExerciseCategoriesTable exerciseCategories =
      $ExerciseCategoriesTable(this);
  late final $WorkoutExercisesTable workoutExercises =
      $WorkoutExercisesTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PlanWorkoutsTable planWorkouts = $PlanWorkoutsTable(this);
  late final $PlanPhasesTable planPhases = $PlanPhasesTable(this);
  late final $PhaseSessionsTable phaseSessions = $PhaseSessionsTable(this);
  late final $PhaseExerciseTargetsTable phaseExerciseTargets =
      $PhaseExerciseTargetsTable(this);
  late final $PlanEventsTable planEvents = $PlanEventsTable(this);
  late final $ExerciseImagesTable exerciseImages = $ExerciseImagesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $DayNotesTable dayNotes = $DayNotesTable(this);
  late final $BodyWeightsTable bodyWeights = $BodyWeightsTable(this);
  late final $InspirationsTable inspirations = $InspirationsTable(this);
  late final Index idxWeWorkout = Index('idx_we_workout',
      'CREATE INDEX idx_we_workout ON workout_exercises (workout_id, sort_order)');
  late final Index idxWeCategory = Index('idx_we_category',
      'CREATE INDEX idx_we_category ON workout_exercises (category_id)');
  late final Index idxPwPlan = Index(
      'idx_pw_plan', 'CREATE INDEX idx_pw_plan ON plan_workouts (plan_id)');
  late final Index idxPwWorkout = Index('idx_pw_workout',
      'CREATE INDEX idx_pw_workout ON plan_workouts (workout_id)');
  late final Index idxPhasePlan = Index('idx_phase_plan',
      'CREATE INDEX idx_phase_plan ON plan_phases (plan_id, sort_order)');
  late final Index idxPsPhase = Index('idx_ps_phase',
      'CREATE INDEX idx_ps_phase ON phase_sessions (phase_id, sort_order)');
  late final Index idxPsWorkout = Index('idx_ps_workout',
      'CREATE INDEX idx_ps_workout ON phase_sessions (workout_id)');
  late final Index idxPetPhase = Index('idx_pet_phase',
      'CREATE INDEX idx_pet_phase ON phase_exercise_targets (phase_id)');
  late final Index idxPetCategory = Index('idx_pet_category',
      'CREATE INDEX idx_pet_category ON phase_exercise_targets (category_id)');
  late final Index idxPePlan = Index('idx_pe_plan',
      'CREATE INDEX idx_pe_plan ON plan_events (plan_id, timestamp)');
  late final Index idxPePhase = Index(
      'idx_pe_phase', 'CREATE INDEX idx_pe_phase ON plan_events (phase_id)');
  late final Index idxPeWorkout = Index('idx_pe_workout',
      'CREATE INDEX idx_pe_workout ON plan_events (workout_id)');
  late final Index idxSetsDate = Index('idx_sets_date',
      'CREATE INDEX idx_sets_date ON workout_sets (date_str, timestamp)');
  late final Index idxSetsCategory = Index('idx_sets_category',
      'CREATE INDEX idx_sets_category ON workout_sets (category_id, date_str)');
  late final Index idxInspirationsCategory = Index('idx_inspirations_category',
      'CREATE INDEX idx_inspirations_category ON inspirations (category_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        workouts,
        exerciseCategories,
        workoutExercises,
        plans,
        planWorkouts,
        planPhases,
        phaseSessions,
        phaseExerciseTargets,
        planEvents,
        exerciseImages,
        workoutSets,
        dayNotes,
        bodyWeights,
        inspirations,
        idxWeWorkout,
        idxWeCategory,
        idxPwPlan,
        idxPwWorkout,
        idxPhasePlan,
        idxPsPhase,
        idxPsWorkout,
        idxPetPhase,
        idxPetCategory,
        idxPePlan,
        idxPePhase,
        idxPeWorkout,
        idxSetsDate,
        idxSetsCategory,
        idxInspirationsCategory
      ];
}

typedef $$WorkoutsTableCreateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> notes,
});
typedef $$WorkoutsTableUpdateCompanionBuilder = WorkoutsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> notes,
});

final class $$WorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutsTable, Workout> {
  $$WorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
      _workoutExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutExercises,
              aliasName: 'workouts__id__workout_exercises__workout_id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager =
        $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises)
            .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanWorkoutsTable, List<PlanWorkout>>
      _planWorkoutsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planWorkouts,
              aliasName: 'workouts__id__plan_workouts__workout_id');

  $$PlanWorkoutsTableProcessedTableManager get planWorkoutsRefs {
    final manager = $$PlanWorkoutsTableTableManager($_db, $_db.planWorkouts)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planWorkoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhaseSessionsTable, List<PhaseSession>>
      _phaseSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.phaseSessions,
              aliasName: 'workouts__id__phase_sessions__workout_id');

  $$PhaseSessionsTableProcessedTableManager get phaseSessionsRefs {
    final manager = $$PhaseSessionsTableTableManager($_db, $_db.phaseSessions)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_phaseSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanEventsTable, List<PlanEvent>>
      _planEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planEvents,
              aliasName: 'workouts__id__plan_events__workout_id');

  $$PlanEventsTableProcessedTableManager get planEventsRefs {
    final manager = $$PlanEventsTableTableManager($_db, $_db.planEvents)
        .filter((f) => f.workoutId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$WorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutExercisesRefs(
      Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableFilterComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planWorkoutsRefs(
      Expression<bool> Function($$PlanWorkoutsTableFilterComposer f) f) {
    final $$PlanWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> phaseSessionsRefs(
      Expression<bool> Function($$PhaseSessionsTableFilterComposer f) f) {
    final $$PhaseSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseSessions,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseSessionsTableFilterComposer(
              $db: $db,
              $table: $db.phaseSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planEventsRefs(
      Expression<bool> Function($$PlanEventsTableFilterComposer f) f) {
    final $$PlanEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableFilterComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$WorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutsTable> {
  $$WorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
      Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> planWorkoutsRefs<T extends Object>(
      Expression<T> Function($$PlanWorkoutsTableAnnotationComposer a) f) {
    final $$PlanWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> phaseSessionsRefs<T extends Object>(
      Expression<T> Function($$PhaseSessionsTableAnnotationComposer a) f) {
    final $$PhaseSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseSessions,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.phaseSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> planEventsRefs<T extends Object>(
      Expression<T> Function($$PlanEventsTableAnnotationComposer a) f) {
    final $$PlanEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.workoutId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$WorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool planWorkoutsRefs,
        bool phaseSessionsRefs,
        bool planEventsRefs})> {
  $$WorkoutsTableTableManager(_$AppDatabase db, $WorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> notes = const Value.absent(),
          }) =>
              WorkoutsCompanion(
            id: id,
            name: name,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> notes = const Value.absent(),
          }) =>
              WorkoutsCompanion.insert(
            id: id,
            name: name,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$WorkoutsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {workoutExercisesRefs = false,
              planWorkoutsRefs = false,
              phaseSessionsRefs = false,
              planEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
                if (planWorkoutsRefs) db.planWorkouts,
                if (phaseSessionsRefs) db.phaseSessions,
                if (planEventsRefs) db.planEvents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            WorkoutExercise>(
                        currentTable: table,
                        referencedTable: $$WorkoutsTableReferences
                            ._workoutExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .workoutExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items),
                  if (planWorkoutsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            PlanWorkout>(
                        currentTable: table,
                        referencedTable: $$WorkoutsTableReferences
                            ._planWorkoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .planWorkoutsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items),
                  if (phaseSessionsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            PhaseSession>(
                        currentTable: table,
                        referencedTable: $$WorkoutsTableReferences
                            ._phaseSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .phaseSessionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items),
                  if (planEventsRefs)
                    await $_getPrefetchedData<Workout, $WorkoutsTable,
                            PlanEvent>(
                        currentTable: table,
                        referencedTable:
                            $$WorkoutsTableReferences._planEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$WorkoutsTableReferences(db, table, p0)
                                .planEventsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.workoutId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$WorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutsTable,
    Workout,
    $$WorkoutsTableFilterComposer,
    $$WorkoutsTableOrderingComposer,
    $$WorkoutsTableAnnotationComposer,
    $$WorkoutsTableCreateCompanionBuilder,
    $$WorkoutsTableUpdateCompanionBuilder,
    (Workout, $$WorkoutsTableReferences),
    Workout,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool planWorkoutsRefs,
        bool phaseSessionsRefs,
        bool planEventsRefs})>;
typedef $$ExerciseCategoriesTableCreateCompanionBuilder
    = ExerciseCategoriesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> groupName,
  Value<String?> description,
  Value<int> exerciseType,
});
typedef $$ExerciseCategoriesTableUpdateCompanionBuilder
    = ExerciseCategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> groupName,
  Value<String?> description,
  Value<int> exerciseType,
});

final class $$ExerciseCategoriesTableReferences extends BaseReferences<
    _$AppDatabase, $ExerciseCategoriesTable, ExerciseCategory> {
  $$ExerciseCategoriesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$WorkoutExercisesTable, List<WorkoutExercise>>
      _workoutExercisesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutExercises,
              aliasName:
                  'exercise_categories__id__workout_exercises__category_id');

  $$WorkoutExercisesTableProcessedTableManager get workoutExercisesRefs {
    final manager =
        $$WorkoutExercisesTableTableManager($_db, $_db.workoutExercises)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_workoutExercisesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhaseExerciseTargetsTable,
      List<PhaseExerciseTarget>> _phaseExerciseTargetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.phaseExerciseTargets,
          aliasName:
              'exercise_categories__id__phase_exercise_targets__category_id');

  $$PhaseExerciseTargetsTableProcessedTableManager
      get phaseExerciseTargetsRefs {
    final manager =
        $$PhaseExerciseTargetsTableTableManager($_db, $_db.phaseExerciseTargets)
            .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_phaseExerciseTargetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ExerciseImagesTable, List<ExerciseImage>>
      _exerciseImagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.exerciseImages,
              aliasName:
                  'exercise_categories__id__exercise_images__category_id');

  $$ExerciseImagesTableProcessedTableManager get exerciseImagesRefs {
    final manager = $$ExerciseImagesTableTableManager($_db, $_db.exerciseImages)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseImagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
      _workoutSetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.workoutSets,
              aliasName: 'exercise_categories__id__workout_sets__category_id');

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$InspirationsTable, List<Inspiration>>
      _inspirationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.inspirations,
              aliasName: 'exercise_categories__id__inspirations__category_id');

  $$InspirationsTableProcessedTableManager get inspirationsRefs {
    final manager = $$InspirationsTableTableManager($_db, $_db.inspirations)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_inspirationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExerciseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => ColumnFilters(column));

  Expression<bool> workoutExercisesRefs(
      Expression<bool> Function($$WorkoutExercisesTableFilterComposer f) f) {
    final $$WorkoutExercisesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableFilterComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> phaseExerciseTargetsRefs(
      Expression<bool> Function($$PhaseExerciseTargetsTableFilterComposer f)
          f) {
    final $$PhaseExerciseTargetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseExerciseTargets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseExerciseTargetsTableFilterComposer(
              $db: $db,
              $table: $db.phaseExerciseTargets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> exerciseImagesRefs(
      Expression<bool> Function($$ExerciseImagesTableFilterComposer f) f) {
    final $$ExerciseImagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exerciseImages,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseImagesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
      Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableFilterComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> inspirationsRefs(
      Expression<bool> Function($$InspirationsTableFilterComposer f) f) {
    final $$InspirationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inspirations,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InspirationsTableFilterComposer(
              $db: $db,
              $table: $db.inspirations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExerciseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupName => $composableBuilder(
      column: $table.groupName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType,
      builder: (column) => ColumnOrderings(column));
}

class $$ExerciseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseCategoriesTable> {
  $$ExerciseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get groupName =>
      $composableBuilder(column: $table.groupName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get exerciseType => $composableBuilder(
      column: $table.exerciseType, builder: (column) => column);

  Expression<T> workoutExercisesRefs<T extends Object>(
      Expression<T> Function($$WorkoutExercisesTableAnnotationComposer a) f) {
    final $$WorkoutExercisesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutExercises,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutExercisesTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutExercises,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> phaseExerciseTargetsRefs<T extends Object>(
      Expression<T> Function($$PhaseExerciseTargetsTableAnnotationComposer a)
          f) {
    final $$PhaseExerciseTargetsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.phaseExerciseTargets,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PhaseExerciseTargetsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.phaseExerciseTargets,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> exerciseImagesRefs<T extends Object>(
      Expression<T> Function($$ExerciseImagesTableAnnotationComposer a) f) {
    final $$ExerciseImagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.exerciseImages,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseImagesTableAnnotationComposer(
              $db: $db,
              $table: $db.exerciseImages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
      Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.workoutSets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutSetsTableAnnotationComposer(
              $db: $db,
              $table: $db.workoutSets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> inspirationsRefs<T extends Object>(
      Expression<T> Function($$InspirationsTableAnnotationComposer a) f) {
    final $$InspirationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.inspirations,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$InspirationsTableAnnotationComposer(
              $db: $db,
              $table: $db.inspirations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExerciseCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseCategoriesTable,
    ExerciseCategory,
    $$ExerciseCategoriesTableFilterComposer,
    $$ExerciseCategoriesTableOrderingComposer,
    $$ExerciseCategoriesTableAnnotationComposer,
    $$ExerciseCategoriesTableCreateCompanionBuilder,
    $$ExerciseCategoriesTableUpdateCompanionBuilder,
    (ExerciseCategory, $$ExerciseCategoriesTableReferences),
    ExerciseCategory,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool phaseExerciseTargetsRefs,
        bool exerciseImagesRefs,
        bool workoutSetsRefs,
        bool inspirationsRefs})> {
  $$ExerciseCategoriesTableTableManager(
      _$AppDatabase db, $ExerciseCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> groupName = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> exerciseType = const Value.absent(),
          }) =>
              ExerciseCategoriesCompanion(
            id: id,
            name: name,
            groupName: groupName,
            description: description,
            exerciseType: exerciseType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> groupName = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> exerciseType = const Value.absent(),
          }) =>
              ExerciseCategoriesCompanion.insert(
            id: id,
            name: name,
            groupName: groupName,
            description: description,
            exerciseType: exerciseType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExerciseCategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {workoutExercisesRefs = false,
              phaseExerciseTargetsRefs = false,
              exerciseImagesRefs = false,
              workoutSetsRefs = false,
              inspirationsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (workoutExercisesRefs) db.workoutExercises,
                if (phaseExerciseTargetsRefs) db.phaseExerciseTargets,
                if (exerciseImagesRefs) db.exerciseImages,
                if (workoutSetsRefs) db.workoutSets,
                if (inspirationsRefs) db.inspirations
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (workoutExercisesRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, WorkoutExercise>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._workoutExercisesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .workoutExercisesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (phaseExerciseTargetsRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, PhaseExerciseTarget>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._phaseExerciseTargetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .phaseExerciseTargetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (exerciseImagesRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, ExerciseImage>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._exerciseImagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .exerciseImagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (workoutSetsRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, WorkoutSet>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._workoutSetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .workoutSetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (inspirationsRefs)
                    await $_getPrefetchedData<ExerciseCategory,
                            $ExerciseCategoriesTable, Inspiration>(
                        currentTable: table,
                        referencedTable: $$ExerciseCategoriesTableReferences
                            ._inspirationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExerciseCategoriesTableReferences(db, table, p0)
                                .inspirationsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExerciseCategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExerciseCategoriesTable,
    ExerciseCategory,
    $$ExerciseCategoriesTableFilterComposer,
    $$ExerciseCategoriesTableOrderingComposer,
    $$ExerciseCategoriesTableAnnotationComposer,
    $$ExerciseCategoriesTableCreateCompanionBuilder,
    $$ExerciseCategoriesTableUpdateCompanionBuilder,
    (ExerciseCategory, $$ExerciseCategoriesTableReferences),
    ExerciseCategory,
    PrefetchHooks Function(
        {bool workoutExercisesRefs,
        bool phaseExerciseTargetsRefs,
        bool exerciseImagesRefs,
        bool workoutSetsRefs,
        bool inspirationsRefs})>;
typedef $$WorkoutExercisesTableCreateCompanionBuilder
    = WorkoutExercisesCompanion Function({
  Value<int> id,
  required int workoutId,
  required int categoryId,
  Value<int?> targetSets,
  Value<int?> targetReps,
  Value<int?> targetRpe,
  Value<int> sortOrder,
});
typedef $$WorkoutExercisesTableUpdateCompanionBuilder
    = WorkoutExercisesCompanion Function({
  Value<int> id,
  Value<int> workoutId,
  Value<int> categoryId,
  Value<int?> targetSets,
  Value<int?> targetReps,
  Value<int?> targetRpe,
  Value<int> sortOrder,
});

final class $$WorkoutExercisesTableReferences extends BaseReferences<
    _$AppDatabase, $WorkoutExercisesTable, WorkoutExercise> {
  $$WorkoutExercisesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('workout_exercises__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .exerciseCategories
      .createAlias('workout_exercises__category_id__exercise_categories__id');

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRpe => $composableBuilder(
      column: $table.targetRpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRpe => $composableBuilder(
      column: $table.targetRpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutExercisesTable> {
  $$WorkoutExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => column);

  GeneratedColumn<int> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WorkoutExercisesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutExercisesTable,
    WorkoutExercise,
    $$WorkoutExercisesTableFilterComposer,
    $$WorkoutExercisesTableOrderingComposer,
    $$WorkoutExercisesTableAnnotationComposer,
    $$WorkoutExercisesTableCreateCompanionBuilder,
    $$WorkoutExercisesTableUpdateCompanionBuilder,
    (WorkoutExercise, $$WorkoutExercisesTableReferences),
    WorkoutExercise,
    PrefetchHooks Function({bool workoutId, bool categoryId})> {
  $$WorkoutExercisesTableTableManager(
      _$AppDatabase db, $WorkoutExercisesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
            Value<int?> targetRpe = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              WorkoutExercisesCompanion(
            id: id,
            workoutId: workoutId,
            categoryId: categoryId,
            targetSets: targetSets,
            targetReps: targetReps,
            targetRpe: targetRpe,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int workoutId,
            required int categoryId,
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
            Value<int?> targetRpe = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              WorkoutExercisesCompanion.insert(
            id: id,
            workoutId: workoutId,
            categoryId: categoryId,
            targetSets: targetSets,
            targetReps: targetReps,
            targetRpe: targetRpe,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutExercisesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({workoutId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$WorkoutExercisesTableReferences._workoutIdTable(db),
                    referencedColumn: $$WorkoutExercisesTableReferences
                        ._workoutIdTable(db)
                        .id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WorkoutExercisesTableReferences._categoryIdTable(db),
                    referencedColumn: $$WorkoutExercisesTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutExercisesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutExercisesTable,
    WorkoutExercise,
    $$WorkoutExercisesTableFilterComposer,
    $$WorkoutExercisesTableOrderingComposer,
    $$WorkoutExercisesTableAnnotationComposer,
    $$WorkoutExercisesTableCreateCompanionBuilder,
    $$WorkoutExercisesTableUpdateCompanionBuilder,
    (WorkoutExercise, $$WorkoutExercisesTableReferences),
    WorkoutExercise,
    PrefetchHooks Function({bool workoutId, bool categoryId})>;
typedef $$PlansTableCreateCompanionBuilder = PlansCompanion Function({
  Value<int> id,
  required String name,
  Value<bool> active,
  Value<int> cycleDays,
});
typedef $$PlansTableUpdateCompanionBuilder = PlansCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<bool> active,
  Value<int> cycleDays,
});

final class $$PlansTableReferences
    extends BaseReferences<_$AppDatabase, $PlansTable, Plan> {
  $$PlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlanWorkoutsTable, List<PlanWorkout>>
      _planWorkoutsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planWorkouts,
              aliasName: 'plans__id__plan_workouts__plan_id');

  $$PlanWorkoutsTableProcessedTableManager get planWorkoutsRefs {
    final manager = $$PlanWorkoutsTableTableManager($_db, $_db.planWorkouts)
        .filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planWorkoutsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanPhasesTable, List<PlanPhase>>
      _planPhasesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planPhases,
              aliasName: 'plans__id__plan_phases__plan_id');

  $$PlanPhasesTableProcessedTableManager get planPhasesRefs {
    final manager = $$PlanPhasesTableTableManager($_db, $_db.planPhases)
        .filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planPhasesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanEventsTable, List<PlanEvent>>
      _planEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planEvents,
              aliasName: 'plans__id__plan_events__plan_id');

  $$PlanEventsTableProcessedTableManager get planEventsRefs {
    final manager = $$PlanEventsTableTableManager($_db, $_db.planEvents)
        .filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cycleDays => $composableBuilder(
      column: $table.cycleDays, builder: (column) => ColumnFilters(column));

  Expression<bool> planWorkoutsRefs(
      Expression<bool> Function($$PlanWorkoutsTableFilterComposer f) f) {
    final $$PlanWorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planPhasesRefs(
      Expression<bool> Function($$PlanPhasesTableFilterComposer f) f) {
    final $$PlanPhasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableFilterComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planEventsRefs(
      Expression<bool> Function($$PlanEventsTableFilterComposer f) f) {
    final $$PlanEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableFilterComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cycleDays => $composableBuilder(
      column: $table.cycleDays, builder: (column) => ColumnOrderings(column));
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get cycleDays =>
      $composableBuilder(column: $table.cycleDays, builder: (column) => column);

  Expression<T> planWorkoutsRefs<T extends Object>(
      Expression<T> Function($$PlanWorkoutsTableAnnotationComposer a) f) {
    final $$PlanWorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planWorkouts,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanWorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.planWorkouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> planPhasesRefs<T extends Object>(
      Expression<T> Function($$PlanPhasesTableAnnotationComposer a) f) {
    final $$PlanPhasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableAnnotationComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> planEventsRefs<T extends Object>(
      Expression<T> Function($$PlanEventsTableAnnotationComposer a) f) {
    final $$PlanEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.planId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlansTable,
    Plan,
    $$PlansTableFilterComposer,
    $$PlansTableOrderingComposer,
    $$PlansTableAnnotationComposer,
    $$PlansTableCreateCompanionBuilder,
    $$PlansTableUpdateCompanionBuilder,
    (Plan, $$PlansTableReferences),
    Plan,
    PrefetchHooks Function(
        {bool planWorkoutsRefs, bool planPhasesRefs, bool planEventsRefs})> {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<int> cycleDays = const Value.absent(),
          }) =>
              PlansCompanion(
            id: id,
            name: name,
            active: active,
            cycleDays: cycleDays,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<bool> active = const Value.absent(),
            Value<int> cycleDays = const Value.absent(),
          }) =>
              PlansCompanion.insert(
            id: id,
            name: name,
            active: active,
            cycleDays: cycleDays,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PlansTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {planWorkoutsRefs = false,
              planPhasesRefs = false,
              planEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (planWorkoutsRefs) db.planWorkouts,
                if (planPhasesRefs) db.planPhases,
                if (planEventsRefs) db.planEvents
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planWorkoutsRefs)
                    await $_getPrefetchedData<Plan, $PlansTable, PlanWorkout>(
                        currentTable: table,
                        referencedTable:
                            $$PlansTableReferences._planWorkoutsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlansTableReferences(db, table, p0)
                                .planWorkoutsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items),
                  if (planPhasesRefs)
                    await $_getPrefetchedData<Plan, $PlansTable, PlanPhase>(
                        currentTable: table,
                        referencedTable:
                            $$PlansTableReferences._planPhasesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlansTableReferences(db, table, p0)
                                .planPhasesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items),
                  if (planEventsRefs)
                    await $_getPrefetchedData<Plan, $PlansTable, PlanEvent>(
                        currentTable: table,
                        referencedTable:
                            $$PlansTableReferences._planEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlansTableReferences(db, table, p0)
                                .planEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.planId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlansTable,
    Plan,
    $$PlansTableFilterComposer,
    $$PlansTableOrderingComposer,
    $$PlansTableAnnotationComposer,
    $$PlansTableCreateCompanionBuilder,
    $$PlansTableUpdateCompanionBuilder,
    (Plan, $$PlansTableReferences),
    Plan,
    PrefetchHooks Function(
        {bool planWorkoutsRefs, bool planPhasesRefs, bool planEventsRefs})>;
typedef $$PlanWorkoutsTableCreateCompanionBuilder = PlanWorkoutsCompanion
    Function({
  Value<int> id,
  required int planId,
  required int workoutId,
  Value<String?> dateStr,
  Value<int?> weekday,
});
typedef $$PlanWorkoutsTableUpdateCompanionBuilder = PlanWorkoutsCompanion
    Function({
  Value<int> id,
  Value<int> planId,
  Value<int> workoutId,
  Value<String?> dateStr,
  Value<int?> weekday,
});

final class $$PlanWorkoutsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanWorkoutsTable, PlanWorkout> {
  $$PlanWorkoutsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('plan_workouts__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager($_db, $_db.plans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('plan_workouts__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlanWorkoutsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableFilterComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableOrderingComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanWorkoutsTable> {
  $$PlanWorkoutsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableAnnotationComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanWorkoutsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanWorkoutsTable,
    PlanWorkout,
    $$PlanWorkoutsTableFilterComposer,
    $$PlanWorkoutsTableOrderingComposer,
    $$PlanWorkoutsTableAnnotationComposer,
    $$PlanWorkoutsTableCreateCompanionBuilder,
    $$PlanWorkoutsTableUpdateCompanionBuilder,
    (PlanWorkout, $$PlanWorkoutsTableReferences),
    PlanWorkout,
    PrefetchHooks Function({bool planId, bool workoutId})> {
  $$PlanWorkoutsTableTableManager(_$AppDatabase db, $PlanWorkoutsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanWorkoutsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanWorkoutsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanWorkoutsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> planId = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<String?> dateStr = const Value.absent(),
            Value<int?> weekday = const Value.absent(),
          }) =>
              PlanWorkoutsCompanion(
            id: id,
            planId: planId,
            workoutId: workoutId,
            dateStr: dateStr,
            weekday: weekday,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int planId,
            required int workoutId,
            Value<String?> dateStr = const Value.absent(),
            Value<int?> weekday = const Value.absent(),
          }) =>
              PlanWorkoutsCompanion.insert(
            id: id,
            planId: planId,
            workoutId: workoutId,
            dateStr: dateStr,
            weekday: weekday,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlanWorkoutsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({planId = false, workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$PlanWorkoutsTableReferences._planIdTable(db),
                    referencedColumn:
                        $$PlanWorkoutsTableReferences._planIdTable(db).id,
                  ) as T;
                }
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$PlanWorkoutsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$PlanWorkoutsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlanWorkoutsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanWorkoutsTable,
    PlanWorkout,
    $$PlanWorkoutsTableFilterComposer,
    $$PlanWorkoutsTableOrderingComposer,
    $$PlanWorkoutsTableAnnotationComposer,
    $$PlanWorkoutsTableCreateCompanionBuilder,
    $$PlanWorkoutsTableUpdateCompanionBuilder,
    (PlanWorkout, $$PlanWorkoutsTableReferences),
    PlanWorkout,
    PrefetchHooks Function({bool planId, bool workoutId})>;
typedef $$PlanPhasesTableCreateCompanionBuilder = PlanPhasesCompanion Function({
  Value<int> id,
  required int planId,
  Value<int> sortOrder,
  required String name,
  required int lengthPasses,
  Value<int?> deloadEvery,
});
typedef $$PlanPhasesTableUpdateCompanionBuilder = PlanPhasesCompanion Function({
  Value<int> id,
  Value<int> planId,
  Value<int> sortOrder,
  Value<String> name,
  Value<int> lengthPasses,
  Value<int?> deloadEvery,
});

final class $$PlanPhasesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanPhasesTable, PlanPhase> {
  $$PlanPhasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('plan_phases__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager($_db, $_db.plans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$PhaseSessionsTable, List<PhaseSession>>
      _phaseSessionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.phaseSessions,
              aliasName: 'plan_phases__id__phase_sessions__phase_id');

  $$PhaseSessionsTableProcessedTableManager get phaseSessionsRefs {
    final manager = $$PhaseSessionsTableTableManager($_db, $_db.phaseSessions)
        .filter((f) => f.phaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_phaseSessionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhaseExerciseTargetsTable,
      List<PhaseExerciseTarget>> _phaseExerciseTargetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.phaseExerciseTargets,
          aliasName: 'plan_phases__id__phase_exercise_targets__phase_id');

  $$PhaseExerciseTargetsTableProcessedTableManager
      get phaseExerciseTargetsRefs {
    final manager =
        $$PhaseExerciseTargetsTableTableManager($_db, $_db.phaseExerciseTargets)
            .filter((f) => f.phaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_phaseExerciseTargetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PlanEventsTable, List<PlanEvent>>
      _planEventsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.planEvents,
              aliasName: 'plan_phases__id__plan_events__phase_id');

  $$PlanEventsTableProcessedTableManager get planEventsRefs {
    final manager = $$PlanEventsTableTableManager($_db, $_db.planEvents)
        .filter((f) => f.phaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planEventsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PlanPhasesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanPhasesTable> {
  $$PlanPhasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lengthPasses => $composableBuilder(
      column: $table.lengthPasses, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deloadEvery => $composableBuilder(
      column: $table.deloadEvery, builder: (column) => ColumnFilters(column));

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableFilterComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> phaseSessionsRefs(
      Expression<bool> Function($$PhaseSessionsTableFilterComposer f) f) {
    final $$PhaseSessionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseSessions,
        getReferencedColumn: (t) => t.phaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseSessionsTableFilterComposer(
              $db: $db,
              $table: $db.phaseSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> phaseExerciseTargetsRefs(
      Expression<bool> Function($$PhaseExerciseTargetsTableFilterComposer f)
          f) {
    final $$PhaseExerciseTargetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseExerciseTargets,
        getReferencedColumn: (t) => t.phaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseExerciseTargetsTableFilterComposer(
              $db: $db,
              $table: $db.phaseExerciseTargets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> planEventsRefs(
      Expression<bool> Function($$PlanEventsTableFilterComposer f) f) {
    final $$PlanEventsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.phaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableFilterComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlanPhasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanPhasesTable> {
  $$PlanPhasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lengthPasses => $composableBuilder(
      column: $table.lengthPasses,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deloadEvery => $composableBuilder(
      column: $table.deloadEvery, builder: (column) => ColumnOrderings(column));

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableOrderingComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanPhasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanPhasesTable> {
  $$PlanPhasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get lengthPasses => $composableBuilder(
      column: $table.lengthPasses, builder: (column) => column);

  GeneratedColumn<int> get deloadEvery => $composableBuilder(
      column: $table.deloadEvery, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableAnnotationComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> phaseSessionsRefs<T extends Object>(
      Expression<T> Function($$PhaseSessionsTableAnnotationComposer a) f) {
    final $$PhaseSessionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.phaseSessions,
        getReferencedColumn: (t) => t.phaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhaseSessionsTableAnnotationComposer(
              $db: $db,
              $table: $db.phaseSessions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> phaseExerciseTargetsRefs<T extends Object>(
      Expression<T> Function($$PhaseExerciseTargetsTableAnnotationComposer a)
          f) {
    final $$PhaseExerciseTargetsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.phaseExerciseTargets,
            getReferencedColumn: (t) => t.phaseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$PhaseExerciseTargetsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.phaseExerciseTargets,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> planEventsRefs<T extends Object>(
      Expression<T> Function($$PlanEventsTableAnnotationComposer a) f) {
    final $$PlanEventsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.planEvents,
        getReferencedColumn: (t) => t.phaseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanEventsTableAnnotationComposer(
              $db: $db,
              $table: $db.planEvents,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PlanPhasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanPhasesTable,
    PlanPhase,
    $$PlanPhasesTableFilterComposer,
    $$PlanPhasesTableOrderingComposer,
    $$PlanPhasesTableAnnotationComposer,
    $$PlanPhasesTableCreateCompanionBuilder,
    $$PlanPhasesTableUpdateCompanionBuilder,
    (PlanPhase, $$PlanPhasesTableReferences),
    PlanPhase,
    PrefetchHooks Function(
        {bool planId,
        bool phaseSessionsRefs,
        bool phaseExerciseTargetsRefs,
        bool planEventsRefs})> {
  $$PlanPhasesTableTableManager(_$AppDatabase db, $PlanPhasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanPhasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanPhasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanPhasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> planId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> lengthPasses = const Value.absent(),
            Value<int?> deloadEvery = const Value.absent(),
          }) =>
              PlanPhasesCompanion(
            id: id,
            planId: planId,
            sortOrder: sortOrder,
            name: name,
            lengthPasses: lengthPasses,
            deloadEvery: deloadEvery,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int planId,
            Value<int> sortOrder = const Value.absent(),
            required String name,
            required int lengthPasses,
            Value<int?> deloadEvery = const Value.absent(),
          }) =>
              PlanPhasesCompanion.insert(
            id: id,
            planId: planId,
            sortOrder: sortOrder,
            name: name,
            lengthPasses: lengthPasses,
            deloadEvery: deloadEvery,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlanPhasesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {planId = false,
              phaseSessionsRefs = false,
              phaseExerciseTargetsRefs = false,
              planEventsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (phaseSessionsRefs) db.phaseSessions,
                if (phaseExerciseTargetsRefs) db.phaseExerciseTargets,
                if (planEventsRefs) db.planEvents
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$PlanPhasesTableReferences._planIdTable(db),
                    referencedColumn:
                        $$PlanPhasesTableReferences._planIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (phaseSessionsRefs)
                    await $_getPrefetchedData<PlanPhase, $PlanPhasesTable,
                            PhaseSession>(
                        currentTable: table,
                        referencedTable: $$PlanPhasesTableReferences
                            ._phaseSessionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlanPhasesTableReferences(db, table, p0)
                                .phaseSessionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.phaseId == item.id),
                        typedResults: items),
                  if (phaseExerciseTargetsRefs)
                    await $_getPrefetchedData<PlanPhase, $PlanPhasesTable,
                            PhaseExerciseTarget>(
                        currentTable: table,
                        referencedTable: $$PlanPhasesTableReferences
                            ._phaseExerciseTargetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlanPhasesTableReferences(db, table, p0)
                                .phaseExerciseTargetsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.phaseId == item.id),
                        typedResults: items),
                  if (planEventsRefs)
                    await $_getPrefetchedData<PlanPhase, $PlanPhasesTable,
                            PlanEvent>(
                        currentTable: table,
                        referencedTable: $$PlanPhasesTableReferences
                            ._planEventsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PlanPhasesTableReferences(db, table, p0)
                                .planEventsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.phaseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PlanPhasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanPhasesTable,
    PlanPhase,
    $$PlanPhasesTableFilterComposer,
    $$PlanPhasesTableOrderingComposer,
    $$PlanPhasesTableAnnotationComposer,
    $$PlanPhasesTableCreateCompanionBuilder,
    $$PlanPhasesTableUpdateCompanionBuilder,
    (PlanPhase, $$PlanPhasesTableReferences),
    PlanPhase,
    PrefetchHooks Function(
        {bool planId,
        bool phaseSessionsRefs,
        bool phaseExerciseTargetsRefs,
        bool planEventsRefs})>;
typedef $$PhaseSessionsTableCreateCompanionBuilder = PhaseSessionsCompanion
    Function({
  Value<int> id,
  required int phaseId,
  required int workoutId,
  Value<int> sortOrder,
  Value<int> day,
});
typedef $$PhaseSessionsTableUpdateCompanionBuilder = PhaseSessionsCompanion
    Function({
  Value<int> id,
  Value<int> phaseId,
  Value<int> workoutId,
  Value<int> sortOrder,
  Value<int> day,
});

final class $$PhaseSessionsTableReferences
    extends BaseReferences<_$AppDatabase, $PhaseSessionsTable, PhaseSession> {
  $$PhaseSessionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlanPhasesTable _phaseIdTable(_$AppDatabase db) =>
      db.planPhases.createAlias('phase_sessions__phase_id__plan_phases__id');

  $$PlanPhasesTableProcessedTableManager get phaseId {
    final $_column = $_itemColumn<int>('phase_id')!;

    final manager = $$PlanPhasesTableTableManager($_db, $_db.planPhases)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('phase_sessions__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager get workoutId {
    final $_column = $_itemColumn<int>('workout_id')!;

    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhaseSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PhaseSessionsTable> {
  $$PhaseSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  $$PlanPhasesTableFilterComposer get phaseId {
    final $$PlanPhasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableFilterComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhaseSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhaseSessionsTable> {
  $$PhaseSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  $$PlanPhasesTableOrderingComposer get phaseId {
    final $$PlanPhasesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableOrderingComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhaseSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhaseSessionsTable> {
  $$PhaseSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  $$PlanPhasesTableAnnotationComposer get phaseId {
    final $$PlanPhasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableAnnotationComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhaseSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhaseSessionsTable,
    PhaseSession,
    $$PhaseSessionsTableFilterComposer,
    $$PhaseSessionsTableOrderingComposer,
    $$PhaseSessionsTableAnnotationComposer,
    $$PhaseSessionsTableCreateCompanionBuilder,
    $$PhaseSessionsTableUpdateCompanionBuilder,
    (PhaseSession, $$PhaseSessionsTableReferences),
    PhaseSession,
    PrefetchHooks Function({bool phaseId, bool workoutId})> {
  $$PhaseSessionsTableTableManager(_$AppDatabase db, $PhaseSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhaseSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhaseSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhaseSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> phaseId = const Value.absent(),
            Value<int> workoutId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<int> day = const Value.absent(),
          }) =>
              PhaseSessionsCompanion(
            id: id,
            phaseId: phaseId,
            workoutId: workoutId,
            sortOrder: sortOrder,
            day: day,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int phaseId,
            required int workoutId,
            Value<int> sortOrder = const Value.absent(),
            Value<int> day = const Value.absent(),
          }) =>
              PhaseSessionsCompanion.insert(
            id: id,
            phaseId: phaseId,
            workoutId: workoutId,
            sortOrder: sortOrder,
            day: day,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PhaseSessionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({phaseId = false, workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (phaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.phaseId,
                    referencedTable:
                        $$PhaseSessionsTableReferences._phaseIdTable(db),
                    referencedColumn:
                        $$PhaseSessionsTableReferences._phaseIdTable(db).id,
                  ) as T;
                }
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$PhaseSessionsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$PhaseSessionsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhaseSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhaseSessionsTable,
    PhaseSession,
    $$PhaseSessionsTableFilterComposer,
    $$PhaseSessionsTableOrderingComposer,
    $$PhaseSessionsTableAnnotationComposer,
    $$PhaseSessionsTableCreateCompanionBuilder,
    $$PhaseSessionsTableUpdateCompanionBuilder,
    (PhaseSession, $$PhaseSessionsTableReferences),
    PhaseSession,
    PrefetchHooks Function({bool phaseId, bool workoutId})>;
typedef $$PhaseExerciseTargetsTableCreateCompanionBuilder
    = PhaseExerciseTargetsCompanion Function({
  Value<int> id,
  required int phaseId,
  required int categoryId,
  Value<int?> targetRpe,
  Value<int?> targetSets,
  Value<int?> targetReps,
});
typedef $$PhaseExerciseTargetsTableUpdateCompanionBuilder
    = PhaseExerciseTargetsCompanion Function({
  Value<int> id,
  Value<int> phaseId,
  Value<int> categoryId,
  Value<int?> targetRpe,
  Value<int?> targetSets,
  Value<int?> targetReps,
});

final class $$PhaseExerciseTargetsTableReferences extends BaseReferences<
    _$AppDatabase, $PhaseExerciseTargetsTable, PhaseExerciseTarget> {
  $$PhaseExerciseTargetsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PlanPhasesTable _phaseIdTable(_$AppDatabase db) => db.planPhases
      .createAlias('phase_exercise_targets__phase_id__plan_phases__id');

  $$PlanPhasesTableProcessedTableManager get phaseId {
    final $_column = $_itemColumn<int>('phase_id')!;

    final manager = $$PlanPhasesTableTableManager($_db, $_db.planPhases)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories.createAlias(
          'phase_exercise_targets__category_id__exercise_categories__id');

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhaseExerciseTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $PhaseExerciseTargetsTable> {
  $$PhaseExerciseTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetRpe => $composableBuilder(
      column: $table.targetRpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnFilters(column));

  $$PlanPhasesTableFilterComposer get phaseId {
    final $$PlanPhasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableFilterComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhaseExerciseTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhaseExerciseTargetsTable> {
  $$PhaseExerciseTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetRpe => $composableBuilder(
      column: $table.targetRpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => ColumnOrderings(column));

  $$PlanPhasesTableOrderingComposer get phaseId {
    final $$PlanPhasesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableOrderingComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhaseExerciseTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhaseExerciseTargetsTable> {
  $$PhaseExerciseTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get targetRpe =>
      $composableBuilder(column: $table.targetRpe, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
      column: $table.targetSets, builder: (column) => column);

  GeneratedColumn<int> get targetReps => $composableBuilder(
      column: $table.targetReps, builder: (column) => column);

  $$PlanPhasesTableAnnotationComposer get phaseId {
    final $$PlanPhasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableAnnotationComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$PhaseExerciseTargetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhaseExerciseTargetsTable,
    PhaseExerciseTarget,
    $$PhaseExerciseTargetsTableFilterComposer,
    $$PhaseExerciseTargetsTableOrderingComposer,
    $$PhaseExerciseTargetsTableAnnotationComposer,
    $$PhaseExerciseTargetsTableCreateCompanionBuilder,
    $$PhaseExerciseTargetsTableUpdateCompanionBuilder,
    (PhaseExerciseTarget, $$PhaseExerciseTargetsTableReferences),
    PhaseExerciseTarget,
    PrefetchHooks Function({bool phaseId, bool categoryId})> {
  $$PhaseExerciseTargetsTableTableManager(
      _$AppDatabase db, $PhaseExerciseTargetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhaseExerciseTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhaseExerciseTargetsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhaseExerciseTargetsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> phaseId = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<int?> targetRpe = const Value.absent(),
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
          }) =>
              PhaseExerciseTargetsCompanion(
            id: id,
            phaseId: phaseId,
            categoryId: categoryId,
            targetRpe: targetRpe,
            targetSets: targetSets,
            targetReps: targetReps,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int phaseId,
            required int categoryId,
            Value<int?> targetRpe = const Value.absent(),
            Value<int?> targetSets = const Value.absent(),
            Value<int?> targetReps = const Value.absent(),
          }) =>
              PhaseExerciseTargetsCompanion.insert(
            id: id,
            phaseId: phaseId,
            categoryId: categoryId,
            targetRpe: targetRpe,
            targetSets: targetSets,
            targetReps: targetReps,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PhaseExerciseTargetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({phaseId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (phaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.phaseId,
                    referencedTable:
                        $$PhaseExerciseTargetsTableReferences._phaseIdTable(db),
                    referencedColumn: $$PhaseExerciseTargetsTableReferences
                        ._phaseIdTable(db)
                        .id,
                  ) as T;
                }
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$PhaseExerciseTargetsTableReferences
                        ._categoryIdTable(db),
                    referencedColumn: $$PhaseExerciseTargetsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhaseExerciseTargetsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $PhaseExerciseTargetsTable,
        PhaseExerciseTarget,
        $$PhaseExerciseTargetsTableFilterComposer,
        $$PhaseExerciseTargetsTableOrderingComposer,
        $$PhaseExerciseTargetsTableAnnotationComposer,
        $$PhaseExerciseTargetsTableCreateCompanionBuilder,
        $$PhaseExerciseTargetsTableUpdateCompanionBuilder,
        (PhaseExerciseTarget, $$PhaseExerciseTargetsTableReferences),
        PhaseExerciseTarget,
        PrefetchHooks Function({bool phaseId, bool categoryId})>;
typedef $$PlanEventsTableCreateCompanionBuilder = PlanEventsCompanion Function({
  Value<int> id,
  required int planId,
  required int phaseId,
  Value<int?> workoutId,
  Value<int?> pass,
  Value<int?> day,
  Value<bool> closesDay,
  required String dateStr,
  required int timestamp,
  required PlanEventKind kind,
});
typedef $$PlanEventsTableUpdateCompanionBuilder = PlanEventsCompanion Function({
  Value<int> id,
  Value<int> planId,
  Value<int> phaseId,
  Value<int?> workoutId,
  Value<int?> pass,
  Value<int?> day,
  Value<bool> closesDay,
  Value<String> dateStr,
  Value<int> timestamp,
  Value<PlanEventKind> kind,
});

final class $$PlanEventsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanEventsTable, PlanEvent> {
  $$PlanEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlansTable _planIdTable(_$AppDatabase db) =>
      db.plans.createAlias('plan_events__plan_id__plans__id');

  $$PlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$PlansTableTableManager($_db, $_db.plans)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PlanPhasesTable _phaseIdTable(_$AppDatabase db) =>
      db.planPhases.createAlias('plan_events__phase_id__plan_phases__id');

  $$PlanPhasesTableProcessedTableManager get phaseId {
    final $_column = $_itemColumn<int>('phase_id')!;

    final manager = $$PlanPhasesTableTableManager($_db, $_db.planPhases)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $WorkoutsTable _workoutIdTable(_$AppDatabase db) =>
      db.workouts.createAlias('plan_events__workout_id__workouts__id');

  $$WorkoutsTableProcessedTableManager? get workoutId {
    final $_column = $_itemColumn<int>('workout_id');
    if ($_column == null) return null;
    final manager = $$WorkoutsTableTableManager($_db, $_db.workouts)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PlanEventsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanEventsTable> {
  $$PlanEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pass => $composableBuilder(
      column: $table.pass, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get closesDay => $composableBuilder(
      column: $table.closesDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PlanEventKind, PlanEventKind, int> get kind =>
      $composableBuilder(
          column: $table.kind,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  $$PlansTableFilterComposer get planId {
    final $$PlansTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableFilterComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlanPhasesTableFilterComposer get phaseId {
    final $$PlanPhasesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableFilterComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableFilterComposer get workoutId {
    final $$WorkoutsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableFilterComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanEventsTable> {
  $$PlanEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pass => $composableBuilder(
      column: $table.pass, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get closesDay => $composableBuilder(
      column: $table.closesDay, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  $$PlansTableOrderingComposer get planId {
    final $$PlansTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableOrderingComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlanPhasesTableOrderingComposer get phaseId {
    final $$PlanPhasesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableOrderingComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableOrderingComposer get workoutId {
    final $$WorkoutsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableOrderingComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanEventsTable> {
  $$PlanEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pass =>
      $composableBuilder(column: $table.pass, builder: (column) => column);

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<bool> get closesDay =>
      $composableBuilder(column: $table.closesDay, builder: (column) => column);

  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PlanEventKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$PlansTableAnnotationComposer get planId {
    final $$PlansTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.planId,
        referencedTable: $db.plans,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlansTableAnnotationComposer(
              $db: $db,
              $table: $db.plans,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PlanPhasesTableAnnotationComposer get phaseId {
    final $$PlanPhasesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.phaseId,
        referencedTable: $db.planPhases,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PlanPhasesTableAnnotationComposer(
              $db: $db,
              $table: $db.planPhases,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$WorkoutsTableAnnotationComposer get workoutId {
    final $$WorkoutsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.workoutId,
        referencedTable: $db.workouts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$WorkoutsTableAnnotationComposer(
              $db: $db,
              $table: $db.workouts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PlanEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanEventsTable,
    PlanEvent,
    $$PlanEventsTableFilterComposer,
    $$PlanEventsTableOrderingComposer,
    $$PlanEventsTableAnnotationComposer,
    $$PlanEventsTableCreateCompanionBuilder,
    $$PlanEventsTableUpdateCompanionBuilder,
    (PlanEvent, $$PlanEventsTableReferences),
    PlanEvent,
    PrefetchHooks Function({bool planId, bool phaseId, bool workoutId})> {
  $$PlanEventsTableTableManager(_$AppDatabase db, $PlanEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> planId = const Value.absent(),
            Value<int> phaseId = const Value.absent(),
            Value<int?> workoutId = const Value.absent(),
            Value<int?> pass = const Value.absent(),
            Value<int?> day = const Value.absent(),
            Value<bool> closesDay = const Value.absent(),
            Value<String> dateStr = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<PlanEventKind> kind = const Value.absent(),
          }) =>
              PlanEventsCompanion(
            id: id,
            planId: planId,
            phaseId: phaseId,
            workoutId: workoutId,
            pass: pass,
            day: day,
            closesDay: closesDay,
            dateStr: dateStr,
            timestamp: timestamp,
            kind: kind,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int planId,
            required int phaseId,
            Value<int?> workoutId = const Value.absent(),
            Value<int?> pass = const Value.absent(),
            Value<int?> day = const Value.absent(),
            Value<bool> closesDay = const Value.absent(),
            required String dateStr,
            required int timestamp,
            required PlanEventKind kind,
          }) =>
              PlanEventsCompanion.insert(
            id: id,
            planId: planId,
            phaseId: phaseId,
            workoutId: workoutId,
            pass: pass,
            day: day,
            closesDay: closesDay,
            dateStr: dateStr,
            timestamp: timestamp,
            kind: kind,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PlanEventsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {planId = false, phaseId = false, workoutId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (planId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.planId,
                    referencedTable:
                        $$PlanEventsTableReferences._planIdTable(db),
                    referencedColumn:
                        $$PlanEventsTableReferences._planIdTable(db).id,
                  ) as T;
                }
                if (phaseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.phaseId,
                    referencedTable:
                        $$PlanEventsTableReferences._phaseIdTable(db),
                    referencedColumn:
                        $$PlanEventsTableReferences._phaseIdTable(db).id,
                  ) as T;
                }
                if (workoutId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.workoutId,
                    referencedTable:
                        $$PlanEventsTableReferences._workoutIdTable(db),
                    referencedColumn:
                        $$PlanEventsTableReferences._workoutIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PlanEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanEventsTable,
    PlanEvent,
    $$PlanEventsTableFilterComposer,
    $$PlanEventsTableOrderingComposer,
    $$PlanEventsTableAnnotationComposer,
    $$PlanEventsTableCreateCompanionBuilder,
    $$PlanEventsTableUpdateCompanionBuilder,
    (PlanEvent, $$PlanEventsTableReferences),
    PlanEvent,
    PrefetchHooks Function({bool planId, bool phaseId, bool workoutId})>;
typedef $$ExerciseImagesTableCreateCompanionBuilder = ExerciseImagesCompanion
    Function({
  Value<int> categoryId,
  required Uint8List data,
});
typedef $$ExerciseImagesTableUpdateCompanionBuilder = ExerciseImagesCompanion
    Function({
  Value<int> categoryId,
  Value<Uint8List> data,
});

final class $$ExerciseImagesTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseImagesTable, ExerciseImage> {
  $$ExerciseImagesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories
          .createAlias('exercise_images__category_id__exercise_categories__id');

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExerciseImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseImagesTable> {
  $$ExerciseImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExerciseImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseImagesTable> {
  $$ExerciseImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExerciseImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseImagesTable> {
  $$ExerciseImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ExerciseImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExerciseImagesTable,
    ExerciseImage,
    $$ExerciseImagesTableFilterComposer,
    $$ExerciseImagesTableOrderingComposer,
    $$ExerciseImagesTableAnnotationComposer,
    $$ExerciseImagesTableCreateCompanionBuilder,
    $$ExerciseImagesTableUpdateCompanionBuilder,
    (ExerciseImage, $$ExerciseImagesTableReferences),
    ExerciseImage,
    PrefetchHooks Function({bool categoryId})> {
  $$ExerciseImagesTableTableManager(
      _$AppDatabase db, $ExerciseImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> categoryId = const Value.absent(),
            Value<Uint8List> data = const Value.absent(),
          }) =>
              ExerciseImagesCompanion(
            categoryId: categoryId,
            data: data,
          ),
          createCompanionCallback: ({
            Value<int> categoryId = const Value.absent(),
            required Uint8List data,
          }) =>
              ExerciseImagesCompanion.insert(
            categoryId: categoryId,
            data: data,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExerciseImagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ExerciseImagesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ExerciseImagesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExerciseImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExerciseImagesTable,
    ExerciseImage,
    $$ExerciseImagesTableFilterComposer,
    $$ExerciseImagesTableOrderingComposer,
    $$ExerciseImagesTableAnnotationComposer,
    $$ExerciseImagesTableCreateCompanionBuilder,
    $$ExerciseImagesTableUpdateCompanionBuilder,
    (ExerciseImage, $$ExerciseImagesTableReferences),
    ExerciseImage,
    PrefetchHooks Function({bool categoryId})>;
typedef $$WorkoutSetsTableCreateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  required int categoryId,
  required String dateStr,
  required int timestamp,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> timeSecs,
  Value<int?> rpe,
  Value<String?> grade,
  Value<int?> wallAngle,
  Value<String?> climbName,
});
typedef $$WorkoutSetsTableUpdateCompanionBuilder = WorkoutSetsCompanion
    Function({
  Value<int> id,
  Value<int> categoryId,
  Value<String> dateStr,
  Value<int> timestamp,
  Value<double?> weightKg,
  Value<int?> reps,
  Value<int?> timeSecs,
  Value<int?> rpe,
  Value<String?> grade,
  Value<int?> wallAngle,
  Value<String?> climbName,
});

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories
          .createAlias('workout_sets__category_id__exercise_categories__id');

  $$ExerciseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeSecs => $composableBuilder(
      column: $table.timeSecs, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wallAngle => $composableBuilder(
      column: $table.wallAngle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get climbName => $composableBuilder(
      column: $table.climbName, builder: (column) => ColumnFilters(column));

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeSecs => $composableBuilder(
      column: $table.timeSecs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rpe => $composableBuilder(
      column: $table.rpe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wallAngle => $composableBuilder(
      column: $table.wallAngle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get climbName => $composableBuilder(
      column: $table.climbName, builder: (column) => ColumnOrderings(column));

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get timeSecs =>
      $composableBuilder(column: $table.timeSecs, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get wallAngle =>
      $composableBuilder(column: $table.wallAngle, builder: (column) => column);

  GeneratedColumn<String> get climbName =>
      $composableBuilder(column: $table.climbName, builder: (column) => column);

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WorkoutSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool categoryId})> {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> categoryId = const Value.absent(),
            Value<String> dateStr = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> timeSecs = const Value.absent(),
            Value<int?> rpe = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<int?> wallAngle = const Value.absent(),
            Value<String?> climbName = const Value.absent(),
          }) =>
              WorkoutSetsCompanion(
            id: id,
            categoryId: categoryId,
            dateStr: dateStr,
            timestamp: timestamp,
            weightKg: weightKg,
            reps: reps,
            timeSecs: timeSecs,
            rpe: rpe,
            grade: grade,
            wallAngle: wallAngle,
            climbName: climbName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int categoryId,
            required String dateStr,
            required int timestamp,
            Value<double?> weightKg = const Value.absent(),
            Value<int?> reps = const Value.absent(),
            Value<int?> timeSecs = const Value.absent(),
            Value<int?> rpe = const Value.absent(),
            Value<String?> grade = const Value.absent(),
            Value<int?> wallAngle = const Value.absent(),
            Value<String?> climbName = const Value.absent(),
          }) =>
              WorkoutSetsCompanion.insert(
            id: id,
            categoryId: categoryId,
            dateStr: dateStr,
            timestamp: timestamp,
            weightKg: weightKg,
            reps: reps,
            timeSecs: timeSecs,
            rpe: rpe,
            grade: grade,
            wallAngle: wallAngle,
            climbName: climbName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WorkoutSetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WorkoutSetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$WorkoutSetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WorkoutSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WorkoutSetsTable,
    WorkoutSet,
    $$WorkoutSetsTableFilterComposer,
    $$WorkoutSetsTableOrderingComposer,
    $$WorkoutSetsTableAnnotationComposer,
    $$WorkoutSetsTableCreateCompanionBuilder,
    $$WorkoutSetsTableUpdateCompanionBuilder,
    (WorkoutSet, $$WorkoutSetsTableReferences),
    WorkoutSet,
    PrefetchHooks Function({bool categoryId})>;
typedef $$DayNotesTableCreateCompanionBuilder = DayNotesCompanion Function({
  required String dateStr,
  required String note,
  Value<int> rowid,
});
typedef $$DayNotesTableUpdateCompanionBuilder = DayNotesCompanion Function({
  Value<String> dateStr,
  Value<String> note,
  Value<int> rowid,
});

class $$DayNotesTableFilterComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$DayNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$DayNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DayNotesTable> {
  $$DayNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$DayNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DayNotesTable,
    DayNote,
    $$DayNotesTableFilterComposer,
    $$DayNotesTableOrderingComposer,
    $$DayNotesTableAnnotationComposer,
    $$DayNotesTableCreateCompanionBuilder,
    $$DayNotesTableUpdateCompanionBuilder,
    (DayNote, BaseReferences<_$AppDatabase, $DayNotesTable, DayNote>),
    DayNote,
    PrefetchHooks Function()> {
  $$DayNotesTableTableManager(_$AppDatabase db, $DayNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DayNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DayNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DayNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateStr = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DayNotesCompanion(
            dateStr: dateStr,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateStr,
            required String note,
            Value<int> rowid = const Value.absent(),
          }) =>
              DayNotesCompanion.insert(
            dateStr: dateStr,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DayNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DayNotesTable,
    DayNote,
    $$DayNotesTableFilterComposer,
    $$DayNotesTableOrderingComposer,
    $$DayNotesTableAnnotationComposer,
    $$DayNotesTableCreateCompanionBuilder,
    $$DayNotesTableUpdateCompanionBuilder,
    (DayNote, BaseReferences<_$AppDatabase, $DayNotesTable, DayNote>),
    DayNote,
    PrefetchHooks Function()>;
typedef $$BodyWeightsTableCreateCompanionBuilder = BodyWeightsCompanion
    Function({
  required String dateStr,
  required double kg,
  Value<int> rowid,
});
typedef $$BodyWeightsTableUpdateCompanionBuilder = BodyWeightsCompanion
    Function({
  Value<String> dateStr,
  Value<double> kg,
  Value<int> rowid,
});

class $$BodyWeightsTableFilterComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnFilters(column));
}

class $$BodyWeightsTableOrderingComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateStr => $composableBuilder(
      column: $table.dateStr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get kg => $composableBuilder(
      column: $table.kg, builder: (column) => ColumnOrderings(column));
}

class $$BodyWeightsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BodyWeightsTable> {
  $$BodyWeightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateStr =>
      $composableBuilder(column: $table.dateStr, builder: (column) => column);

  GeneratedColumn<double> get kg =>
      $composableBuilder(column: $table.kg, builder: (column) => column);
}

class $$BodyWeightsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BodyWeightsTable,
    BodyWeight,
    $$BodyWeightsTableFilterComposer,
    $$BodyWeightsTableOrderingComposer,
    $$BodyWeightsTableAnnotationComposer,
    $$BodyWeightsTableCreateCompanionBuilder,
    $$BodyWeightsTableUpdateCompanionBuilder,
    (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
    BodyWeight,
    PrefetchHooks Function()> {
  $$BodyWeightsTableTableManager(_$AppDatabase db, $BodyWeightsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BodyWeightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BodyWeightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BodyWeightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateStr = const Value.absent(),
            Value<double> kg = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyWeightsCompanion(
            dateStr: dateStr,
            kg: kg,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateStr,
            required double kg,
            Value<int> rowid = const Value.absent(),
          }) =>
              BodyWeightsCompanion.insert(
            dateStr: dateStr,
            kg: kg,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BodyWeightsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BodyWeightsTable,
    BodyWeight,
    $$BodyWeightsTableFilterComposer,
    $$BodyWeightsTableOrderingComposer,
    $$BodyWeightsTableAnnotationComposer,
    $$BodyWeightsTableCreateCompanionBuilder,
    $$BodyWeightsTableUpdateCompanionBuilder,
    (BodyWeight, BaseReferences<_$AppDatabase, $BodyWeightsTable, BodyWeight>),
    BodyWeight,
    PrefetchHooks Function()>;
typedef $$InspirationsTableCreateCompanionBuilder = InspirationsCompanion
    Function({
  Value<int> id,
  required String title,
  required String url,
  Value<String?> notes,
  Value<int?> categoryId,
  required int addedAt,
});
typedef $$InspirationsTableUpdateCompanionBuilder = InspirationsCompanion
    Function({
  Value<int> id,
  Value<String> title,
  Value<String> url,
  Value<String?> notes,
  Value<int?> categoryId,
  Value<int> addedAt,
});

final class $$InspirationsTableReferences
    extends BaseReferences<_$AppDatabase, $InspirationsTable, Inspiration> {
  $$InspirationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExerciseCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.exerciseCategories
          .createAlias('inspirations__category_id__exercise_categories__id');

  $$ExerciseCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager =
        $$ExerciseCategoriesTableTableManager($_db, $_db.exerciseCategories)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$InspirationsTableFilterComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnFilters(column));

  $$ExerciseCategoriesTableFilterComposer get categoryId {
    final $$ExerciseCategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableFilterComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InspirationsTableOrderingComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get addedAt => $composableBuilder(
      column: $table.addedAt, builder: (column) => ColumnOrderings(column));

  $$ExerciseCategoriesTableOrderingComposer get categoryId {
    final $$ExerciseCategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.exerciseCategories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExerciseCategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.exerciseCategories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$InspirationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InspirationsTable> {
  $$InspirationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$ExerciseCategoriesTableAnnotationComposer get categoryId {
    final $$ExerciseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.exerciseCategories,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExerciseCategoriesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.exerciseCategories,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$InspirationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InspirationsTable,
    Inspiration,
    $$InspirationsTableFilterComposer,
    $$InspirationsTableOrderingComposer,
    $$InspirationsTableAnnotationComposer,
    $$InspirationsTableCreateCompanionBuilder,
    $$InspirationsTableUpdateCompanionBuilder,
    (Inspiration, $$InspirationsTableReferences),
    Inspiration,
    PrefetchHooks Function({bool categoryId})> {
  $$InspirationsTableTableManager(_$AppDatabase db, $InspirationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InspirationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InspirationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InspirationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            Value<int> addedAt = const Value.absent(),
          }) =>
              InspirationsCompanion(
            id: id,
            title: title,
            url: url,
            notes: notes,
            categoryId: categoryId,
            addedAt: addedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            required String url,
            Value<String?> notes = const Value.absent(),
            Value<int?> categoryId = const Value.absent(),
            required int addedAt,
          }) =>
              InspirationsCompanion.insert(
            id: id,
            title: title,
            url: url,
            notes: notes,
            categoryId: categoryId,
            addedAt: addedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$InspirationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$InspirationsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$InspirationsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$InspirationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InspirationsTable,
    Inspiration,
    $$InspirationsTableFilterComposer,
    $$InspirationsTableOrderingComposer,
    $$InspirationsTableAnnotationComposer,
    $$InspirationsTableCreateCompanionBuilder,
    $$InspirationsTableUpdateCompanionBuilder,
    (Inspiration, $$InspirationsTableReferences),
    Inspiration,
    PrefetchHooks Function({bool categoryId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WorkoutsTableTableManager get workouts =>
      $$WorkoutsTableTableManager(_db, _db.workouts);
  $$ExerciseCategoriesTableTableManager get exerciseCategories =>
      $$ExerciseCategoriesTableTableManager(_db, _db.exerciseCategories);
  $$WorkoutExercisesTableTableManager get workoutExercises =>
      $$WorkoutExercisesTableTableManager(_db, _db.workoutExercises);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PlanWorkoutsTableTableManager get planWorkouts =>
      $$PlanWorkoutsTableTableManager(_db, _db.planWorkouts);
  $$PlanPhasesTableTableManager get planPhases =>
      $$PlanPhasesTableTableManager(_db, _db.planPhases);
  $$PhaseSessionsTableTableManager get phaseSessions =>
      $$PhaseSessionsTableTableManager(_db, _db.phaseSessions);
  $$PhaseExerciseTargetsTableTableManager get phaseExerciseTargets =>
      $$PhaseExerciseTargetsTableTableManager(_db, _db.phaseExerciseTargets);
  $$PlanEventsTableTableManager get planEvents =>
      $$PlanEventsTableTableManager(_db, _db.planEvents);
  $$ExerciseImagesTableTableManager get exerciseImages =>
      $$ExerciseImagesTableTableManager(_db, _db.exerciseImages);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$DayNotesTableTableManager get dayNotes =>
      $$DayNotesTableTableManager(_db, _db.dayNotes);
  $$BodyWeightsTableTableManager get bodyWeights =>
      $$BodyWeightsTableTableManager(_db, _db.bodyWeights);
  $$InspirationsTableTableManager get inspirations =>
      $$InspirationsTableTableManager(_db, _db.inspirations);
}
