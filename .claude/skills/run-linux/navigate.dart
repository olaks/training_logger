import 'package:vm_service/vm_service_io.dart';

/// Evaluates args[1] in app.dart's scope on the app's main isolate (drift
/// runs another, where the router doesn't exist), and prints the result.
Future<void> main(List<String> args) async {
  final service = await vmServiceConnectUri(args[0]);
  try {
    final vm = await service.getVM();
    final main = vm.isolates!.firstWhere((i) => i.name == 'main');
    final iso = await service.getIsolate(main.id!);
    final lib = iso.libraries!
        .firstWhere((l) => l.uri == 'package:training_logger/app.dart');
    final r = await service.evaluate(main.id!, lib.id!, args[1]);
    print(r.json?['kind'] == 'Null' ? 'ok' : r);
  } finally {
    await service.dispose();
  }
}
