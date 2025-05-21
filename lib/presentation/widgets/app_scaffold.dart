import 'package:flutter/material.dart';
import 'package:stock_manager/presentation/widgets/network_status_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showNetworkStatus;

  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.showNetworkStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
        title: Text(title!),
        actions: actions,
      )
          : null,
      body: Column(
        children: [
          if (showNetworkStatus) const NetworkStatusBar(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}