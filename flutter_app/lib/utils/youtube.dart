/// Pulls a YouTube video ID out of common URL forms:
///   https://www.youtube.com/watch?v=ID&...
///   https://youtu.be/ID
///   https://www.youtube.com/embed/ID
///   https://www.youtube.com/shorts/ID
/// Returns null for non-YouTube URLs or anything we can't parse.
String? youtubeIdFromUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  final host = uri.host.toLowerCase();

  if (host == 'youtu.be') {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  }
  if (host.endsWith('youtube.com') || host.endsWith('youtube-nocookie.com')) {
    final v = uri.queryParameters['v'];
    if (v != null && v.isNotEmpty) return v;
    if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'embed' || uri.pathSegments[0] == 'shorts')) {
      return uri.pathSegments[1];
    }
  }
  return null;
}

/// `https://i.ytimg.com/vi/<id>/hqdefault.jpg` — public, no API key.
String? youtubeThumbnail(String url) {
  final id = youtubeIdFromUrl(url);
  return id == null ? null : 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}
