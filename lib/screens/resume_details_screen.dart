import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import '../models/resume_data.dart';
import '../services/resume_download_service.dart';
import '../utils/url_utils.dart';
import '../widgets/app_ui.dart';

/// Represents an interactive clickable hotspot within the resume document.
class _ResumeLinkSpot {
  const _ResumeLinkSpot({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.normX,
    required this.normY,
    required this.normW,
    required this.normH,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String url;
  final double normX;
  final double normY;
  final double normW;
  final double normH;
  final IconData icon;
}

/// Full-screen high-fidelity visual preview of the developer resume document (SnjR_removed.pdf).
/// Displays the actual resume document with pinch-to-zoom, pan, clickable links,
/// a quick-links bottom sheet, and direct PDF download.
class ResumeDetailsScreen extends StatefulWidget {
  const ResumeDetailsScreen({
    super.key,
    this.resume,
    this.canApplyToProfile = false,
  });

  final ResumeData? resume;
  final bool canApplyToProfile;

  @override
  State<ResumeDetailsScreen> createState() => _ResumeDetailsScreenState();
}

class _ResumeDetailsScreenState extends State<ResumeDetailsScreen> {
  final TransformationController _transformCtrl = TransformationController();
  double _currentScale = 1.0;
  bool _showLinkHighlights = true;
  bool _showHintBanner = true;

  /// Exact normalized coordinates for links extracted from SnjR_removed.pdf (A4: 595.28 x 841.89 pt).
  static const List<_ResumeLinkSpot> _resumeLinks = [
    _ResumeLinkSpot(
      title: 'Phone',
      subtitle: '+91-7014781370',
      url: 'tel:+917014781370',
      normX: 0.056,
      normY: 0.075,
      normW: 0.155,
      normH: 0.022,
      icon: Icons.phone_rounded,
    ),
    _ResumeLinkSpot(
      title: 'Email',
      subtitle: 'bairwas361@gmail.com',
      url: 'mailto:bairwas361@gmail.com',
      normX: 0.230,
      normY: 0.075,
      normW: 0.175,
      normH: 0.022,
      icon: Icons.email_rounded,
    ),
    _ResumeLinkSpot(
      title: 'GitHub',
      subtitle: 'github.com/sanjayBairwa',
      url: 'https://github.com/sanjayBairwa',
      normX: 0.453,
      normY: 0.075,
      normW: 0.195,
      normH: 0.022,
      icon: Icons.code_rounded,
    ),
    _ResumeLinkSpot(
      title: 'LinkedIn',
      subtitle: 'linkedin.com/in/sanjay-buhadiya',
      url: 'https://linkedin.com/in/sanjay-buhadiya',
      normX: 0.695,
      normY: 0.075,
      normW: 0.250,
      normH: 0.022,
      icon: Icons.badge_rounded,
    ),
    _ResumeLinkSpot(
      title: 'TaskFlow APK Demo',
      subtitle: 'Google Drive APK Download',
      url:
          'https://drive.google.com/file/d/1d1JbtGcZA_Yfl3My5aot7V2j3JCiA69Z/view?usp=sharing',
      normX: 0.842,
      normY: 0.598,
      normW: 0.104,
      normH: 0.020,
      icon: Icons.android_rounded,
    ),
    _ResumeLinkSpot(
      title: 'Salesforce Certificate',
      subtitle: 'Administrator & App Builder',
      url:
          'https://drive.google.com/file/d/1UO-VDDJpwvDmjPl3lAvKt5cwTKZw28sw/view?usp=sharing',
      normX: 0.845,
      normY: 0.841,
      normW: 0.095,
      normH: 0.018,
      icon: Icons.verified_rounded,
    ),
    _ResumeLinkSpot(
      title: 'Generative AI Certificate',
      subtitle: 'Introduction to GenAI Studio',
      url:
          'https://drive.google.com/file/d/1eL0CZLUQUu1XBdTPqJQGsRLVfyDSHimj/view?usp=sharing',
      normX: 0.845,
      normY: 0.855,
      normW: 0.095,
      normH: 0.018,
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _transformCtrl.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformCtrl.removeListener(_onTransformChanged);
    _transformCtrl.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformCtrl.value.getMaxScaleOnAxis();
    if (scale != _currentScale) {
      setState(() => _currentScale = scale);
    }
  }

  void _resetZoom() {
    setState(() {
      _transformCtrl.value = Matrix4.identity();
      _currentScale = 1.0;
    });
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.3).clamp(1.0, 4.5);
    _transformCtrl.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    setState(() => _currentScale = newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.3).clamp(1.0, 4.5);
    _transformCtrl.value = Matrix4.diagonal3Values(newScale, newScale, 1.0);
    setState(() => _currentScale = newScale);
  }

  void _handleDoubleTap() {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      _transformCtrl.value = Matrix4.diagonal3Values(2.2, 2.2, 1.0);
      setState(() => _currentScale = 2.2);
    }
  }

  void _openResumeLink(_ResumeLinkSpot link) {
    openLink(link.url);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(link.icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Opening ${link.title} • ${link.subtitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(fontSize: 13),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showQuickLinksModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? kDarkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: appTextMuted(isDark).withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(Icons.link_rounded, color: kAccentViolet, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Verified Credentials & Links',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: appTextPrimary(isDark),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kAccentViolet.withValues(alpha: isDark ? 0.2 : 0.12),
                        borderRadius: BorderRadius.circular(kRadiusXs),
                      ),
                      child: Text(
                        '${_resumeLinks.length} ACTIVE',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: kAccentViolet,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _resumeLinks.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: appBorderColor(isDark),
                    ),
                    itemBuilder: (ctx, index) {
                      final item = _resumeLinks[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kAccentViolet.withValues(alpha: isDark ? 0.16 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(item.icon, size: 18, color: kAccentViolet),
                        ),
                        title: Text(
                          item.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary(isDark),
                          ),
                        ),
                        subtitle: Text(
                          item.subtitle,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: appTextSecondary(isDark),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: appTextMuted(isDark),
                        ),
                        onTap: () {
                          Navigator.pop(ctx);
                          _openResumeLink(item);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? kDarkBackground : const Color(0xFFE5E7EB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              kResumeFileName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Official Document • 1 Page • Interactive Hotspots',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: kAccentViolet,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _showLinkHighlights ? 'Hide Hotspot Borders' : 'Show Hotspot Borders',
            icon: Icon(
              _showLinkHighlights
                  ? Icons.highlight_rounded
                  : Icons.highlight_outlined,
              color: _showLinkHighlights ? kAccentViolet : null,
            ),
            onPressed: () {
              setState(() => _showLinkHighlights = !_showLinkHighlights);
            },
          ),
          IconButton(
            tooltip: 'All Links (${_resumeLinks.length})',
            icon: const Icon(Icons.link_rounded),
            onPressed: () => _showQuickLinksModal(context),
          ),
          IconButton(
            tooltip: 'Download PDF File',
            icon: const Icon(Icons.download_rounded, color: kAccentViolet),
            onPressed: () => ResumeDownloadService.downloadResume(context),
          ),
          IconButton(
            tooltip: 'Reset Zoom Scale',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetZoom,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Document Viewer with Pan, Pinch Zoom, and Clickable Hotspots
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transformCtrl,
                  minScale: 1.0,
                  maxScale: 4.5,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 820),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(kRadiusSm),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.6 : 0.22,
                              ),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: AspectRatio(
                          // Standard A4 aspect ratio (595.28 / 841.89 = 0.70707)
                          aspectRatio: 595.276 / 841.890,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final docWidth = constraints.maxWidth;
                              final docHeight = constraints.maxHeight;

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Base Rendered Document Image
                                  Image.asset(
                                    kResumeImagePage1,
                                    fit: BoxFit.fill,
                                    errorBuilder: (_, __, ___) =>
                                        _buildFallbackDocument(isDark),
                                  ),

                                  // Clickable Document Hotspots (Directly mapped to PDF link rects)
                                  for (final link in _resumeLinks)
                                    Positioned(
                                      left: link.normX * docWidth,
                                      top: link.normY * docHeight,
                                      width: link.normW * docWidth,
                                      height: link.normH * docHeight,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                          splashColor: kAccentViolet
                                              .withValues(alpha: 0.3),
                                          highlightColor: kAccentBlue
                                              .withValues(alpha: 0.15),
                                          onTap: () => _openResumeLink(link),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              color: _showLinkHighlights
                                                  ? kAccentViolet
                                                      .withValues(alpha: 0.16)
                                                  : Colors.transparent,
                                              border: _showLinkHighlights
                                                  ? Border.all(
                                                      color: kAccentViolet
                                                          .withValues(alpha: 0.5),
                                                      width: 1.0,
                                                    )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Dismissible tip banner
            if (_showHintBanner && _showLinkHighlights)
              Positioned(
                top: 8,
                left: 16,
                right: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: (isDark ? kDarkSurface : Colors.white)
                          .withValues(alpha: 0.96),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: appBorderColor(isDark)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          size: 16,
                          color: kAccentViolet,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Interactive Hotspots: Tap any highlighted link to navigate',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: appTextPrimary(isDark),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => setState(() => _showHintBanner = false),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: appTextMuted(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Floating Bottom Control Bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? kDarkSurface : Colors.white)
                        .withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: appBorderColor(isDark)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.zoom_out_rounded, size: 20),
                          tooltip: 'Zoom Out',
                          onPressed: _zoomOut,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${(_currentScale * 100).toInt()}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: appTextPrimary(isDark),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.zoom_in_rounded, size: 20),
                          tooltip: 'Zoom In',
                          onPressed: _zoomIn,
                        ),
                        Container(
                          height: 20,
                          width: 1,
                          color: appBorderColor(isDark),
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showQuickLinksModal(context),
                          icon: const Icon(Icons.link_rounded, size: 16),
                          label: Text(
                            'Links (${_resumeLinks.length})',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kAccentViolet,
                            side: BorderSide(
                              color: kAccentViolet.withValues(alpha: 0.4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: () =>
                              ResumeDownloadService.downloadResume(context),
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: Text(
                            'Download PDF',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: kAccentViolet,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackDocument(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            '$kDevName — Resume',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            kDevRole,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
