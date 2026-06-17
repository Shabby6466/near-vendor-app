import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_data.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/widgets/app_elevated_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _pageController;
  double _pageOffset = 0.0;
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      imagePath: Assets.images.onboarding0.path,
      heading: 'Everything you need,\nclose to home.',
      subHeading:
          'Find local vendors easily. Skip the traffic and discover hidden gems on your street.',
      buttonText: 'Wah!',
    ),
    OnboardingData(
      imagePath: Assets.images.onboarding1.path,
      heading: 'Local Deals &\nExclusive Offers.',
      subHeading:
          'Discover trending sales from your favorite neighbor, tailored for your daily life.',
      buttonText: 'zabardast!',
    ),
    OnboardingData(
      imagePath: Assets.images.onboarding2.path,
      heading: 'Smart AI search.\nJust say what you need.',
      subHeading:
          'No complex keywords. From repairs to snacks, our AI finds exactly what you need.',
      buttonText: 'kamal hogya!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        setState(() {
          _pageOffset = _pageController.page ?? 0.0;
        });
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    AppData().setHasOnboarded(true);
    AppNavigator.pushReplacement(context, const MainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ParallaxBackground(
            pageController: _pageController,
            pageCount: _onboardingData.length,
            images: _onboardingData.map((d) => d.imagePath).toList(),
          ),

          ColoredBox(color: Colors.black.withValues(alpha: 0.3)),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              final isActive = _currentPage == index;

              return OnboardingPageContent(
                key: ValueKey('page_content_${index}_$isActive'),
                index: index,
                heading: data.heading,
                subHeading: data.subHeading,
                buttonText: data.buttonText,
                onButtonPressed: _nextPage,
                isActive: isActive,
              );
            },
          ),

          // 4. Logo Overlay (Shared element, scales in once on load, animates position & size between pages)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            top:
                MediaQuery.of(context).padding.top +
                (_currentPage == 1 ? 28.0 : 20.0),
            left: _currentPage == 1 ? 32.0 : 24.0,
            child: AnimatedScale(
              scale: _currentPage == 1 ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              child:
                  SvgEmbeddedImage(
                    assetPath: Assets
                        .icons
                        .appIcon
                        .path, // Uses build_runner generated asset path
                    width: 60,
                    height: 60,
                  ).animate().scale(
                    begin: Offset.zero,
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  ),
            ),
          ),

          // 5. Progress Bar Overlay
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: ProgressBarIndicator(
                pageOffset: _pageOffset,
                pageCount: _onboardingData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String imagePath;
  final String heading;
  final String subHeading;
  final String buttonText;

  OnboardingData({
    required this.imagePath,
    required this.heading,
    required this.subHeading,
    required this.buttonText,
  });
}

class OnboardingPageContent extends StatelessWidget {
  final int index;
  final String heading;
  final String subHeading;
  final String buttonText;
  final VoidCallback onButtonPressed;
  final bool isActive;

  const OnboardingPageContent({
    super.key,
    required this.index,
    required this.heading,
    required this.subHeading,
    required this.buttonText,
    required this.onButtonPressed,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    // Page 0 waits for the initial logo spring animation (800ms) to complete before building foreground
    final delayOffset = index == 0 ? 800.ms : 0.ms;

    Widget button = _buildCTAButton(
      context: context,
      text: buttonText,
      onPressed: onButtonPressed,
    );

    if (isActive) {
      button = button
          .animate(delay: 600.ms + delayOffset)
          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
          .slideY(
            begin: 0.15,
            end: 0,
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          )
          .then(delay: 200.ms)
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    } else {
      button = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Headline
          if (isActive)
            SizedBox(
              height: 90,
              child: index == 2
                  ? TypewriterText(
                      text: heading,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                      delay: 1000.ms + delayOffset,
                    )
                  : Text(
                          heading,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        )
                        .animate(delay: delayOffset)
                        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                        .slideY(
                          begin: 0.15,
                          end: 0,
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
            )
          else
            const SizedBox(height: 90),

          const SizedBox(height: 16),

          // Description
          if (isActive)
            SizedBox(
              height: 75,
              child:
                  Text(
                        subHeading,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                        ),
                      )
                      .animate(delay: 300.ms + delayOffset)
                      .fadeIn(duration: 500.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ),
            )
          else
            const SizedBox(height: 75),

          const SizedBox(height: 48),

          // Button
          Align(
            child: SizedBox(height: 60, child: Center(child: button)),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCTAButton({
    required BuildContext context,
    required String text,
    required VoidCallback onPressed,
  }) {
    final Color buttonColor = Theme.of(context).colorScheme.secondary;
    // Uses AppElevatedButton from widgets with custom theme override to match styling and animations
    return Theme(
      data: Theme.of(context).copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 14),
          ),
        ),
      ),
      child: AppElevatedButton(
        onPressed: onPressed,
        text: text,
        color: buttonColor,
      ),
    );
  }
}

