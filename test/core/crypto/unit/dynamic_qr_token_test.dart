import 'package:attendance_app/core/crypto/qr_token_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QrTokenService service;

  setUp(() {
    service = QrTokenService();
  });

  test('generateDynamicSessionToken generates valid signed token for current window', () async {
    final now = DateTime(2026, 9, 21, 10, 0, 0);
    final token = await service.generateDynamicSessionToken(
      sessionId: 'session_123',
      programId: 'program_abc',
      sessionTitle: 'Flutter Advanced',
      windowSeconds: 20,
      now: now,
    );

    expect(token, isNotEmpty);
    expect(token.contains('.'), isTrue);

    final payload = await service.verifyDynamicSessionToken(
      token,
      windowSeconds: 20,
      now: now,
    );

    expect(payload, isNotNull);
    expect(payload!.sessionId, 'session_123');
    expect(payload.programId, 'program_abc');
    expect(payload.sessionTitle, 'Flutter Advanced');
  });

  test('verifyDynamicSessionToken accepts token within +-1 window tolerance', () async {
    final t0 = DateTime(2026, 9, 21, 10, 0, 0);
    final token = await service.generateDynamicSessionToken(
      sessionId: 'session_123',
      programId: 'program_abc',
      sessionTitle: 'Flutter Advanced',
      windowSeconds: 20,
      now: t0,
    );

    // 15 seconds later (same window or +1)
    final t1 = t0.add(const Duration(seconds: 15));
    final verifiedT1 = await service.verifyDynamicSessionToken(
      token,
      windowSeconds: 20,
      now: t1,
    );
    expect(verifiedT1, isNotNull);

    // 25 seconds later (windowIndex diff is 1)
    final t2 = t0.add(const Duration(seconds: 25));
    final verifiedT2 = await service.verifyDynamicSessionToken(
      token,
      windowSeconds: 20,
      now: t2,
    );
    expect(verifiedT2, isNotNull);
  });

  test('verifyDynamicSessionToken rejects expired token outside tolerance window', () async {
    final t0 = DateTime(2026, 9, 21, 10, 0, 0);
    final token = await service.generateDynamicSessionToken(
      sessionId: 'session_123',
      programId: 'program_abc',
      sessionTitle: 'Flutter Advanced',
      windowSeconds: 20,
      now: t0,
    );

    // 45 seconds later (windowIndex diff is > 1)
    final tExpired = t0.add(const Duration(seconds: 45));
    final verifiedExpired = await service.verifyDynamicSessionToken(
      token,
      windowSeconds: 20,
      now: tExpired,
    );
    expect(verifiedExpired, isNull);
  });

  test('verifyDynamicSessionToken rejects tampered token', () async {
    final now = DateTime.now();
    final token = await service.generateDynamicSessionToken(
      sessionId: 'session_123',
      programId: 'program_abc',
      sessionTitle: 'Flutter Advanced',
      windowSeconds: 20,
      now: now,
    );

    final tamperedToken = '${token.substring(0, token.length - 4)}AAAA';
    final payload = await service.verifyDynamicSessionToken(
      tamperedToken,
      windowSeconds: 20,
      now: now,
    );

    expect(payload, isNull);
  });
}
