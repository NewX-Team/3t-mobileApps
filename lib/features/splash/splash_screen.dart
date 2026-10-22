import 'package:flutter/material.dart';
import 'package:layanan_masyarakat3t/features/home/home_screen.dart';
import 'package:layanan_masyarakat3t/features/splash/widgets/g_snake_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _inController;
  late final Animation<double> _inAnimation;

  late final AnimationController _outController;
  late final Animation<double> _outAnimation;
  late final Animation<Offset> _outSlideAnimation;

  // Title fade-in animation, which appears as the G is nearly complete
  late final Animation<double> _titleFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (Head moves along path from top-right to center)
    _inController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _inAnimation = CurvedAnimation(
      parent: _inController,
      curve: Curves.easeInOutCubic,
    );

    _titleFadeAnimation = CurvedAnimation(
      parent: _inController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    // 2. Exit animation (Retraces path in reverse from center outwards, un-drawing the G)
    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _outAnimation = CurvedAnimation(
      parent: _outController,
      curve: Curves.easeInOutCubic,
    );

    // Subtle downward drift during exit
    _outSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.12),
    ).animate(
      CurvedAnimation(
        parent: _outController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _inController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onEntranceCompleted();
      }
    });

    _outController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    // Start entrance animation
    _inController.forward();
  }

  void _onEntranceCompleted() async {
    // Brief hold to display the fully formed G mark and identity
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // Start reverse exit animation
    _outController.forward();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _inController.dispose();
    _outController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Solid dark slate background (strictly no gradient, no purple)
    const backgroundColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered G animation and branding
            Center(
              child: SlideTransition(
                position: _outSlideAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The G Snake / Kinetic Painter (Entrance & Reverse Exit)
                    AnimatedBuilder(
                      animation: Listenable.merge([_inAnimation, _outAnimation]),
                      builder: (context, child) {
                        final isExiting = _outController.value > 0.0;
                        return CustomPaint(
                          size: const Size(160, 160),
                          painter: GSnakePainter(
                            entranceProgress: _inAnimation.value,
                            exitProgress: _outAnimation.value,
                            isExiting: isExiting,
                            strokeColor: const Color(0xFFFFFFFF),
                            headColor: const Color(0xFFFFFFFF),
                            trackColor: const Color(0xFF1E293B),
                            strokeWidth: 12.0,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 36),

                    // Text & metadata that fades in on entrance, fades out on exit
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _titleFadeAnimation,
                        _outAnimation,
                      ]),
                      builder: (context, child) {
                        final inOpacity = _titleFadeAnimation.value;
                        final outOpacity = (1.0 - _outAnimation.value).clamp(0.0, 1.0);
                        final effectiveOpacity = (inOpacity * outOpacity).clamp(0.0, 1.0);

                        return Opacity(
                          opacity: effectiveOpacity,
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          const Text(
                            'LAYANAN MASYARAKAT 3T',
                            style: TextStyle(
                              color: Color(0xFFF8FAFC),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Sistem Pelayanan Terpadu & Tanggap Darurat',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Clean, professional civic badge (strictly no green dots!)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFF334155),
                                width: 1.0,
                              ),
                            ),
                            child: const Text(
                              'TERDEPAN • TERLUAR • TERTINGGAL',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Subtle footer metadata
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _outAnimation,
                builder: (context, child) {
                  final opacity = (1.0 - _outAnimation.value).clamp(0.0, 1.0);
                  return Opacity(opacity: opacity, child: child);
                },
                child: const Text(
                  'Kementerian & Pemerintah Daerah Wilayah 3T',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
