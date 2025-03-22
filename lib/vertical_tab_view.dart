import 'package:flutter/material.dart';

enum IndicatorSide { start, end }

/// A vertical tab widget for flutter
class VerticalTabView extends StatefulWidget {
  final int initialIndex;
  final double tabsWidth;
  final double indicatorWidth;
  final IndicatorSide indicatorSide;

  final List<Tab> tabs;
  final List<Widget> contents;

  final TextDirection direction;
  final Color? indicatorColor;
  final bool disabledChangePageFromContentView;
  final Axis contentScrollAxis;
  final Color selectedTabBackgroundColor;
  final Color tabBackgroundColor;
  final TextStyle? selectedTabTextStyle;
  final TextStyle? tabTextStyle;
  final Duration changePageDuration;
  final Curve changePageCurve;
  final Color tabsShadowColor;
  final double tabsElevation;
  final Function(int tabIndex)? onSelect;
  final Color? backgroundColor;

  const VerticalTabView({
    super.key,
    required this.tabs,
    required this.contents,
    this.tabsWidth = 90,
    this.indicatorWidth = 3,
    this.indicatorSide = IndicatorSide.end,
    this.initialIndex = 0,
    this.direction = TextDirection.ltr,
    this.indicatorColor,
    this.disabledChangePageFromContentView = false,
    this.contentScrollAxis = Axis.vertical,
    this.selectedTabBackgroundColor = Colors.transparent,
    this.tabBackgroundColor = Colors.transparent,
    this.selectedTabTextStyle,
    this.tabTextStyle,
    this.changePageCurve = Curves.easeInOut,
    this.changePageDuration = const Duration(milliseconds: 300),
    this.tabsShadowColor = Colors.transparent,
    this.tabsElevation = 0.0,
    this.onSelect,
    this.backgroundColor,
  });

  @override
  State<VerticalTabView> createState() => _VerticalTabViewState();
}

class _VerticalTabViewState extends State<VerticalTabView>
    with TickerProviderStateMixin {
  int _selectedIndex = -1;
  late bool _changePageByTapView;

  late Animation<double> animation;
  late Animation<RelativeRect> rectAnimation;

  PageController pageController = PageController();

  List<AnimationController> animationControllers = [];

  ScrollPhysics pageScrollPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    _changePageByTapView = false;

    for (int i = 0; i < widget.tabs.length; i++) {
      animationControllers.add(
        AnimationController(duration: Durations.medium3, vsync: this),
      );
    }

    if (widget.disabledChangePageFromContentView == true) {
      pageScrollPhysics = const NeverScrollableScrollPhysics();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectTab(widget.initialIndex);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.direction,
      child: Container(
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Material(
                    type: MaterialType.transparency,
                    elevation: widget.tabsElevation,
                    shadowColor: widget.tabsShadowColor,
                    shape: const BeveledRectangleBorder(),
                    child: SizedBox(
                      width: widget.tabsWidth,
                      child: ListView.builder(
                        itemCount: widget.tabs.length,
                        itemBuilder: (context, index) {
                          Tab tab = widget.tabs[index];

                          Alignment alignment = Alignment.centerLeft;
                          if (widget.direction == TextDirection.rtl) {
                            alignment = Alignment.centerRight;
                          }

                          Widget child;
                          if (tab.child != null) {
                            child = tab.child!;
                          } else {
                            child = Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 2,
                              ),
                              child: Row(
                                children: <Widget>[
                                  (tab.icon != null)
                                      ? Row(
                                        children: <Widget>[
                                          tab.icon!,
                                          const SizedBox(width: 5),
                                        ],
                                      )
                                      : Container(),
                                  (tab.text != null)
                                      ? SizedBox(
                                        width: widget.tabsWidth - 50,
                                        child: Text(
                                          tab.text!,
                                          softWrap: true,
                                          style: _tabTextStyle(index),
                                        ),
                                      )
                                      : Container(),
                                ],
                              ),
                            );
                          }

                          final itemBGColor =
                              _selectedIndex == index
                                  ? widget.selectedTabBackgroundColor
                                  : widget.tabBackgroundColor;

                          final (left, right) = _getIndicatorPosition();

                          return Stack(
                            children: <Widget>[
                              Positioned(
                                top: 2,
                                bottom: 2,
                                width: widget.indicatorWidth,
                                left: left,
                                right: right,
                                child: ScaleTransition(
                                  scale: Tween(begin: 0.0, end: 1.0).animate(
                                    CurvedAnimation(
                                      parent: animationControllers[index],
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          widget.indicatorColor ??
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(
                                          widget.indicatorWidth,
                                        ),
                                        bottomLeft: Radius.circular(
                                          widget.indicatorWidth,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _changePageByTapView = true;
                                  setState(() {
                                    _selectTab(index);
                                  });

                                  pageController.animateToPage(
                                    index,
                                    duration: widget.changePageDuration,
                                    curve: widget.changePageCurve,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(color: itemBGColor),
                                  alignment: alignment,
                                  padding: const EdgeInsets.all(10),
                                  child: child,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: widget.contentScrollAxis,
                      physics: pageScrollPhysics,
                      onPageChanged: (index) {
                        if (_changePageByTapView == false) {
                          _selectTab(index);
                        }
                        if (_selectedIndex == index) {
                          _changePageByTapView = false;
                        }
                        setState(() {});
                      },
                      controller: pageController,
                      itemCount: widget.contents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return widget.contents[index];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(int index) {
    if (index == -1) return;

    _selectedIndex = index;
    for (AnimationController animationController in animationControllers) {
      animationController.reset();
    }
    animationControllers[index].forward();

    if (widget.onSelect != null) {
      widget.onSelect!(_selectedIndex);
    }
  }

  (double? left, double? right) _getIndicatorPosition() {
    if (widget.direction == TextDirection.rtl) {
      return (widget.indicatorSide == IndicatorSide.end)
          ? (0, null)
          : (null, 0);
    }
    return (widget.indicatorSide == IndicatorSide.start)
        ? (0, null)
        : (null, 0);
  }

  TextStyle _tabTextStyle(int index) {
    final theme = Theme.of(context);
    if (_selectedIndex == index) {
      return widget.selectedTabTextStyle ??
          theme.tabBarTheme.labelStyle ??
          theme.textTheme.bodyMedium!;
    }
    return widget.tabTextStyle ??
        theme.tabBarTheme.unselectedLabelStyle ??
        theme.textTheme.bodyMedium!.copyWith(color: theme.hintColor);
  }

  @override
  void dispose() {
    for (AnimationController animationController in animationControllers) {
      animationController.dispose();
    }
    super.dispose();
  }
}
