import 'package:url_launcher/url_launcher.dart';

/// Opens [value] in an external browser/app.
/// Silently ignores empty strings or non-http(s) URIs.
Future<void> openLink(
  String value, {
  LaunchMode? mode,
}) async {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      (uri.scheme != 'https' &&
          uri.scheme != 'http' &&
          uri.scheme != 'mailto' &&
          uri.scheme != 'tel')) {
    return;
  }
  try {
    final effectiveMode = mode ??
        (uri.scheme == 'mailto' || uri.scheme == 'tel'
            ? LaunchMode.platformDefault
            : (trimmed.contains('drive.google.com')
                ? LaunchMode.inAppBrowserView
                : LaunchMode.externalApplication));

    final success = await launchUrl(uri, mode: effectiveMode);
    if (!success && effectiveMode != LaunchMode.platformDefault) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  } catch (_) {
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

/// Returns true if [url] is a non-empty, well-formed http(s) URL.
bool isValidUrl(String url) {
  if (url.trim().isEmpty) return true; // optional fields are allowed empty
  final uri = Uri.tryParse(url.trim());
  return uri != null && (uri.scheme == 'https' || uri.scheme == 'http');
}
