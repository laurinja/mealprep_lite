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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && 
          _scrollController.position.maxScrollExtent == 0) {
        setState(() => _reachedEnd = true);
      }
    });
  }

  void _onScroll() {
    if (!_reachedEnd &&
        _scrollController.offset >= _scrollController.position.maxScrollExtent - 20) {
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
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_reachedEnd)
            LinearProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey[300],
            ),
          const SizedBox(height: 8),
          Flexible(
            child: SizedBox(
              width: double.maxFinite,
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
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
          ),
        ],
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