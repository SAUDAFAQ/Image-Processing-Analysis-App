import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';

/// Reusable section: Extracted Text with search (highlight + auto-scroll to match) and copy.
/// Uses [searchQuery] (Rx) for reactive search; [onCopy] is called when Copy is pressed.
class ExtractedTextSection extends StatefulWidget {
  const ExtractedTextSection({
    super.key,
    required this.text,
    required this.searchQuery,
    required this.onCopy,
  });

  final String text;
  final RxString searchQuery;
  final VoidCallback onCopy;

  @override
  State<ExtractedTextSection> createState() => _ExtractedTextSectionState();
}

class _ExtractedTextSectionState extends State<ExtractedTextSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    ever(widget.searchQuery, _scrollToFirstMatch);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstMatch(_) {
    final query = widget.searchQuery.value.trim();
    if (query.isEmpty || widget.text.isEmpty) return;
    final index = widget.text.toLowerCase().indexOf(query.toLowerCase());
    if (index < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position;
      final maxScroll = position.maxScrollExtent;
      if (maxScroll <= 0) return;
      final ratio = index / widget.text.length;
      final targetOffset = (ratio * maxScroll).clamp(0.0, maxScroll);
      _scrollController.jumpTo(targetOffset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Extracted Text',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => widget.searchQuery.value = v,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search in text...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: widget.text.isEmpty ? null : widget.onCopy,
              icon: const Icon(Icons.copy, size: 18, color: AppColors.accent),
              label: const Text(
                'Copy',
                style: TextStyle(color: AppColors.accent),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(minHeight: 120, maxHeight: 220),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: widget.text.isEmpty
              ? const Center(
                  child: Text(
                    'No text detected.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                )
              : Obx(
                  () => SingleChildScrollView(
                    controller: _scrollController,
                    child: SelectableText.rich(
                      TextSpan(
                        children: _buildSpans(
                          widget.text,
                          widget.searchQuery.value,
                        ),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  static List<InlineSpan> _buildSpans(String fullText, String query) {
    if (query.trim().isEmpty) {
      return [TextSpan(text: fullText)];
    }
    final q = query.trim().toLowerCase();
    final list = <InlineSpan>[];
    int start = 0;
    while (true) {
      final i = fullText.toLowerCase().indexOf(q, start);
      if (i < 0) {
        if (start < fullText.length) {
          list.add(TextSpan(text: fullText.substring(start)));
        }
        break;
      }
      if (i > start) {
        list.add(TextSpan(text: fullText.substring(start, i)));
      }
      list.add(
        TextSpan(
          text: fullText.substring(i, i + q.length),
          style: const TextStyle(
            backgroundColor: AppColors.accent,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      start = i + q.length;
    }
    return list;
  }
}
