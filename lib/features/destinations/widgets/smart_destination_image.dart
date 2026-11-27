import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget gambar pintar yang otomatis mencari foto asli dari Wikipedia Indonesia
/// atau Wikimedia Commons jika `imageUrl` dari database kosong atau gagal dimuat.
class SmartDestinationImage extends StatefulWidget {
  const SmartDestinationImage({
    super.key,
    required this.imageUrl,
    required this.destinationName,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imageUrl;
  final String destinationName;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  State<SmartDestinationImage> createState() => _SmartDestinationImageState();
}

class _SmartDestinationImageState extends State<SmartDestinationImage> {
  static final Map<String, String?> _memoryCache = {};
  static final Map<String, Future<String?>> _inFlightRequests = {};

  String? _resolvedUrl;
  bool _isSearching = false;
  bool _primaryFailed = false;

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  void didUpdateWidget(covariant SmartDestinationImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.destinationName != widget.destinationName) {
      _primaryFailed = false;
      _resolvedUrl = null;
      _initImage();
    }
  }

  void _initImage() {
    final trimmed = widget.imageUrl.trim();
    if (trimmed.isNotEmpty) {
      _resolvedUrl = trimmed;
      return;
    }
    _fetchFromPublicApi();
  }

  Future<void> _fetchFromPublicApi() async {
    final key = widget.destinationName.trim().toLowerCase();
    if (key.isEmpty) return;

    if (_memoryCache.containsKey(key)) {
      if (mounted) {
        setState(() {
          _resolvedUrl = _memoryCache[key];
          _isSearching = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isSearching = true);
    }

    final future = _inFlightRequests.putIfAbsent(
      key,
      () => _searchWikipediaAndCommons(widget.destinationName.trim()),
    );

    final url = await future;
    _inFlightRequests.remove(key);
    _memoryCache[key] = url;

    if (mounted) {
      setState(() {
        _resolvedUrl = url;
        _isSearching = false;
      });
    }
  }

  static Future<String?> _searchWikipediaAndCommons(String query) async {
    final encoded = Uri.encodeQueryComponent(query);
    final wikiUrl =
        'https://id.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=$encoded&gsrlimit=1&prop=pageimages&pithumbsize=800&format=json';

    final wikiImage = await _fetchJsonThumbnail(wikiUrl, isCommons: false);
    if (wikiImage != null && wikiImage.isNotEmpty) {
      return wikiImage;
    }

    final commonsUrl =
        'https://commons.wikimedia.org/w/api.php?action=query&generator=search&gsrsearch=$encoded&gsrnamespace=6&gsrlimit=1&prop=imageinfo&iiprop=url&iiurlwidth=800&format=json';
    return _fetchJsonThumbnail(commonsUrl, isCommons: true);
  }

  static Future<String?> _fetchJsonThumbnail(
    String url, {
    required bool isCommons,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(Uri.parse(url));
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'JelajahWisataLampung/1.0 (Flutter App)',
      );
      final response = await request.close();
      if (response.statusCode != 200) return null;

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as Map<String, dynamic>?;
      final query = data?['query'] as Map<String, dynamic>?;
      final pages = query?['pages'] as Map<String, dynamic>?;
      if (pages == null || pages.isEmpty) return null;

      final firstPage = pages.values.first as Map<String, dynamic>?;
      if (firstPage == null) return null;

      if (!isCommons) {
        final thumbnail = firstPage['thumbnail'] as Map<String, dynamic>?;
        return thumbnail?['source']?.toString();
      } else {
        final imageInfo = firstPage['imageinfo'] as List<dynamic>?;
        if (imageInfo == null || imageInfo.isEmpty) return null;
        final info = imageInfo.first as Map<String, dynamic>?;
        return (info?['thumburl'] ?? info?['url'])?.toString();
      }
    } catch (_) {
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      return _ShimmerPlaceholder(width: widget.width, height: widget.height);
    }

    final url = _resolvedUrl;
    if (url == null || url.isEmpty) {
      return _FallbackPlaceholder(width: widget.width, height: widget.height);
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, _) =>
          _ShimmerPlaceholder(width: widget.width, height: widget.height),
      errorWidget: (context, _, __) {
        if (!_primaryFailed && widget.imageUrl.trim().isNotEmpty) {
          _primaryFailed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchFromPublicApi();
          });
          return _ShimmerPlaceholder(
            width: widget.width,
            height: widget.height,
          );
        }
        return _FallbackPlaceholder(
          width: widget.width,
          height: widget.height,
        );
      },
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  const _ShimmerPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(slide - 1, -0.2),
              end: Alignment(slide + 1, 0.2),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF1F5F9),
                Color(0xFFE2E8F0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FallbackPlaceholder extends StatelessWidget {
  const _FallbackPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE2E8F0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.landscape_rounded,
        size: 48,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
