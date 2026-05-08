import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nearvendorapp/cubits/session/session_cubit.dart';
import 'package:nearvendorapp/gen/assets.gen.dart';
import 'package:nearvendorapp/utils/app_navigation.dart';
import 'package:nearvendorapp/views/screens/home/view/main_screen.dart';
import 'package:nearvendorapp/views/screens/onboarding/widget/onboaring_btns.dart';
import 'package:nearvendorapp/views/widgets/app_scaffold.dart';
import 'package:permission_handler/permission_handler.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: Assets.images.onboardingProximity,
      heading: 'Everything you need,\nclose to home.',
      subHeading:
          'Find local vendors easily. Skip the traffic and discover hidden gems on your street.',
      buttonText: 'Next',
    ),
    OnboardingData(
      image: Assets.images.onboardingSearch,
      heading: 'Smart AI Search.\nJust say what you need.',
      subHeading:
          'No complex keywords. From repairs to snacks, our AI finds exactly what you need.',
      buttonText: 'Next',
    ),
    OnboardingData(
      image: Assets.images.onboardingOffers,
      heading: 'Local Deals &\nExclusive Offers.',
      subHeading:
          'Discover trending sales from your favorite neighbors, tailored for your daily life.',
      buttonText: 'Get Started',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      setState(() => _currentPage++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  Future<void> _finishOnboarding() async {
    await Permission.location.request();
    if (mounted) {
      context.read<SessionCubit>().setOnboarded();
      AppNavigator.pushReplacement(context, const MainScreen());
    }
  }

  Widget _slideFadeTransition(Widget child, Animation<double> animation) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: offsetAnimation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return AppScaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if ((details.primaryVelocity ?? 0) < 0) {
            _nextPage();
          } else if ((details.primaryVelocity ?? 0) > 0) {
            _prevPage();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.scaffoldBackgroundColor,
                      theme.scaffoldBackgroundColor,
                      theme.primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.12),
                  SizedBox(
                    height: size.height * 0.40,
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: 50.ms,
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        key: ValueKey(_currentPage),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: _onboardingData[_currentPage].image
                                .provider(),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Fixed-height Text Section to anchor UI below it
                  SizedBox(
                    height: size.height * 0.25,
                    child: Column(
                      children: [
                        AnimatedSwitcher(
                          duration: 400.ms,
                          transitionBuilder: _slideFadeTransition,
                          child: Text(
                            _onboardingData[_currentPage].heading,
                            key: ValueKey('h_$_currentPage'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        AnimatedSwitcher(
                          duration: 500.ms,
                          transitionBuilder: _slideFadeTransition,
                          child: Text(
                            _onboardingData[_currentPage].subHeading,
                            key: ValueKey('s_$_currentPage'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 24,
              child: AnimatedOpacity(
                opacity: _currentPage < _onboardingData.length - 1 ? 1.0 : 0.0,
                duration: 300.ms,
                child: IgnorePointer(
                  ignoring: _currentPage >= _onboardingData.length - 1,
                  child: TextButton(
                    onPressed: () => setState(
                      () => _currentPage = _onboardingData.length - 1,
                    ),
                    child: Text(
                      'Skip',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _onboardingData.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(right: 6),
                    height: 8,
                    width: _currentPage == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              OnboardingBtns(
                    btnText: _onboardingData[_currentPage].buttonText,
                    color: theme.primaryColor,
                    textColor: Colors.white,
                    onTap: _nextPage,
                    borderRadius: BorderRadius.circular(16),
                  )
                  .animate(key: ValueKey(_currentPage))
                  .scaleY(
                    begin: 0.95,
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final AssetGenImage image;
  final String heading;
  final String subHeading;
  final String buttonText;

  OnboardingData({
    required this.image,
    required this.heading,
    required this.subHeading,
    required this.buttonText,
  });
}
