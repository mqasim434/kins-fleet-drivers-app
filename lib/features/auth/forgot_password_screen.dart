import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kins_fleet_drivers/core/auth/auth_controller.dart';
import 'package:kins_fleet_drivers/core/config/app_colors.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;
  bool _sent = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Vul uw e-mailadres in.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final message = await context.read<AuthController>().sendPasswordReset(email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _sent = message == null;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wachtwoord')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'We sturen een link om uw wachtwoord te resetten. Het account zelf blijft hetzelfde als in de planning.',
            style: TextStyle(color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-mail'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.bordeaux)),
          ],
          if (_sent) ...[
            const SizedBox(height: 12),
            const Text('Controleer uw inbox voor de resetlink.'),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'Bezig…' : 'Verstuur link'),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Terug naar inloggen'),
          ),
        ],
      ),
    );
  }
}
