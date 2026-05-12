import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meowdabattery/utils/storage.dart';

/// Optional insecure shared sync.
///
/// Configure with:
/// --dart-define=HOUSECYCLE_SYNC_URL=https://api.jsonbin.io/v3/b/<bin-id>
/// --dart-define=HOUSECYCLE_SYNC_KEY=<jsonbin-master-key>
///
/// The app still works locally when these values are not provided.
class RemoteSync {
  static const _url = String.fromEnvironment('HOUSECYCLE_SYNC_URL');
  static const _key = String.fromEnvironment('HOUSECYCLE_SYNC_KEY');
  static const _pollInterval = Duration(seconds: 15);

  Timer? _timer;
  bool _isSyncing = false;

  bool get isEnabled => _url.isNotEmpty;

  Future<bool> pull() async {
    if (!isEnabled || _isSyncing) return false;
    _isSyncing = true;
    try {
      final response = await http.get(Uri.parse(_readUrl), headers: _headers);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return false;
      }

      final decoded = jsonDecode(response.body);
      final state = _extractState(decoded);
      if (state == null) return false;
      return Storage.applySharedState(state);
    } catch (_) {
      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> push() async {
    if (!isEnabled || _isSyncing) return;
    _isSyncing = true;
    try {
      await http.put(
        Uri.parse(_url),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode({
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
          'state': Storage.getSharedState(),
        }),
      );
    } catch (_) {
      // Local state remains the source of truth until the next successful push.
    } finally {
      _isSyncing = false;
    }
  }

  void startPolling(void Function() onRemoteChange) {
    if (!isEnabled || _timer != null) return;
    _timer = Timer.periodic(_pollInterval, (_) async {
      final changed = await pull();
      if (changed) onRemoteChange();
    });
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  String get _readUrl =>
      _url.contains('api.jsonbin.io') && !_url.endsWith('/latest')
      ? '$_url/latest'
      : _url;

  Map<String, String> get _headers =>
      _key.isEmpty ? const {} : const {'X-Master-Key': _key};

  Map<String, Object?>? _extractState(Object? decoded) {
    if (decoded is! Map) return null;

    final root = Map<String, Object?>.from(decoded);
    final record = root['record'];
    final data = record is Map ? Map<String, Object?>.from(record) : root;
    final state = data['state'];

    if (state is Map) {
      return Map<String, Object?>.from(state);
    }

    return Map<String, Object?>.from(data);
  }
}
