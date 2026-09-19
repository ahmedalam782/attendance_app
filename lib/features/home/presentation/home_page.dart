import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/languages/locale_keys.g.dart';
import '../../auth/presentation/view/pages/auth_page.dart';
import '../data/app_bootstrap_impl.dart';
import '../domain/app_bootstrap.dart';

/// First route: initializes Firebase/DI, then shows auth.
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
      await _bootstrap.run();
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
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
    return const AuthPage();
  }
}
