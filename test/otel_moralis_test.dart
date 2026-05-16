// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_moralis/otel_moralis.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_moralis-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('evm.getTokenBalances records chain + credits', () async {
    await tracedMoralis<String>(
      operation: 'evm.getTokenBalances',
      invoke: () async => const MoralisCallResult(
        value: 'ok',
        result: MoralisResult(
          surface: 'evm',
          chain: '0x1',
          address: '0xabc',
          tokenCount: 24,
          creditsUsed: 10,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('moralis evm.getTokenBalances')!);
    expect(a['moralis.chain'], '0x1');
    expect(a['moralis.token.count'], 24);
  });

  test('streams.create records trigger kind', () async {
    await tracedMoralis<String>(
      operation: 'streams.create',
      invoke: () async => const MoralisCallResult(
        value: 'ok',
        result: MoralisResult(
          surface: 'streams',
          streamId: 's_1',
          streamTriggerKind: 'token_transfers',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('moralis streams.create')!);
    expect(a['moralis.stream.trigger.kind'], 'token_transfers');
  });

  test('error sets span error', () async {
    await tracedMoralis<String>(
      operation: 'evm.getNFTsByWallet',
      invoke: () async => const MoralisCallResult(
        value: 'ok',
        result: MoralisResult(
          errorCode: 'C0008',
          errorMessage: 'No content found',
          statusCode: 404,
        ),
      ),
    );
    expect(
      spans.findSpanByName('moralis evm.getNFTsByWallet')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutMoralisInstrumentationAsync(() async {
      await tracedMoralis<String>(
        operation: 'auth.requestChallengeEvm',
        invoke: () async => const MoralisCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('moralis '), isEmpty);
  });
}
