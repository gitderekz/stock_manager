import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialKey = 'tutorial_completed_v2';

  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_tutorialKey) ?? false);
  }

  static Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
  }

  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialKey);
  }
}

class TutorialOverlay {
  static Future<void> showTutorialIfNeeded(BuildContext context) async {
    if (await TutorialService.shouldShowTutorial()) {
      final navigatorKey = GlobalKey<NavigatorState>();

      final steps = [
        TutorialStep(
          title: 'Welcome to Stock Manager',
          description: 'Swipe through to learn how to use the app',
          targetKey: GlobalKey(),
        ),
        TutorialStep(
          title: 'Dashboard',
          description: 'View your key metrics and quick actions here',
          targetKey: GlobalKey(),
          targetAlignment: Alignment.bottomCenter,
        ),
        TutorialStep(
          title: 'Products Management',
          description: 'Add, edit and manage your products inventory',
          targetKey: GlobalKey(),
          targetAlignment: Alignment.bottomCenter,
        ),
        TutorialStep(
          title: 'Inventory Tracking',
          description: 'Monitor stock levels and receive low stock alerts',
          targetKey: GlobalKey(),
          targetAlignment: Alignment.bottomCenter,
        ),
      ];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TutorialCarousel(
          steps: steps,
          onComplete: () {
            TutorialService.completeTutorial();
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }
}

class TutorialCarousel extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;

  const TutorialCarousel({
    required this.steps,
    required this.onComplete,
    Key? key,
  }) : super(key: key);

  @override
  _TutorialCarouselState createState() => _TutorialCarouselState();
}

class _TutorialCarouselState extends State<TutorialCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.steps.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final step = widget.steps[index];
                  return TutorialStepWidget(
                    step: step,
                    currentIndex: index,
                    totalSteps: widget.steps.length,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  _buildPageIndicator(),
                  _currentPage < widget.steps.length - 1
                      ? TextButton(
                    onPressed: () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: const Text('Next'),
                  )
                      : TextButton(
                    onPressed: widget.onComplete,
                    child: const Text('Get Started'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.steps.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        );
      }),
    );
  }
}

class TutorialStepWidget extends StatelessWidget {
  final TutorialStep step;
  final int currentIndex;
  final int totalSteps;

  const TutorialStepWidget({
    required this.step,
    required this.currentIndex,
    required this.totalSteps,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // You can add illustrations or icons here
          Icon(
            _getStepIcon(currentIndex),
            size: 100,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.waving_hand;
      case 1:
        return Icons.dashboard;
      case 2:
        return Icons.inventory;
      case 3:
        return Icons.analytics;
      default:
        return Icons.help;
    }
  }
}

class TutorialStep {
  final String title;
  final String description;
  final GlobalKey targetKey;
  final Alignment targetAlignment;

  TutorialStep({
    required this.title,
    required this.description,
    required this.targetKey,
    this.targetAlignment = Alignment.center,
  });
}




// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class TutorialOverlay {
//   static Future<bool> shouldShowTutorial() async {
//     final prefs = await SharedPreferences.getInstance();
//     return !(prefs.getBool('tutorial_completed') ?? false);
//   }
//
//   static Future<void> showTutorialIfNeeded(BuildContext context) async {
//     if (await shouldShowTutorial()) {
//       showTutorial(context, [
//         TutorialStep(
//           title: 'Welcome to Stock Manager',
//           description: 'This app helps you track your inventory and sales.',
//           targetKey: GlobalKey(),
//         ),
//         // Add more steps as needed
//       ]);
//     }
//   }
//
//   static void showTutorial(BuildContext context, List<TutorialStep> steps) {
//     int currentStep = 0;
//     OverlayEntry? overlayEntry;
//
//     overlayEntry = OverlayEntry(
//       builder: (context) => TutorialWidget(
//         step: steps[currentStep],
//         totalSteps: steps.length,
//         currentStep: currentStep,
//         onNext: () {
//           if (currentStep < steps.length - 1) {
//             currentStep++;
//             overlayEntry?.markNeedsBuild();
//           } else {
//             overlayEntry?.remove();
//             // Save that tutorial was completed
//             SharedPreferences.getInstance().then((prefs) {
//               prefs.setBool('tutorial_completed', true);
//             });
//           }
//         },
//         onClose: () {
//           overlayEntry?.remove();
//           SharedPreferences.getInstance().then((prefs) {
//             prefs.setBool('tutorial_completed', true);
//           });
//         },
//       ),
//     );
//
//     Overlay.of(context)?.insert(overlayEntry);
//   }
// }
//
// class TutorialStep {
//   final String title;
//   final String description;
//   final GlobalKey targetKey;
//   final Alignment targetAlignment;
//
//   TutorialStep({
//     required this.title,
//     required this.description,
//     required this.targetKey,
//     this.targetAlignment = Alignment.bottomCenter,
//   });
// }
//
// class TutorialWidget extends StatelessWidget {
//   final TutorialStep step;
//   final int totalSteps;
//   final int currentStep;
//   final VoidCallback onNext;
//   final VoidCallback onClose;
//
//   const TutorialWidget({
//     required this.step,
//     required this.totalSteps,
//     required this.currentStep,
//     required this.onNext,
//     required this.onClose,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final renderBox = step.targetKey.currentContext?.findRenderObject() as RenderBox?;
//     final position = renderBox?.localToGlobal(Offset.zero);
//
//     return Stack(
//       children: [
//         GestureDetector(
//           onTap: onClose,
//           child: Container(
//             color: Colors.black.withOpacity(0.6),
//           ),
//         ),
//         if (position != null && renderBox != null)
//           Positioned(
//             left: position.dx,
//             top: position.dy,
//             child: SizedBox(
//               width: renderBox.size.width,
//               height: renderBox.size.height,
//               child: CustomPaint(
//                 painter: TutorialHighlightPainter(),
//               ),
//             ),
//           ),
//         Positioned.fill(
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             step.title,
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             step.description,
//                             style: Theme.of(context).textTheme.bodyMedium,
//                           ),
//                           const SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 '${currentStep + 1}/$totalSteps',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                               ElevatedButton(
//                                 onPressed: onNext,
//                                 child: Text(
//                                   currentStep == totalSteps - 1 ? 'Finish' : 'Next',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class TutorialHighlightPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(0.3)
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke;
//
//     final rrect = RRect.fromRectAndRadius(
//       Rect.fromLTWH(0, 0, size.width, size.height),
//       const Radius.circular(8),
//     );
//
//     canvas.drawRRect(rrect, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }