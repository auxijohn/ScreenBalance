import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Each flash problem statement: bold part + normal part
class _FlashStatement {
  final String boldText;
  final String normalText;
  final Color accentColor;
  final IconData icon;
  final String sourceTitle;
  final String sourceDetails;

  const _FlashStatement({
    required this.boldText,
    required this.normalText,
    required this.accentColor,
    required this.icon,
    required this.sourceTitle,
    required this.sourceDetails,
  });
}

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onStart;
  const WelcomeScreen({super.key, required this.onStart});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // --- Flash Statements (5 problems) ---
  final List<_FlashStatement> _statements = const [
    _FlashStatement(
      boldText: 'People pick up their phone without any reason',
      normalText: '— and when asked why, they genuinely cannot answer.',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.psychology_alt_rounded,
      sourceTitle: 'Computers in Human Behavior (2018)',
      sourceDetails: 'Habitual smartphone usage research shows that 40% of smartphone pick-ups are automatic, subconscious actions triggered by dopamine habit loops rather than conscious intent.',
    ),
    _FlashStatement(
      boldText: 'People swear they use their phone "maybe 2–3 hours"',
      normalText: '— but their screen data says almost double that.',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.access_time_rounded,
      sourceTitle: 'Journal of Association for Consumer Research (2017)',
      sourceDetails: 'A study on self-reported vs. objective screen time found that users underestimate their actual phone usage by an average of 47%, genuinely believing they spend half the time they actually do.',
    ),
    _FlashStatement(
      boldText: 'People scroll in bed thinking it helps them relax',
      normalText: '— but it suppresses their melatonin by 58%, keeping the brain awake.',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.nights_stay_rounded,
      sourceTitle: 'Harvard Medical School / Endocrine Society (2015)',
      sourceDetails: 'Exposure to blue light from screens within 2 hours of bedtime suppresses melatonin levels by 58%, shifting circadian rhythms by up to 1.5 hours and keeping the brain in an active state.',
    ),
    _FlashStatement(
      boldText: 'People jump between apps believing they are productive',
      normalText: '— while each switch costs them 23 minutes of lost deep focus.',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.swap_horiz_rounded,
      sourceTitle: 'University of California, Irvine (2016)',
      sourceDetails: 'Dr. Gloria Mark\'s research on digital distraction shows it takes an average of 23 minutes and 15 seconds to return to deep focus after switching apps or answering a notification.',
    ),
    _FlashStatement(
      boldText: 'People feel anxious and don\'t know why',
      normalText: '— their phone has been triggering a dopamine spike-crash cycle all day long.',
      accentColor: Color(0xFF42A5F5),
      icon: Icons.favorite_rounded,
      sourceTitle: 'Neuroscience & Biobehavioral Reviews (2019)',
      sourceDetails: 'The intermittent reward schedule of smartphone notifications triggers rapid dopamine spikes followed by crashes, causing elevated baseline cortisol (stress hormone) and chronic anxiety.',
    ),
  ];

  int _currentIndex = 0;
  bool _showFlash = false;   // white flash overlay visible
  bool _showText = false;    // statement text visible
  bool _showPhone = false;   // phone illustration visible
  bool _isResearchOpen = false; // whether research paper sheet is open

  late AnimationController _phoneFloatController;
  late Animation<double> _phoneFloatAnim;
  late AnimationController _flashController;
  late Animation<double> _flashAnim;
  late AnimationController _textController;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnim;
  bool _showFinalQuote = false;

  Timer? _autoAdvanceTimer;

  @override
  void initState() {
    super.initState();

    // Phone shadow/glow pulsing animation (resting on table)
    final bool isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    _phoneFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!isTesting) {
      _phoneFloatController.repeat(reverse: true);
    } else {
      _phoneFloatController.value = 0.5;
    }
    _phoneFloatAnim = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(parent: _phoneFloatController, curve: Curves.easeInOut),
    );

    // Flash controller
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flashAnim = CurvedAnimation(parent: _flashController, curve: Curves.easeOut);

    // Text fade+slide controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFadeAnim = CurvedAnimation(parent: _textController, curve: Curves.easeOut);
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    // Rotation controller
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _rotationAnim = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOutCubic),
    );

    if (!isTesting) {
      _startSequence();
    } else {
      _showPhone = true;
      _showText = true;
      _textController.value = 1.0;
    }
  }

  void _startSequence() async {
    // Initial delay — let user see the phone
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showPhone = true);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _triggerFlash();
  }

  void _resetAutoAdvanceTimer() {
    _autoAdvanceTimer?.cancel();
    final bool isTesting = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!_isResearchOpen && mounted && !isTesting) {
      _autoAdvanceTimer = Timer(const Duration(milliseconds: 4000), () {
        if (!mounted) return;
        _nextStatement();
      });
    }
  }

  void _triggerFlash() async {
    if (!mounted) return;

    // 1. Reset text, lock screen
    setState(() {
      _showFlash = false;
      _showText = false;
    });

    // 2. Short delay before flash
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // 3. Trigger Flash
    setState(() {
      _showFlash = true;
    });
    _flashController.forward(from: 0);

    // Wait for flash peak (220ms)
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    // 4. Reveal screen content and fade in statement text
    _flashController.reverse();
    setState(() {
      _showFlash = false;
      _showText = true;
    });
    _textController.forward(from: 0);

    // 5. Start auto advance timer (4000ms)
    _resetAutoAdvanceTimer();
  }

  void _enterFinalQuote() {
    _autoAdvanceTimer?.cancel();
    _textController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _showFinalQuote = true;
      });
      _rotationController.forward(from: 0.0);
      _textController.forward(from: 0);
    });
  }

  void _exitFinalQuote() {
    _textController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _showFinalQuote = false;
        _currentIndex = _statements.length - 1;
      });
      _rotationController.reverse(from: 1.0);
      _triggerFlash();
    });
  }

  void _nextStatement() {
    if (!mounted) return;
    _autoAdvanceTimer?.cancel();

    if (_showFinalQuote) return;

    if (_currentIndex < _statements.length - 1) {
      _textController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex++;
        });
        _triggerFlash();
      });
    } else {
      _enterFinalQuote();
    }
  }

  void _prevStatement() {
    if (!mounted) return;
    _autoAdvanceTimer?.cancel();

    if (_showFinalQuote) {
      _exitFinalQuote();
      return;
    }

    if (_currentIndex > 0) {
      _textController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex--;
        });
        _triggerFlash();
      });
    }
  }

  @override
  void dispose() {
    _phoneFloatController.dispose();
    _flashController.dispose();
    _textController.dispose();
    _rotationController.dispose();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  Widget _buildCenterPhone(Color accentColor) {
    return Container(
      width: 90,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Phone screen content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF070B14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    // Status bar time / battery (makes it look premium)
                    Positioned(
                      top: 6,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '09:41',
                            style: TextStyle(
                              fontSize: 7,
                              color: Colors.white.withOpacity(0.4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.battery_std_rounded,
                            size: 8,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),

                    // Main screen content (Mock feed, unlocked Statement Icon, or Psychological Radar)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18, bottom: 8),
                        child: _showFinalQuote
                            ? Center(
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween<double>(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 800),
                                  builder: (context, val, child) {
                                    return Opacity(
                                      opacity: val,
                                      child: Transform.scale(
                                        scale: val,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            AnimatedBuilder(
                                              animation: _phoneFloatController,
                                              builder: (context, child) {
                                                return Transform.rotate(
                                                  angle: _phoneFloatController.value * 2 * pi,
                                                  child: Icon(
                                                    Icons.adjust_rounded,
                                                    color: Colors.cyanAccent.withOpacity(0.3),
                                                    size: 44,
                                                  ),
                                                );
                                              },
                                            ),
                                            const Icon(
                                              Icons.psychology_rounded,
                                              color: Colors.cyanAccent,
                                              size: 26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : AnimatedCrossFade(
                                duration: const Duration(milliseconds: 400),
                                crossFadeState: _showText
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                // Unlocked state: Statement Icon
                                firstChild: Center(
                                  child: AnimatedScale(
                                    scale: _showText ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.elasticOut,
                                    child: Icon(
                                      _statements[_currentIndex].icon,
                                      color: accentColor,
                                      size: 32,
                                    ),
                                  ),
                                ),
                                // Locked state: Mock Feed
                                secondChild: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(3, (index) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 6),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.04),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            // Mock Avatar
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: accentColor.withOpacity(0.18),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            // Mock Text Lines
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    height: 3,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Container(
                                                    height: 3,
                                                    width: 20,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(2),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Phone screen FLASH overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _flashAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: _showFlash ? _flashAnim.value : 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.95),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Camera notch details
          Positioned(
            top: 6,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 28,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatement(_FlashStatement statement) {
    return SlideTransition(
      position: _textSlideAnim,
      child: FadeTransition(
        opacity: _textFadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: statement.boldText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: statement.accentColor,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                    TextSpan(
                      text: ' ${statement.normalText}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _showResearchSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: statement.accentColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statement.accentColor.withOpacity(0.24),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 14,
                        color: statement.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'View Research Source',
                        style: TextStyle(
                          fontSize: 12,
                          color: statement.accentColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinalStatement() {
    return SlideTransition(
      position: _textSlideAnim,
      child: FadeTransition(
        opacity: _textFadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'ScreenBalance ',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.cyanAccent,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: "doesn't just block apps — it ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: 'systematically targets ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.cyanAccent,
                        height: 1.4,
                      ),
                    ),
                    TextSpan(
                      text: 'every psychological mechanism that keeps users trapped in unconscious digital habits.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _showAppDetails(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.24)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: Colors.cyanAccent, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'More Details about the App',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_statements.length + 1, (index) {
        final isActive = _showFinalQuote ? (index == _statements.length) : (index == _currentIndex);
        return GestureDetector(
          onTap: () {
            if (_showFinalQuote) {
              if (index < _statements.length) {
                _exitFinalQuote();
              }
              return;
            }
            if (index == _statements.length) {
              _enterFinalQuote();
            } else if (index < _currentIndex) {
              _prevStatement();
            } else if (index > _currentIndex) {
              _nextStatement();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            height: 8,
            width: isActive ? 28 : 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: isActive
                  ? (_showFinalQuote ? Colors.cyanAccent : _statements[_currentIndex].accentColor)
                  : Colors.white24,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: (_showFinalQuote ? Colors.cyanAccent : _statements[_currentIndex].accentColor).withOpacity(0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statement = _statements[_currentIndex];
    final screenHeight = MediaQuery.of(context).size.height;
    final themeColor = _showFinalQuote ? Colors.cyanAccent : statement.accentColor;

    return Scaffold(
      backgroundColor: const Color(0xFF07101F),
      body: Stack(
        children: [
          // 1. Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF07101F),
                  Color(0xFF0A192F),
                  Color(0xFF0D1E3A),
                ],
              ),
            ),
          ),

          // Ambient glow top-right
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withOpacity(0.06),
              ),
            ),
          ),

          // Ambient glow bottom-left
          Positioned(
            bottom: -60,
            left: -60,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor.withOpacity(0.04),
              ),
            ),
          ),

          // 2. Holographic Projection Canvas (Positioned.fill to allow full-screen beams)
          Positioned.fill(
            child: Stack(
              children: [
                // Projection light beam and ambient glows stretching to top of screen
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _textFadeAnim,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ProjectionPainter(
                          projectionProgress: _textFadeAnim.value,
                          breathProgress: _phoneFloatAnim.value,
                          accentColor: themeColor,
                          screenHeight: screenHeight,
                        ),
                      );
                    },
                  ),
                ),
                
                // The Center Phone Widget with 3D Rotation
                Positioned(
                  bottom: 100,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _showPhone ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 700),
                      child: AnimatedBuilder(
                        animation: _rotationAnim,
                        builder: (context, child) {
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001) // perspective
                              ..rotateY(_rotationAnim.value),
                            alignment: Alignment.center,
                            child: _buildCenterPhone(themeColor),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Main content column (top 70% of screen)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.41,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // App name & Skip button (outside of the GestureDetector)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 65), // Left placeholder
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.spa_rounded, color: Colors.blue[300], size: 22),
                            const SizedBox(width: 8),
                            const Text(
                              'ScreenBalance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        _showFinalQuote
                            ? const SizedBox(width: 65)
                            : SizedBox(
                                width: 65,
                                child: TextButton(
                                  onPressed: _enterFinalQuote,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(color: Colors.white.withOpacity(0.15)),
                                    ),
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Interactive area
                  Expanded(
                    child: GestureDetector(
                      onTap: _showFinalQuote ? null : _nextStatement,
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity == null) return;
                        if (details.primaryVelocity! < 0) {
                          _nextStatement();
                        } else if (details.primaryVelocity! > 0) {
                          _prevStatement();
                        }
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Column(
                        children: [
                          // "Tap anywhere to continue" hint
                          Opacity(
                            opacity: _showFinalQuote ? 0.0 : 1.0,
                            child: Text(
                              'Tap anywhere to continue',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.3),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Statement text
                          SizedBox(
                            height: 180,
                            child: AnimatedOpacity(
                              opacity: _showText ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: _showText
                                  ? (_showFinalQuote ? _buildFinalStatement() : _buildStatement(statement))
                                  : const SizedBox.shrink(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Dot indicators
                          _buildDots(),

                          const Spacer(),

                          // CTA Button (appears only on final quote screen)
                          AnimatedOpacity(
                            opacity: _showFinalQuote ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 600),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _showFinalQuote ? widget.onStart : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: themeColor,
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        elevation: 10,
                                        shadowColor: themeColor.withOpacity(0.4),
                                      ),
                                      child: const Text(
                                        'Unlock Screen Balance →',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.black87,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. WHITE FLASH OVERLAY (pronounced flash effect covering the whole room/screen)
          if (_showFlash)
            FadeTransition(
              opacity: _flashAnim,
              child: Container(
                color: Colors.white.withOpacity(0.24),
              ),
            ),
        ],
      ),
    );
  }

  void _showResearchSheet() {
    setState(() {
      _isResearchOpen = true;
    });
    _autoAdvanceTimer?.cancel(); // Pause auto advance

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final statement = _statements[_currentIndex];
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0F172A), Color(0xFF070B14)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statement.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.science_outlined, color: statement.accentColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Research Confirmation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statement.sourceTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: statement.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Text(
                  statement.sourceDetails,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statement.accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Acknowledge Study',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ).then((_) {
      if (mounted) {
        setState(() {
          _isResearchOpen = false;
        });
        _resetAutoAdvanceTimer(); // Resume auto advance
      }
    });
  }

  void _showAppDetails(BuildContext context) {
    Widget buildDetailPoint(IconData icon, String title, String description) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.cyanAccent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.3)),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13.5, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.cyanAccent.withOpacity(0.2), width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_mosaic_rounded, color: Colors.cyanAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text('The Architecture of Focus', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Willpower is a finite resource. ScreenBalance doesn't just block apps; it intelligently intercepts the subconscious habit loops that drain your time.",
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 24),
                buildDetailPoint(
                  Icons.psychology_rounded,
                  "Subconscious Telemetry",
                  "Silently maps your unique behavioral patterns—detecting phantom unlocks, doom-scrolling, and cognitive overload—keeping all data strictly on your device.",
                ),
                buildDetailPoint(
                  Icons.self_improvement_rounded,
                  "Somatic Interventions",
                  "Shatters digital hypnosis. When compulsive behaviors spike, an un-dismissable reset gently grounds your nervous system, returning you to absolute conscious control.",
                ),
                buildDetailPoint(
                  Icons.nights_stay_rounded,
                  "Circadian Sunset Protocol",
                  "Respects your biology. As evening approaches, stimulating apps dynamically fade out and lock down, effortlessly guiding your brain toward deep, restorative sleep.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}

class _ProjectionPainter extends CustomPainter {
  final double projectionProgress;
  final double breathProgress;
  final Color accentColor;
  final double screenHeight;

  _ProjectionPainter({
    required this.projectionProgress,
    required this.breathProgress,
    required this.accentColor,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    
    // The phone is at bottom: 100. Height of phone is 160.
    // So the top of the phone is at y = size.height - 260.
    final phoneTopY = size.height - 260;

    // 1. Ambient radial glow behind the phone
    // The center of the phone is at y = size.height - 180 (100 bottom + 80 half height)
    final phoneCenterY = size.height - 180;
    
    final paintAmbient = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withOpacity(0.15 * projectionProgress),
          accentColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, phoneCenterY),
        radius: 120 + 15 * breathProgress,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, phoneCenterY), 130 + 15 * breathProgress, paintAmbient);

    // 2. Holographic fanning light beam fanning upwards from top of phone to top of screen (y = 0)
    if (projectionProgress > 0) {
      final paintProjection = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            accentColor.withOpacity(0.24 * projectionProgress),
            accentColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(0, 0, size.width, phoneTopY))
        ..style = PaintingStyle.fill;

      // The beam starts at top of phone (width 70, from -35 to +35)
      // and fans out to cover the entire width of the screen at the top (y = 0)
      final projectionPath = Path()
        ..moveTo(centerX - 35, phoneTopY)
        ..lineTo(centerX + 35, phoneTopY)
        ..lineTo(size.width, 0)
        ..lineTo(0, 0)
        ..close();

      canvas.drawPath(projectionPath, paintProjection);

      // Fine holographic laser scanner lines / rays inside the cone
      final paintRay = Paint()
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      final double progressOffset = sin(breathProgress * pi) * 30;
      final rays = [
        {
          'startX': centerX - 20.0,
          'endX': size.width * 0.15 + progressOffset,
          'opacity': 0.10 * projectionProgress,
        },
        {
          'startX': centerX - 5.0,
          'endX': size.width * 0.40 - progressOffset * 0.5,
          'opacity': 0.15 * projectionProgress,
        },
        {
          'startX': centerX + 5.0,
          'endX': size.width * 0.60 + progressOffset * 0.5,
          'opacity': 0.15 * projectionProgress,
        },
        {
          'startX': centerX + 20.0,
          'endX': size.width * 0.85 - progressOffset,
          'opacity': 0.10 * projectionProgress,
        },
      ];

      for (var ray in rays) {
        paintRay.shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            accentColor.withOpacity(ray['opacity'] as double),
            accentColor.withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTRB(0, 0, size.width, phoneTopY));

        final rayPath = Path()
          ..moveTo(ray['startX'] as double, phoneTopY)
          ..lineTo(ray['endX'] as double, 0);

        canvas.drawPath(rayPath, paintRay);
      }

      // 3. Emitter glow line at the top of the phone screen
      final paintEmitter = Paint()
        ..color = accentColor.withOpacity(0.45 * projectionProgress)
        ..strokeWidth = 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(centerX - 35, phoneTopY), Offset(centerX + 35, phoneTopY), paintEmitter);
    }
  }

  @override
  bool shouldRepaint(covariant _ProjectionPainter oldDelegate) {
    return oldDelegate.projectionProgress != projectionProgress ||
        oldDelegate.breathProgress != breathProgress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.screenHeight != screenHeight;
  }
}
