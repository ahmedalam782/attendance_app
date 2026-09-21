import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:injectable/injectable.dart';

class QrPayload {
  const QrPayload({
    required this.studentId,
    required this.studentName,
    required this.issuedAt,
    this.expiresAt,
  });

  final String studentId;
  final String studentName;
  final DateTime issuedAt;
  final DateTime? expiresAt;

  Map<String, dynamic> toJson() => {
        'sid': studentId,
        'name': studentName,
        'iat': issuedAt.millisecondsSinceEpoch,
        if (expiresAt != null) 'exp': expiresAt!.millisecondsSinceEpoch,
      };

  factory QrPayload.fromJson(Map<String, dynamic> json) {
    return QrPayload(
      studentId: json['sid'] as String? ?? '',
      studentName: json['name'] as String? ?? '',
      issuedAt: json['iat'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['iat'] as int)
          : DateTime.now(),
      expiresAt: json['exp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['exp'] as int)
          : null,
    );
  }
}

@lazySingleton
class QrTokenService {
  QrTokenService() : _algorithm = Ed25519();

  final Ed25519 _algorithm;

  // 32-byte deterministic seed for development / offline self-signed tokens.
  // In production, server Cloud Functions sign with Secret Manager private key.
  static final List<int> _defaultSeed = List<int>.generate(
    32,
    (i) => (i * 7 + 13) % 256,
  );

  SimpleKeyPair? _cachedKeyPair;

  Future<SimpleKeyPair> _getKeyPair() async {
    return _cachedKeyPair ??=
        await _algorithm.newKeyPairFromSeed(_defaultSeed);
  }

  /// Generates a signed QR token string: base64url(payload).base64url(signature)
  Future<String> generateToken({
    required String studentId,
    required String studentName,
    DateTime? expiresAt,
  }) async {
    final payload = QrPayload(
      studentId: studentId,
      studentName: studentName,
      issuedAt: DateTime.now(),
      expiresAt: expiresAt,
    );

    final payloadJson = jsonEncode(payload.toJson());
    final payloadBytes = utf8.encode(payloadJson);
    final payloadB64 = base64UrlEncode(payloadBytes);

    final keyPair = await _getKeyPair();
    final signature = await _algorithm.sign(payloadBytes, keyPair: keyPair);
    final sigB64 = base64UrlEncode(signature.bytes);

    return '$payloadB64.$sigB64';
  }

  /// Verifies an Ed25519 signed QR token string and returns the decoded payload.
  /// If the token is invalid, expired, or malformed, returns null.
  Future<QrPayload?> verifyToken(String token) async {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 2) return null;

      final payloadBytes = base64Url.decode(base64Url.normalize(parts[0]));
      final signatureBytes = base64Url.decode(base64Url.normalize(parts[1]));

      final keyPair = await _getKeyPair();
      final publicKey = await keyPair.extractPublicKey();

      final isValid = await _algorithm.verify(
        payloadBytes,
        signature: Signature(
          signatureBytes,
          publicKey: publicKey,
        ),
      );

      if (!isValid) return null;

      final jsonStr = utf8.decode(payloadBytes);
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      final payload = QrPayload.fromJson(jsonMap);

      if (payload.studentId.isEmpty) return null;

      // Check expiry if set
      if (payload.expiresAt != null &&
          DateTime.now().isAfter(payload.expiresAt!)) {
        return null;
      }

      return payload;
    } catch (_) {
      return null;
    }
  }

  /// Generates a rotating session token valid for the given time window (default 20 seconds).
  Future<String> generateDynamicSessionToken({
    required String sessionId,
    required String programId,
    required String sessionTitle,
    int windowSeconds = 20,
    DateTime? now,
  }) async {
    final currentTime = now ?? DateTime.now();
    final windowIndex =
        currentTime.millisecondsSinceEpoch ~/ (windowSeconds * 1000);

    final payload = DynamicSessionPayload(
      sessionId: sessionId,
      programId: programId,
      sessionTitle: sessionTitle,
      timestamp: currentTime,
      windowIndex: windowIndex,
    );

    final payloadJson = jsonEncode(payload.toJson());
    final payloadBytes = utf8.encode(payloadJson);
    final payloadB64 = base64UrlEncode(payloadBytes);

    final keyPair = await _getKeyPair();
    final signature = await _algorithm.sign(payloadBytes, keyPair: keyPair);
    final sigB64 = base64UrlEncode(signature.bytes);

    return '$payloadB64.$sigB64';
  }

  /// Verifies a rotating dynamic session token.
  /// Tolerance of ±1 window (i.e. currently within current window or previous window)
  /// ensures reliable scanning without allowing older photographed codes.
  Future<DynamicSessionPayload?> verifyDynamicSessionToken(
    String token, {
    int windowSeconds = 20,
    DateTime? now,
  }) async {
    try {
      final parts = token.trim().split('.');
      if (parts.length != 2) return null;

      final payloadBytes = base64Url.decode(base64Url.normalize(parts[0]));
      final signatureBytes = base64Url.decode(base64Url.normalize(parts[1]));

      final keyPair = await _getKeyPair();
      final publicKey = await keyPair.extractPublicKey();

      final isValid = await _algorithm.verify(
        payloadBytes,
        signature: Signature(
          signatureBytes,
          publicKey: publicKey,
        ),
      );

      if (!isValid) return null;

      final jsonStr = utf8.decode(payloadBytes);
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (jsonMap['type'] != 'dyn_session') return null;

      final payload = DynamicSessionPayload.fromJson(jsonMap);
      if (payload.sessionId.isEmpty || payload.programId.isEmpty) return null;

      final currentTime = now ?? DateTime.now();
      final currentWindow =
          currentTime.millisecondsSinceEpoch ~/ (windowSeconds * 1000);

      // Allow tolerance: difference of at most 1 window (e.g. within previous or current window)
      final diff = (currentWindow - payload.windowIndex).abs();
      if (diff > 1) {
        return null; // Expired or invalid time window
      }

      return payload;
    } catch (_) {
      return null;
    }
  }
}

class DynamicSessionPayload {
  const DynamicSessionPayload({
    required this.sessionId,
    required this.programId,
    required this.sessionTitle,
    required this.timestamp,
    required this.windowIndex,
  });

  final String sessionId;
  final String programId;
  final String sessionTitle;
  final DateTime timestamp;
  final int windowIndex;

  Map<String, dynamic> toJson() => {
        'type': 'dyn_session',
        'sid': sessionId,
        'pid': programId,
        'title': sessionTitle,
        'ts': timestamp.millisecondsSinceEpoch,
        'win': windowIndex,
      };

  factory DynamicSessionPayload.fromJson(Map<String, dynamic> json) {
    return DynamicSessionPayload(
      sessionId: json['sid'] as String? ?? '',
      programId: json['pid'] as String? ?? '',
      sessionTitle: json['title'] as String? ?? '',
      timestamp: json['ts'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ts'] as int)
          : DateTime.now(),
      windowIndex: json['win'] as int? ?? 0,
    );
  }
}
