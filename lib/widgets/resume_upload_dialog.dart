import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/resume_details_screen.dart';
import '../services/resume_parser_service.dart';

/// Modal dialog allowing users to pick a resume file, paste text, or try a demo.
Future<void> showResumeUploadModal(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? kDarkSurface : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _ResumeUploadSheetContent(isDark: isDark),
  );
}

class _ResumeUploadSheetContent extends StatefulWidget {
  const _ResumeUploadSheetContent({required this.isDark});
  final bool isDark;

  @override
  State<_ResumeUploadSheetContent> createState() =>
      _ResumeUploadSheetContentState();
}

class _ResumeUploadSheetContentState extends State<_ResumeUploadSheetContent> {
  bool _isLoading = false;
  String? _statusMessage;

  Future<void> _handleFilePick() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Reading document and extracting details...';
    });

    try {
      final resume = await ResumeParserService.pickAndParseResume();
      if (!mounted) return;
      if (resume != null) {
        Navigator.pop(context); // close modal
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResumeDetailsScreen(resume: resume),
          ),
        );
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _handleDemoResume() {
    final demo = ResumeParserService.getDemoResume();
    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResumeDetailsScreen(resume: demo),
      ),
    );
  }

  void _handlePasteText() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        title: const Text('Paste Resume Content'),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: textController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste the full text of your resume here...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = textController.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(dCtx); // close dialog
              Navigator.pop(context); // close sheet
              final parsed = ResumeParserService.parseText(
                text,
                fileName: 'Pasted_Resume.txt',
                fileSizeBytes: text.length,
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ResumeDetailsScreen(resume: parsed),
                ),
              );
            },
            child: const Text('Parse Text'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: kVioletPurpleGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryPurple.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload & Extract Resume',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : kLightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Extracts skills, experience, projects & education',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? kDarkTextSecondary
                            : kLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          if (_isLoading) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? kDarkSurface2 : kLightSurface2,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: kAccentViolet),
                    const SizedBox(height: 14),
                    Text(
                      _statusMessage ?? 'Analyzing resume...',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Primary Pick File Option
            InkWell(
              onTap: _handleFilePick,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(
                          colors: [Color(0xFF2E1065), Color(0xFF1E1B4B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isDark ? null : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kAccentViolet.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimaryPurple.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: kAccentViolet,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose PDF or Text File',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : kPrimaryPurple,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Supports .pdf, .txt, .md documents',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? kDarkTextSecondary
                                  : kLightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: kAccentViolet),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Try Demo Resume Option
            OutlinedButton.icon(
              onPressed: _handleDemoResume,
              icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: kAccentViolet),
              label: const Text('Try Demo Developer Resume (Instant Preview)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Paste Text Option
            TextButton.icon(
              onPressed: _handlePasteText,
              icon: const Icon(Icons.paste_rounded, size: 16),
              label: const Text('Paste Raw Resume Text Instead'),
              style: TextButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
