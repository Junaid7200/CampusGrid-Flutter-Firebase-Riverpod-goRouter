import 'package:campus_grid/src/shared/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

// 1. We keep your data list here
final List<Map<String, String>> getStartedTexts = [
  {
    "title": "Share Notes",
    "desc": "Upload and share your study materials with fellow students",
  },
  {
    "title": "Search Resources",
    "desc": "Find exactly what you need for your upcoming exams",
  },
  {
    "title": "Collaborate",
    "desc": "Connect with peers and study together effectively",
  },
];

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    const String getStartedIcon = 'assets/images/startup/Share_Icon.svg';
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const Spacer(flex: 2),
          Container(
            width: 340,
            height: 220,
            decoration: BoxDecoration(
              color: colors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: SvgPicture.asset(getStartedIcon, width: 130, height: 130),
            ),
          ),
          const Spacer(flex: 2),

          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.primary.withAlpha(20),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(30),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (value) {
                          setState(() {
                            _currentPage = value;
                          });
                        },
                        itemCount: getStartedTexts.length,
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                getStartedTexts[index]['title']!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                getStartedTexts[index]['desc']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        getStartedTexts.length,
                        (index) => buildDot(index, colors.primary),
                      ),
                    ),

                    const SizedBox(height: 40),
                    CustomButton(
                      text: _currentPage == 0 ? "Get Started" : _currentPage == 2 ? "Sign Up" : "Next",
                      trailingIcon: _currentPage == 0 ? Icons.chevron_right : null,
                      onPressed: () {
                        if(_currentPage < getStartedTexts.length - 1) {
                          _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        } else {
                          context.push('/signup');
                        }
                      }
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      // the pill is 32 width and dot is 8, both got the smae height though
      width: _currentPage == index ? 32 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? color : color.withAlpha(50),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
