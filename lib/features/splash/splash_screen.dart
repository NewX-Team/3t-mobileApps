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
  late final Animation<Offset> _outSlideAnimation;
  late final Animation<double> _outFadeAnimation;

  // Title fade-in animation, which appears as the G is nearly complete
  late final Animation<double> _titleFadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (Snake slithers to form the letter G)
    _inController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    );

    _inAnimation = CurvedAnimation(
      parent: _inController,
      curve: Curves.easeInOutCubic,
    );

    _titleFadeAnimation = CurvedAnimation(
      parent: _inController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    // 2. Exit animation (The letter G slides downward and fades away)
    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _outSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.45),
    ).animate(
      CurvedAnimation(
        parent: _outController,
        curve: Curves.easeInCubic,
      ),
    );

    _outFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _outController,
        curve: Curves.easeInCubic,
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
    // Brief pause to display the completed G icon and title
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    // Start downward exit animation
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
        transitionDuration: const Duration(milliseconds: 400),
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
                child: FadeTransition(
                  opacity: _outFadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // The G Snake Custom Painter
                      AnimatedBuilder(
                        animation: _inAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(160, 160),
                            painter: GSnakePainter(
                              progress: _inAnimation.value,
                              strokeColor: const Color(0xFFFFFFFF),
                              snakeColor: const Color(0xFF10B981),
                              trackColor: const Color(0xFF1E293B),
                              strokeWidth: 12.0,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 36),

                      // Text info that fades in as the G finishes forming
                      AnimatedBuilder(
                        animation: _titleFadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _titleFadeAnimation.value,
                            child: child,
                          );
                        },
                        child: Column(
                          children: [
                            const Text(
                              'LAYANAN MASYARAKAT 3T',
                              style: TextStyle(
                                color: Color(0xFFF8FAFC),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sistem Informasi & Pelayanan Publik Mandiri',
                              style: TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Civic offline indicator pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF334155),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF10B981),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Siap Beroperasi Tanpa Sinyal',
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer info
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _outFadeAnimation,
                child: const Text(
                  'Aplikasi Layanan Wilayah Terdepan, Terluar, Tertinggal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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
