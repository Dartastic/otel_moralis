// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'dart:async';

const _key = #dartastic_otel_libs_moralis_suppress;

bool moralisInstrumentationSuppressed() => Zone.current[_key] == true;

T runWithoutMoralisInstrumentation<T>(T Function() body) =>
    runZoned(body, zoneValues: {_key: true});

Future<T> runWithoutMoralisInstrumentationAsync<T>(
  Future<T> Function() body,
) =>
    runZoned(body, zoneValues: {_key: true});