class ParallaxBackground extends StatelessWidget {
  final PageController pageController;
  final int pageCount;
  final List<String> images;

  const ParallaxBackground({
    super.key,
    required this.pageController,
    required this.pageCount,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double pageOffset = 0.0;
        if (pageController.hasClients) {
          pageOffset = pageController.page ?? 0.0;
        }

        return Stack(
          fit: StackFit.expand,
          children: List.generate(pageCount, (index) {
            final double translation = (index - pageOffset) * size.width * 0.3;
            final double opacity = (1.0 - (index - pageOffset).abs()).clamp(
              0.0,
              1.0,
            );
            final bool isVisible = opacity > 0.01;

            return Positioned.fill(
              left: translation,
              right: -translation,
              child: Opacity(
                opacity: opacity,
                child: KenBurnsBackground(
                  imagePath: images[index],
                  startScale: index == 0 ? 1.0 : (index == 1 ? 1.15 : 1.05),
                  endScale: index == 0 ? 1.15 : (index == 1 ? 1.0 : 1.25),
                  startAlignment: index == 0
                      ? Alignment.bottomLeft
                      : (index == 1
                            ? Alignment.topRight
                            : Alignment.bottomRight),
                  endAlignment: index == 0
                      ? Alignment.topRight
                      : (index == 1 ? Alignment.bottomLeft : Alignment.topLeft),
                  duration: index == 0
                      ? const Duration(seconds: 15)
                      : (index == 1
                            ? const Duration(seconds: 18)
                            : const Duration(seconds: 22)),
                  animate: isVisible,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class KenBurnsBackground extends StatefulWidget {
  final String imagePath;
  final double startScale;
  final double endScale;
  final Alignment startAlignment;
  final Alignment endAlignment;
  final Duration duration;
  final bool animate;

  const KenBurnsBackground({
    super.key,
    required this.imagePath,
    required this.startScale,
    required this.endScale,
    required this.startAlignment,
    required this.endAlignment,
    required this.duration,
    required this.animate,
  });

  @override
  State<KenBurnsBackground> createState() => _KenBurnsBackgroundState();
}

class _KenBurnsBackgroundState extends State<KenBurnsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
      begin: widget.startScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _alignmentAnimation = AlignmentTween(
      begin: widget.startAlignment,
      end: widget.endAlignment,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant KenBurnsBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: _alignmentAnimation.value,
          child: Image.asset(
            widget.imagePath,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      },
    );
  }
}

class ProgressBarIndicator extends StatelessWidget {
  final double pageOffset;
  final int pageCount;

  const ProgressBarIndicator({
    super.key,
    required this.pageOffset,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeColor = Theme.of(context).colorScheme.secondary;
    final Color inactiveColor = Colors.white.withValues(alpha: 0.25);
    const double barWidth = 140.0;
    const double barHeight = 4.0;

    final double fillRatio = (pageOffset + 1.0) / pageCount;

    return Container(
      width: barWidth,
      height: barHeight,
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fillRatio.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration delay;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.delay = const Duration(milliseconds: 1000),
    this.speed = const Duration(milliseconds: 40),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorController;
  int _currentCharCount = 0;
  Timer? _typingTimer;
  Timer? _startTimer;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _cursorController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addListener(() {
          setState(() {
            _showCursor = _cursorController.value < 0.5;
          });
        });
    _cursorController.repeat();

    _startTimer = Timer(widget.delay, _startTyping);
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.speed, (timer) {
      if (_currentCharCount < widget.text.length) {
        setState(() {
          _currentCharCount++;
        });
      } else {
        _typingTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cursorController.dispose();
    _typingTimer?.cancel();
    _startTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedText = widget.text.substring(0, _currentCharCount);
    return RichText(
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: displayedText),
          TextSpan(
            text: '|',
            style: widget.style?.copyWith(
              color: _showCursor ? const Color(0xFFBCFF5E) : Colors.transparent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class SvgEmbeddedImage extends StatefulWidget {
  final String assetPath;
  final double width;
  final double height;

  const SvgEmbeddedImage({
    super.key,
    required this.assetPath,
    required this.width,
    required this.height,
  });

  @override
  State<SvgEmbeddedImage> createState() => _SvgEmbeddedImageState();
}

class _SvgEmbeddedImageState extends State<SvgEmbeddedImage> {
  Uint8List? _bytes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSvgImage();
  }

  Future<void> _loadSvgImage() async {
    try {
      final svgString = await DefaultAssetBundle.of(
        context,
      ).loadString(widget.assetPath);
      final match = RegExp(
        'data:image/png;base64,([^"]+)',
      ).firstMatch(svgString);
      if (match != null) {
        final base64Str = match.group(1)!;
        final cleanBase64 = base64Str.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);
        if (mounted) {
          setState(() {
            _bytes = bytes;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(
          _bytes!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_hasError) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.asset(
          'assets/app_icons/nearvendor.png',
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    }

    return SizedBox(width: widget.width, height: widget.height);
  }
}
