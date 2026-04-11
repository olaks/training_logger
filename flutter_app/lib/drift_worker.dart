// Compiled to web/drift_worker.js for web SQLite support.
// Run: dart compile js -O2 -o web/drift_worker.js lib/drift_worker.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
