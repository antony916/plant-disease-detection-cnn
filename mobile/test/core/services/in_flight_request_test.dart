import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:plantcare_ai/core/services/in_flight_request.dart';

void main() {
  test('coalesces concurrent requests for the same key', () async {
    final requests = InFlightRequest<int>();
    final result = Completer<int>();
    var callCount = 0;

    final first = requests.run('user-1', () {
      callCount++;
      return result.future;
    });
    final second = requests.run('user-1', () {
      callCount++;
      return Future.value(2);
    });

    expect(callCount, 1);
    result.complete(1);

    expect(await first, 1);
    expect(await second, 1);
  });

  test('keeps requests for different keys independent', () async {
    final requests = InFlightRequest<int>();
    final firstResult = Completer<int>();
    final secondResult = Completer<int>();
    var callCount = 0;

    final first = requests.run('user-1', () {
      callCount++;
      return firstResult.future;
    });
    final second = requests.run('user-2', () {
      callCount++;
      return secondResult.future;
    });

    expect(callCount, 2);
    firstResult.complete(1);
    secondResult.complete(2);

    expect(await first, 1);
    expect(await second, 2);
  });

  test('clears completed and failed requests so callers can retry', () async {
    final requests = InFlightRequest<int>();
    var callCount = 0;

    expect(await requests.run('user-1', () async => ++callCount), 1);

    final failedResult = Completer<int>();
    final first = requests.run('user-1', () {
      callCount++;
      return failedResult.future;
    });
    final second = requests.run('user-1', () {
      callCount++;
      return Future.value(-1);
    });
    failedResult.completeError(StateError('temporary failure'));

    await expectLater(
      Future.wait([first, second]),
      throwsA(isA<StateError>()),
    );

    expect(await requests.run('user-1', () async => ++callCount), 3);
  });
}
