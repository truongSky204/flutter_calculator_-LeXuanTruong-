import 'package:flutter/material.dart';

import '../models/calculation_history.dart';
import '../utils/constants.dart';

class DisplayArea extends StatelessWidget {
  final String expression;
  final String result;
  final String previousResult;
  final bool hasError;

  final bool angleDegrees;
  final bool memoryStored;

  final List<CalculationHistory> previewItems;
  final Function(String expr) onSelectHistory;

  // Gestures
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;

  // Tham số scale + fontScale vẫn giữ để không phải sửa các file khác
  final ValueChanged<double> onScaleUpdate;
  final double fontScale;

  const DisplayArea({
    super.key,
    required this.expression,
    required this.result,
    required this.previousResult,
    required this.hasError,
    required this.angleDegrees,
    required this.memoryStored,
    required this.previewItems,
    required this.onSelectHistory,
    required this.onSwipeRight,
    required this.onSwipeUp,
    required this.onScaleUpdate,
    required this.fontScale,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      // Swipe phải -> xoá 1 ký tự
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > 0) {
          onSwipeRight();
        }
      },
      // Swipe lên -> mở History
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! < 0) {
          onSwipeUp();
        }
      },
      // ❌ KHÔNG dùng onScaleUpdate ở đây nữa để tránh conflict gesture
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppDimens.displayRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ---- Hàng indicator DEG/RAD + M ----
            Row(
              children: [
                _Chip(text: angleDegrees ? "DEG" : "RAD"),
                const SizedBox(width: 6),
                if (memoryStored) const _Chip(text: "M"),
                const Spacer(),
              ],
            ),

            const SizedBox(height: 4),

            // ---- Dòng expression trước (dimmed) ----
            Text(
              previousResult.isEmpty ? "" : previousResult,
              style: TextStyle(
                fontSize: 14 * fontScale,
                fontWeight: FontWeight.w300,
                color: cs.onSurface.withOpacity(0.45),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            // ---- Expression hiện tại (scroll ngang) ----
            ScrollConfiguration(
              behavior: ScrollConfiguration.of(context)
                  .copyWith(scrollbars: false),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Text(
                  expression.isEmpty ? "0" : expression,
                  style: TextStyle(
                    fontSize: 16 * fontScale,
                    fontWeight: FontWeight.w400,
                    color: cs.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ---- Result (fade-in + báo lỗi màu đỏ) ----
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                result,
                key: ValueKey(result),
                style: TextStyle(
                  fontSize: 30 * fontScale,
                  fontWeight: FontWeight.w600,
                  color: hasError ? Colors.redAccent : cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // ---- History preview (3 phép tính gần nhất) ----
            _HistoryPreview(
              items: previewItems,
              onTapItem: onSelectHistory,
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.secondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _HistoryPreview extends StatelessWidget {
  final List<CalculationHistory> items;
  final Function(String expr) onTapItem;

  const _HistoryPreview({
    required this.items,
    required this.onTapItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox(height: 32);

    final preview = items.take(3).toList();
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: preview.length,
        itemBuilder: (_, i) {
          final h = preview[i];
          return GestureDetector(
            onTap: () => onTapItem(h.expression),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.secondary.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      h.expression,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    h.result,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
