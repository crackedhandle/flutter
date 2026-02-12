import 'dart:convert';
import 'dart:io';

Future<int> main(List<String> args) async {
  // If a path is passed use it, else default to repository root
  final workingDir = args.isNotEmpty ? args.first : Directory.current.path;
  print('Running in directory: \');

  // 1) Run flutter analyze (if available)
  var analyzeResult = await Process.run('flutter', ['analyze', workingDir]);
  if (analyzeResult.stdout != null) stdout.write(analyzeResult.stdout);
  if (analyzeResult.stderr != null) stderr.write(analyzeResult.stderr);

  // 2) Run dart fix --dry-run --format=json to check for auto-fixes
  print('\\nChecking for dart fix suggestions (dry-run) ...');
  var fixProc = await Process.run('dart', ['fix', '--dry-run', '--format=json'], workingDirectory: workingDir);

  if (fixProc.exitCode != 0) {
    print('dart fix did not run successfully. It may not be available in PATH or there was an error:');
    if (fixProc.stderr != null) stderr.write(fixProc.stderr);
    return analyzeResult.exitCode ?? 1;
  }

  try {
    final jsonOut = fixProc.stdout == null ? '{}' : fixProc.stdout as String;
    final dynamic decoded = json.decode(jsonOut);
    int fixes = 0;

    if (decoded is Map && decoded.containsKey('changes')) {
      final changes = decoded['changes'] as List<dynamic>;
      fixes = changes.length;
    } else if (decoded is Map && decoded.containsKey('fixes')) {
      final fixesList = decoded['fixes'] as List<dynamic>;
      fixes = fixesList.length;
    } else {
      final out = jsonOut.trim();
      if (out.isNotEmpty && out != '[]') fixes = 1;
    }

    if (fixes > 0) {
      print("\\nSome issues can be automatically fixed by running: dart fix --apply");
    } else {
      print("\\nNo automatic fixes reported by dart fix.");
    }
  } catch (e) {
    print('Failed to parse dart fix output as JSON: \');
    print('Raw output:');
    print(fixProc.stdout);
  }

  return analyzeResult.exitCode ?? 0;
}
