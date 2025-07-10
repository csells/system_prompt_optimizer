import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget formPanel;
  final Widget outputPanel;
  final double breakpoint;

  const ResponsiveLayout({
    super.key,
    required this.formPanel,
    required this.outputPanel,
    this.breakpoint = 800,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          // Desktop layout - side by side
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: formPanel,
                ),
              ),
              Container(
                width: 1,
                color: Colors.grey.shade300,
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: outputPanel,
                ),
              ),
            ],
          );
        } else {
          // Mobile layout - tabs
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Configuration'),
                    Tab(text: 'Output'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: formPanel,
                      ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: outputPanel,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}