import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kins_fleet_drivers/core/auth/auth_provider.dart';
import 'package:kins_fleet_drivers/core/l10n/auth_messages.dart';
import 'package:kins_fleet_drivers/core/utils/validators.dart';
import 'package:kins_fleet_drivers/l10n/app_localizations.dart';
import 'package:kins_fleet_drivers/widgets/error_banner.dart';
import 'package:kins_fleet_drivers/widgets/loading_overlay.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    auth.clearLoginError();

    final success = await auth.sendPasswordReset(_emailController.text);
    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotTitle),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _emailSent ? l10n.forgotEmailSentTitle : l10n.forgotResetTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailSent
                          ? l10n.forgotEmailSentBody
                          : l10n.forgotInstructions,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (auth.loginErrorKey != null) ...[
                      ErrorBanner(
                        message: auth.loginErrorKey!.localize(l10n),
                        onDismiss: auth.clearLoginError,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!_emailSent) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: l10n.loginEmail,
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) => Validators.email(value, l10n),
                        enabled: !auth.isBusy,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: auth.isBusy ? null : _submit,
                        child: Text(l10n.forgotSend),
                      ),
                    ] else ...[
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: Text(l10n.forgotBack),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (auth.isBusy) LoadingOverlay(message: l10n.forgotBusy),
          ],
        ),
      ),
    );
  }
}
