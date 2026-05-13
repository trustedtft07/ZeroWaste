import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';
import '../../utils/markdown_text.dart';

class RecipeResultScreen extends StatelessWidget {
  final List<String> ingredients;
  final String recipeText;
  final String? title;

  const RecipeResultScreen({
    super.key,
    required this.ingredients,
    required this.recipeText,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isError = recipeText.startsWith('⚠️');

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Ide Masakan'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.dividerColor),
        ),
        actions: [
          if (!isError)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Salin resep',
              onPressed: () {
                // Salin teks bersih tanpa markdown
                final cleanText = recipeText
                    .replaceAll(RegExp(r'\*\*\*(.+?)\*\*\*'), r'$1')
                    .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
                    .replaceAll(RegExp(r'\*(.+?)\*'), r'$1');
                Clipboard.setData(ClipboardData(text: cleanText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Resep disalin!'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    const Text('Rekomendasi dari Groq AI',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    title ?? 'Ide Masakan dari Bahan Pilihanmu',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (ingredients.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Bahan utama:',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ingredients
                          .map((ing) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(ing,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Disclaimer ───────────────────────────────────────────
            if (!isError)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFCC80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Color(0xFFFF9800), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rekomendasi ini adalah saran pengolahan. Pastikan kelayakan fisik bahan sebelum dikonsumsi.',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.textMedium),
                      ),
                    ),
                  ],
                ),
              ),

            if (!isError) const SizedBox(height: 14),

            // ── Isi Resep dengan Markdown ────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.dividerColor),
              ),
              child: isError
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppTheme.statusCritical, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recipeText.replaceFirst('⚠️ ', ''),
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textDark,
                                height: 1.5),
                          ),
                        ),
                      ],
                    )
                  : MarkdownText(
                      text: recipeText,
                      fontSize: 14,
                      color: AppTheme.textDark,
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
