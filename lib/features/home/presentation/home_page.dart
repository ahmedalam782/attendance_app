import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/languages/locale_keys.g.dart';
import '../../auth/presentation/view/pages/auth_page.dart';
import '../../splash/presentation/splash_page.dart';
import '../data/app_bootstrap_impl.dart';
import '../domain/app_bootstrap.dart';

/// First route: displays the animated splash screen during bootstrap,
/// then transitions gracefully to the auth flow.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.bootstrap});

  final AppBootstrap? bootstrap;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AppBootstrap _bootstrap =
      widget.bootstrap ?? AppBootstrapImpl();

  var _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Future.wait([
        _bootstrap.run(),
        Future<void>.delayed(const Duration(milliseconds: 1400)),
      ]);
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: _loading
          ? const SplashPage(key: ValueKey('splash'))
          : _error != null
              ? _errorView(context)
              : const AuthPage(key: ValueKey('auth')),
    );
  }

  Widget _errorView(BuildContext context) => Scaffold(
        key: const ValueKey('error'),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    LocaleKeys.global_setup_incomplete.tr(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _initialize,
                    child: Text(LocaleKeys.global_retry.tr()),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
