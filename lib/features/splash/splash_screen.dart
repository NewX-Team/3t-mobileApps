import 'package:flutter/material.dart';
import 'package:layanan_masyarakat3t/features/home/home_screen.dart';
import 'package:layanan_masyarakat3t/features/splash/widgets/g_snake_painter.dart';
import 'package:layanan_masyarakat3t/features/splash/widgets/typewriter_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const String _fullTitle = 'LAYANAN MASYARAKAT 3T';
  static const String _fullSubtitle =
      'Sistem Pelayanan Terpadu & Tanggap Darurat';

  late final AnimationController _inController;
  late final Animation<double> _inAnimation;

  late final AnimationController _outController;
  late final Animation<double> _outAnimation;
  late final Animation<Offset> _outSlideAnimation;

  late final AnimationController _cursorBlinkController;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (G forms & text types in)
    _inController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );

    _inAnimation = CurvedAnimation(
      parent: _inController,
      curve: Curves.easeInOutCubic,
    );

    // 2. Exit animation (G un-draws in reverse & text backspaces out)
    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _outAnimation = CurvedAnimation(
      parent: _outController,
      curve: Curves.easeInOutCubic,
    );

    _outSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.10),
    ).animate(
      CurvedAnimation(
        parent: _outController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 3. Cursor blinking animation during the resting / hold phase
    _cursorBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..repeat(reverse: true);

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
    // Brief hold so the user can clearly read the fully typed text
    await Future.delayed(const Duration(milliseconds: 700));
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
    _cursorBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
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
                    const SizedBox(height: 32),

                    // Typewriter Section (Types in on entrance, backspaces on exit)
                    AnimatedBuilder(
                      animation: Listenable.merge([
                        _inAnimation,
                        _outAnimation,
                        _cursorBlinkController,
                      ]),
                      builder: (context, child) {
                        final inVal = _inAnimation.value;
                        final outVal = _outAnimation.value;
                        final isExiting = outVal > 0.0;

                        double titleProgress = 0.0;
                        double subtitleProgress = 0.0;
                        double badgeOpacity = 0.0;

                        bool showTitleCursor = false;
                        bool showSubtitleCursor = false;

                        if (!isExiting) {
                          // --- ENTRANCE (Type in) ---
                          // Title types in from 30% to 75% of entrance duration
                          titleProgress = ((inVal - 0.30) / 0.45).clamp(0.0, 1.0);
                          // Subtitle types in from 65% to 95% of entrance duration
                          subtitleProgress =
                              ((inVal - 0.65) / 0.30).clamp(0.0, 1.0);
                          // Badge fades in at 90% to 100%
                          badgeOpacity = ((inVal - 0.90) / 0.10).clamp(0.0, 1.0);

                          if (titleProgress > 0.0 && titleProgress < 1.0) {
                            showTitleCursor = true;
                          } else if (subtitleProgress > 0.0 &&
                              subtitleProgress < 1.0) {
                            showSubtitleCursor = true;
                          } else if (inVal >= 1.0) {
                            // During resting hold, cursor gently blinks on subtitle
                            showSubtitleCursor = true;
                          }
                        } else {
                          // --- EXIT (Backspacing character-by-character) ---
                          // Badge fades out immediately (0.0 to 0.15)
                          badgeOpacity = (1.0 - (outVal / 0.15)).clamp(0.0, 1.0);

                          // Subtitle backspaces from 0.05 to 0.48
                          subtitleProgress =
                              (1.0 - ((outVal - 0.05) / 0.43)).clamp(0.0, 1.0);

                          // Title backspaces from 0.45 to 0.90
                          titleProgress =
                              (1.0 - ((outVal - 0.45) / 0.45)).clamp(0.0, 1.0);

                          if (subtitleProgress > 0.0) {
                            showSubtitleCursor = true;
                          } else if (titleProgress > 0.0) {
                            showTitleCursor = true;
                          }
                        }

                        // Cursor visibility: solid while typing/deleting, blinks during hold
                        final bool isBlinkingPhase = inVal >= 1.0 && !isExiting;
                        final bool cursorVisible = isBlinkingPhase
                            ? _cursorBlinkController.value > 0.5
                            : true;

                        return Column(
                          children: [
                            // 1. Main Title with typewriter effect
                            TypewriterText(
                              text: _fullTitle,
                              progress: titleProgress,
                              containerHeight: 28,
                              style: const TextStyle(
                                color: Color(0xFFF8FAFC),
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.5,
                              ),
                              showCursor: showTitleCursor,
                              cursorColor: const Color(0xFFF8FAFC),
                              cursorHeight: 18,
                              cursorVisible: cursorVisible,
                            ),
                            const SizedBox(height: 6),

                            // 2. Subtitle with typewriter effect
                            TypewriterText(
                              text: _fullSubtitle,
                              progress: subtitleProgress,
                              containerHeight: 20,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.3,
                              ),
                              showCursor: showSubtitleCursor,
                              cursorColor: const Color(0xFF94A3B8),
                              cursorHeight: 13,
                              cursorVisible: cursorVisible,
                            ),
                            const SizedBox(height: 20),

                            // 3. Civic badge (no green dots)
                            Opacity(
                              opacity: badgeOpacity,
                              child: Container(
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
                            ),
                          ],
                        );
                      },
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.copyright,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Hak Milik & Dilisensikan kepada Noxei Indonesia Branch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
