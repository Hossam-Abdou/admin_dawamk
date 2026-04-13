import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/routes_manager/routes.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo scale + fade
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;

  // Text slide-up + fade
  late final AnimationController _textController;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  // Rotating ring
  late final AnimationController _ringController;

  // Bottom tagline fade
  late final AnimationController _taglineController;
  late final Animation<double> _taglineFade;

  // Particle controllers
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    // ── Logo ──────────────────────────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      ),
    );

    // ── Text ──────────────────────────────────────────────────────
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    // ── Rotating ring ─────────────────────────────────────────────
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // ── Tagline ───────────────────────────────────────────────────
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeIn),
    );

    // ── Particles ─────────────────────────────────────────────────
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // ── Sequence ──────────────────────────────────────────────────
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _taglineController.forward();

    // Navigate after splash duration
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.adminHome);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _ringController.dispose();
    _taglineController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Gradient background ───────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1A6E), // deep navy
                  Color(0xFF1F4ED8), // primary blue
                  Color(0xFF0EA5E9), // sky blue
                  Color(0xFF06B6D4), // cyan accent
                ],
                stops: [0, 0.35, 0.7, 1],
              ),
            ),
          ),

          // ── Floating particles ───────────────────────────────────
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              return CustomPaint(
                painter: _ParticlePainter(_particleController.value),
                size: size,
              );
            },
          ),

          // ── Large blurred decorative circles ─────────────────────
          Positioned(
            top: -size.height * 0.12,
            right: -size.width * 0.2,
            child: _GlowCircle(size: size.width * 0.7, opacity: 0.12),
          ),
          Positioned(
            bottom: -size.height * 0.08,
            left: -size.width * 0.25,
            child: _GlowCircle(size: size.width * 0.8, opacity: 0.1),
          ),

          // ── Rotating dashed ring ──────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _ringController.value * 2 * math.pi,
                  child: CustomPaint(
                    painter: _DashedRingPainter(),
                    size: const Size(220, 220),
                  ),
                );
              },
            ),
          ),

          // ── Counter-rotating inner ring ───────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (_, __) {
                return Transform.rotate(
                  angle: -_ringController.value * 2 * math.pi * 0.6,
                  child: CustomPaint(
                    painter: _DashedRingPainter(radius: 100, dashCount: 8, opacity: 0.3),
                    size: const Size(200, 200),
                  ),
                );
              },
            ),
          ),

          // ── Main content ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentColor.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Image.asset(
                          'assets/images/admin_attendance_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'دوامك',
                          style: GoogleFonts.readexPro(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Attendance Management',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Loading dots
                FadeTransition(
                  opacity: _taglineFade,
                  child: _LoadingDots(),
                ),
              ],
            ),
          ),

          // ── Bottom branding ───────────────────────────────────────
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Column(
                children: [
                  Text(
                    'Track · Manage · Thrive',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading dots widget ──────────────────────────────────────────────────────
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );
    _animations = _controllers.map((c) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: c, curve: Curves.easeInOut),
      );
    }).toList();

    _startLoop();
  }

  Future<void> _startLoop() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 150));
      }
      await Future.delayed(const Duration(milliseconds: 400));
      for (final c in _controllers) {
        if (mounted) c.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3 + 0.7 * _animations[i].value),
              ),
              transform: Matrix4.translationValues(
                0,
                -6 * _animations[i].value,
                0,
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Decorative glow circle ───────────────────────────────────────────────────
class _GlowCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _GlowCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

// ── Dashed ring painter ───────────────────────────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final double radius;
  final int dashCount;
  final double opacity;

  const _DashedRingPainter({
    this.radius = 108,
    this.dashCount = 12,
    this.opacity = 0.2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final angleStep = (2 * math.pi) / dashCount;
    final dashAngle = angleStep * 0.5;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * angleStep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Floating particles painter ────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  static final List<_Particle> _particles = List.generate(
    18,
        (i) => _Particle(
      x: (i * 0.137 + 0.05) % 1.0,
      y: (i * 0.213 + 0.1) % 1.0,
      size: 2.0 + (i % 4) * 1.2,
      speed: 0.15 + (i % 5) * 0.07,
      phase: i * 0.35,
    ),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in _particles) {
      final t = (progress * p.speed + p.phase) % 1.0;
      final y = (p.y - t * 0.3) % 1.0;
      final x = p.x + math.sin(t * 2 * math.pi + p.phase) * 0.04;
      final opacity = (math.sin(t * math.pi)).clamp(0.0, 1.0) * 0.5;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}

class _Particle {
  final double x, y, size, speed, phase;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}
