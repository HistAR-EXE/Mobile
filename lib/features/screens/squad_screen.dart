import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:histar_mobile/core/config/env.dart';
import 'package:histar_mobile/features/squad/squad_models.dart';
import 'package:histar_mobile/shared/providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Minimal tiểu đội: REST create/join + mở lobby Web trên FE.
class SquadScreen extends ConsumerStatefulWidget {
  const SquadScreen({super.key});

  @override
  ConsumerState<SquadScreen> createState() => _SquadScreenState();
}

class _SquadScreenState extends ConsumerState<SquadScreen> {
  final _joinController = TextEditingController();
  final _siteController = TextEditingController();
  bool _busy = false;
  SquadMe? _squad;

  @override
  void initState() {
    super.initState();
    _loadMe();
  }

  Future<void> _loadMe() async {
    final me = await ref.read(squadRepositoryProvider).me();
    if (mounted) setState(() => _squad = me);
  }

  Future<void> _create() async {
    setState(() => _busy = true);
    try {
      final created = await ref
          .read(squadRepositoryProvider)
          .create(siteCode: _siteController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiểu đội ${created.code}')),
      );
      await _loadMe();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _join() async {
    final code = _joinController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mã 6 ký tự')),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(squadRepositoryProvider).join(code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tham gia tiểu đội')),
      );
      await _loadMe();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openWebLobby() async {
    final base = AppEnv.webAppUrl.replaceAll(RegExp(r'/$'), '');
    final uri = Uri.parse('$base/squad');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tiểu đội')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _squad == null ? _buildForms() : _buildSquad(_squad!),
      ),
    );
  }

  Widget _buildForms() {
    return ListView(
      children: [
        const Text(
          'Tạo hoặc tham gia tiểu đội (REST). Đồng bộ live qua Web.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _siteController,
          decoration: const InputDecoration(labelText: 'Mã điểm (tuỳ chọn)'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _create,
          child: const Text('Tạo tiểu đội'),
        ),
        const Divider(height: 32),
        TextField(
          controller: _joinController,
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Mã 6 ký tự'),
        ),
        FilledButton.tonal(
          onPressed: _busy ? null : _join,
          child: const Text('Tham gia'),
        ),
      ],
    );
  }

  Widget _buildSquad(SquadMe squad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mã: ${squad.code}', style: Theme.of(context).textTheme.headlineSmall),
        if (squad.siteCode != null) Text('Điểm: ${squad.siteCode}'),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: squad.members.length,
            itemBuilder: (_, i) {
              final m = squad.members[i];
              final station = m.stationCode ?? '—';
              return ListTile(
                title: Text(m.displayName),
                subtitle: Text('Trạm: $station'),
              );
            },
          ),
        ),
        OutlinedButton(
          onPressed: _openWebLobby,
          child: const Text('Mở lobby Web (WebSocket)'),
        ),
        TextButton(onPressed: _loadMe, child: const Text('Làm mới')),
      ],
    );
  }
}
