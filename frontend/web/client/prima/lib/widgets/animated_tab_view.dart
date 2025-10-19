import 'package:flutter/material.dart';

class AnimatedTabView extends StatefulWidget {
  final TabController controller;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const AnimatedTabView({
    Key? key,
    required this.controller,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  State<AnimatedTabView> createState() => _AnimatedTabViewState();
}

class _AnimatedTabViewState extends State<AnimatedTabView> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.index;
    _pageController = PageController(initialPage: _currentIndex);

    widget.controller.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTabChange);
    _pageController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_currentIndex != widget.controller.index) {
      _currentIndex = widget.controller.index;
      _pageController.animateToPage(
        _currentIndex,
        duration: widget.duration,
        curve: widget.curve,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.children.length,
      onPageChanged: (index) {
        if (widget.controller.index != index) {
          widget.controller.animateTo(index);
        }
      },
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: widget.controller.animation!,
            curve: widget.curve,
          )),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(index > _currentIndex ? 1.0 : -1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: widget.controller.animation!,
              curve: widget.curve,
            )),
            child: widget.children[index],
          ),
        );
      },
    );
  }
}

// Widget d'exemple d'utilisation
class AnimatedTabExample extends StatefulWidget {
  const AnimatedTabExample({Key? key}) : super(key: key);

  @override
  State<AnimatedTabExample> createState() => _AnimatedTabExampleState();
}

class _AnimatedTabExampleState extends State<AnimatedTabExample>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tab 1'),
            Tab(text: 'Tab 2'),
            Tab(text: 'Tab 3'),
          ],
        ),
        Expanded(
          child: AnimatedTabView(
            controller: _tabController,
            children: const [
              Center(child: Text('Content 1')),
              Center(child: Text('Content 2')),
              Center(child: Text('Content 3')),
            ],
          ),
        ),
      ],
    );
  }
}
