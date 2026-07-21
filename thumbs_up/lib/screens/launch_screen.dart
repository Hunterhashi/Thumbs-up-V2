import 'package:flutter/material.dart';
import 'package:thumbs_up/navigation/app_router.dart';
import 'package:thumbs_up/theme/app_theme.dart';

/// First screen shown on app start.
///
/// Sequence: logo centered → logo shifts upward → progress indicator fades
/// in → cross-fade to [HomeScreen]. See plan: "Launch sequence spec".
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _shiftDuration = Duration(milliseconds: 1200);
  static const Duration _spinnerDelay = Duration(milliseconds: 1500);
  static const Duration _navigateDelay = Duration(milliseconds: 2800);

  late final AnimationController _shiftController;
  late final Animation<Alignment> _logoAlignment;

  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();

    _shiftController = AnimationController(
      vsync: this,
      duration: _shiftDuration,
    )..forward();

    _logoAlignment = Tween<Alignment>(
      begin: Alignment.center,
      end: const Alignment(0, -0.3),
    ).animate(
      CurvedAnimation(parent: _shiftController, curve: Curves.easeOutCubic),
    );

    Future<void>.delayed(_spinnerDelay, () {
      if (!mounted) return;
      setState(() => _showSpinner = true);
    });

    Future<void>.delayed(_navigateDelay, () {
      if (!mounted) return;
      AppRouter.toHome(context);
    });
  }

  @override
  void dispose() {
    _shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppColors.brandYellow, AppColors.brandYellowTop],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _logoAlignment,
            builder: (context, _) {
              return Align(
                alignment: _logoAlignment.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoWordmark(),
                    const SizedBox(height: 28),
                    AnimatedOpacity(
                      opacity: _showSpinner ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: const CircularProgressIndicator(
                        color: AppColors.matteBlack,
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Text-only "Thumbs Up" wordmark (no background asset needed).
///
/// "Thumbs " uses the brand yellow with layered dark drop-shadows for a
/// subtle 3D feel; "Up" uses matte black.
class _LogoWordmark extends StatelessWidget {
  const _LogoWordmark();

  static const List<Shadow> _shadows = [
    Shadow(color: AppColors.matteBlack, offset: Offset(2, 3)),
    Shadow(color: AppColors.matteBlack, offset: Offset(1, 1.5)),
  ];

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        children: [
          TextSpan(
            text: 'Thumbs ',
            style: TextStyle(
              color: AppColors.brandYellow,
              shadows: _shadows,
            ),
          ),
          TextSpan(
            text: 'Up',
            style: TextStyle(color: AppColors.matteBlack),
          ),
        ],
      ),
    );
  }
}
