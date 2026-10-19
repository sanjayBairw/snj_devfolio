import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/resume_data.dart';
import '../services/resume_download_service.dart';

/// Full-screen high-fidelity visual preview of the developer resume document.
/// Displays the actual resume document with pinch-to-zoom, pan, and direct download.
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF070B16) : const Color(0xFFE2E8F0),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              kResumeFileName,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Official Document • 1 Page',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? kDarkTextSecondary : kLightTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Download PDF',
            icon: const Icon(Icons.download_rounded, color: kAccentViolet),
            onPressed: () => ResumeDownloadService.downloadResume(context),
          ),
          IconButton(
            tooltip: 'Reset Zoom',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetZoom,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Document Viewer with Pan and Pinch Zoom
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
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 820),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.6 : 0.25,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          kResumeImagePage1,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              _buildFallbackDocument(isDark),
                        ),
                      ),
                    ),
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
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : kLightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.zoom_out_rounded, size: 20),
                        tooltip: 'Zoom Out',
                        onPressed: _zoomOut,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '${(_currentScale * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : kLightTextPrimary,
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
                        color: Colors.grey.withValues(alpha: 0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            ResumeDownloadService.downloadResume(context),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimaryPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
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
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackDocument(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      color: Colors.white,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_rounded, size: 64, color: Colors.redAccent),
          SizedBox(height: 12),
          Text(
            'Sanjay Bairwa — Resume',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Flutter Developer • Full Stack Developer',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
