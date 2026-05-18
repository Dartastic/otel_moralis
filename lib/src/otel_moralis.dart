// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_moralis_suppression.dart';

const _tracerName = 'dartastic_otel_libs_moralis';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class MoralisResult {
  const MoralisResult({
    this.surface,
    this.chain,
    this.address,
    this.tokenAddress,
    this.tokenId,
    this.tokenStandard,
    this.tokenCount,
    this.balanceWei,
    this.priceUsdMicros,
    this.txHash,
    this.streamId,
    this.streamTriggerKind,
    this.solanaNetwork,
    this.aptosNetwork,
    this.queryCount,
    this.creditsUsed,
    this.rateLimitRemaining,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// `evm`, `solana`, `aptos`, `streams`, `auth`, `extended_evm_api`,
  /// `nft`, `defi`, `wallet`, `entity`.
  final String? surface;

  /// EVM hex chain id (`0x1`, `0x89`, `0xa4b1`, ...) or chain slug
  /// (`eth`, `polygon`, `arbitrum`, `base`, `optimism`, `avalanche`,
  /// `bsc`, `fantom`, `palm`, `cronos`).
  final String? chain;

  final String? address;
  final String? tokenAddress;
  final String? tokenId;

  /// `ERC20`, `ERC721`, `ERC1155`, `SPL`, `AptosCoin`, `AptosTokenObject`.
  final String? tokenStandard;
  final int? tokenCount;

  /// Wei balance for native token.
  final String? balanceWei;

  /// USD price in millionths.
  final int? priceUsdMicros;

  final String? txHash;

  // ── Streams ────────────────────────────────────────────────────
  final String? streamId;

  /// `transactions`, `internal_transactions`, `logs`, `native_balances`,
  /// `nft_transfers`, `token_transfers`.
  final String? streamTriggerKind;

  // ── Solana / Aptos ─────────────────────────────────────────────
  /// `mainnet`, `devnet`, `testnet`.
  final String? solanaNetwork;
  final String? aptosNetwork;

  final int? queryCount;

  /// Moralis credits charged (primary billing).
  final int? creditsUsed;
  final int? rateLimitRemaining;

  /// Moralis error code.
  final String? errorCode;
  final String? errorMessage;
  final int? statusCode;
}

class MoralisCallResult<T> {
  const MoralisCallResult({required this.value, this.result});
  final T value;
  final MoralisResult? result;
}

/// Wraps a Moralis API call in a CLIENT span. [operation] is one of
/// `evm.getNativeBalance`, `evm.getTokenBalances`, `evm.getTokenMetadata`,
/// `evm.getTokenPrice`, `evm.getTransaction`,
/// `evm.getTransactionsByWallet`, `evm.getNFTsByWallet`,
/// `evm.getNFTMetadata`, `evm.getNFTOwners`, `evm.getNFTContractMetadata`,
/// `evm.getNFTTransfers`, `evm.getContractEvents`, `evm.runContractFunction`,
/// `evm.resolveENS`, `evm.lookupENS`, `defi.getPositions`, `defi.getPnL`,
/// `wallet.getWalletNetWorth`, `wallet.getWalletProfile`,
/// `entity.getEntity`, `solana.getBalance`, `solana.getSPLTokens`,
/// `solana.getNFTs`, `solana.getPortfolio`, `solana.getNFTMetadata`,
/// `aptos.getAccountBalance`, `aptos.getNFTs`,
/// `streams.create`, `streams.delete`, `streams.update`, `streams.list`,
/// `streams.addAddress`, `streams.removeAddress`,
/// `auth.requestChallengeEvm`, `auth.verifyChallengeEvm`,
/// `auth.requestChallengeSolana`, `auth.verifyChallengeSolana`.
Future<T> tracedMoralis<T>({
  required String operation,
  required Future<MoralisCallResult<T>> Function() invoke,
}) async {
  if (moralisInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'moralis',
    'rpc.method': operation,
    'moralis.operation': operation,
  };

  final span = _tracer().startSpan(
    'moralis $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.surface != null) {
        extras.add(OTel.attributeString('moralis.surface', res.surface!));
      }
      if (res.chain != null) {
        extras.add(OTel.attributeString('moralis.chain', res.chain!));
      }
      if (res.address != null) {
        extras.add(OTel.attributeString('moralis.address', res.address!));
      }
      if (res.tokenAddress != null) {
        extras.add(OTel.attributeString(
          'moralis.token.address',
          res.tokenAddress!,
        ));
      }
      if (res.tokenId != null) {
        extras.add(OTel.attributeString('moralis.token.id', res.tokenId!));
      }
      if (res.tokenStandard != null) {
        extras.add(OTel.attributeString(
          'moralis.token.standard',
          res.tokenStandard!,
        ));
      }
      if (res.tokenCount != null) {
        extras.add(OTel.attributeInt(
          'moralis.token.count',
          res.tokenCount!,
        ));
      }
      if (res.balanceWei != null) {
        extras.add(OTel.attributeString(
          'moralis.balance.wei',
          res.balanceWei!,
        ));
      }
      if (res.priceUsdMicros != null) {
        extras.add(OTel.attributeInt(
          'moralis.price.usd_micros',
          res.priceUsdMicros!,
        ));
      }
      if (res.txHash != null) {
        extras.add(OTel.attributeString('moralis.tx.hash', res.txHash!));
      }
      if (res.streamId != null) {
        extras.add(OTel.attributeString(
          'moralis.stream.id',
          res.streamId!,
        ));
      }
      if (res.streamTriggerKind != null) {
        extras.add(OTel.attributeString(
          'moralis.stream.trigger.kind',
          res.streamTriggerKind!,
        ));
      }
      if (res.solanaNetwork != null) {
        extras.add(OTel.attributeString(
          'moralis.solana.network',
          res.solanaNetwork!,
        ));
      }
      if (res.aptosNetwork != null) {
        extras.add(OTel.attributeString(
          'moralis.aptos.network',
          res.aptosNetwork!,
        ));
      }
      if (res.queryCount != null) {
        extras.add(OTel.attributeInt(
          'moralis.query.count',
          res.queryCount!,
        ));
      }
      if (res.creditsUsed != null) {
        extras.add(OTel.attributeInt(
          'moralis.credits.used',
          res.creditsUsed!,
        ));
      }
      if (res.rateLimitRemaining != null) {
        extras.add(OTel.attributeInt(
          'moralis.rate_limit.remaining',
          res.rateLimitRemaining!,
        ));
      }
      if (res.errorCode != null) {
        extras.add(OTel.attributeString(
          'moralis.error.code',
          res.errorCode!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Moralis ${res.errorCode}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'moralis.error.message',
          res.errorMessage!,
        ));
      }
      if (res.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          res.statusCode!,
        ));
        if (res.statusCode! >= 400) {
          span.setStatus(
              SpanStatusCode.Error, 'Moralis HTTP ${res.statusCode}');
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
