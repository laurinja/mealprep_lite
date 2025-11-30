import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class PolicyDialog extends StatefulWidget {
  final String title;
  final String content;

  const PolicyDialog({super.key, required this.title, required this.content});

  @override
  State<PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<PolicyDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _reachedEnd = false;
  double _readingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent == 0) {
        setState(() {
          _reachedEnd = true;
          _readingProgress = 1.0;
        });
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    
    setState(() {
      _readingProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    });

    if (!_reachedEnd && currentScroll >= maxScroll - 20) {
      setState(() => _reachedEnd = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _readingProgress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _reachedEnd ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: MarkdownBody(
              data: widget.content,
              onTapLink: (text, href, title) {
                if (href != null) launchUrl(Uri.parse(href));
              },
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _reachedEnd ? () => Navigator.of(context).pop(true) : null,
          child: Text(_reachedEnd ? 'Li e Concordo' : 'Role até o fim'),
        ),
      ],
    );
  }
}