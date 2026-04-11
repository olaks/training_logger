/// Fontainebleau bouldering grades (most common globally).
const fontGrades = [
  '3', '4', '4+', '5', '5+',
  '6A', '6A+', '6B', '6B+', '6C', '6C+',
  '7A', '7A+', '7B', '7B+', '7C', '7C+',
  '8A', '8A+', '8B', '8B+', '8C', '8C+',
];

/// Hueco V-scale bouldering grades.
const vGrades = [
  'VB', 'V0', 'V1', 'V2', 'V3', 'V4',
  'V5', 'V6', 'V7', 'V8', 'V9', 'V10',
  'V11', 'V12', 'V13', 'V14', 'V15', 'V16', 'V17',
];

/// Given a set of logged grade strings, returns whichever scale they belong to.
/// Defaults to Font if mixed or unrecognised.
List<String> detectGradeScale(Iterable<String> grades) {
  if (grades.any((g) => vGrades.contains(g))) return vGrades;
  return fontGrades;
}

/// Maps a grade string to its numeric index in [scale], or −1 if not found.
int gradeToIndex(String grade, List<String> scale) => scale.indexOf(grade);
