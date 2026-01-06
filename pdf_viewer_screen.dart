import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

import '../state/app_state.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final int initialPage;
  final String title;
  const PdfViewerScreen({super.key, required this.initialPage, required this.title});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  PdfControllerPinch? _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final path = ref.read(pdfPathProvider);
    if (path == null) return;
    try {
      final doc = await PdfDocument.openFile(path);
      setState(() {
        _controller = PdfControllerPinch(
          document: doc,
          initialPage: widget.initialPage,
        );
      });
    } catch (e) {
      setState(() => _error = 'Could not open PDF: $e');
    }
  }

  Future<void> _attachPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single.path;
    if (picked == null) return;

    // Basic existence check
    if (!File(picked).existsSync()) return;

    await ref.read(pdfPathProvider.notifier).setPath(picked);
    await _init();
  }

  @override
  Widget build(BuildContext context) {
    final pdfPath = ref.watch(pdfPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            tooltip: 'Attach rulebook PDF',
            onPressed: _attachPdf,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (pdfPath == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Attach your DH2e Core Rulebook PDF to enable page jumps.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _attachPdf,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Attach PDF'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (_error != null) {
            return Center(child: Text(_error!));
          }

          final controller = _controller;
          if (controller == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return PdfViewPinch(
            controller: controller,
            onDocumentError: (e) => setState(() => _error = e.toString()),
            onPageError: (page, e) => setState(() => _error = 'Page $page: $e'),
          );
        },
      ),
    );
  }
}
