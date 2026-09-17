import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android MainActivity package matches the application ID', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final applicationId =
        RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradle)!.group(1)!;
    final activities = Directory('android/app/src/main/kotlin')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('MainActivity.kt'))
        .toList();

    expect(activities, hasLength(1));
    final source = activities.single.readAsStringSync();
    final activityPackage = RegExp(r'^package\s+([^\s]+)', multiLine: true)
        .firstMatch(source)!
        .group(1)!;

    expect('$activityPackage.MainActivity', '$applicationId.MainActivity');
    expect(
      gradle,
      contains('id("org.jetbrains.kotlin.android")'),
      reason: 'AGP 9 requires the Kotlin Android plugin for MainActivity.kt.',
    );
  });
}
