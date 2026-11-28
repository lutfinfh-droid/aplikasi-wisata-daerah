import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Widget gambar cerdas yang memuat foto dari `imageUrl` Supabase.
/// Jika kosong atau gagal dimuat, widget secara otomatis mencari foto asli tempat
/// wisata tersebut dari API publik Wikipedia Indonesia atau Wikimedia Commons
/// dan menampilkannya dengan efek shimmer loading halus dan in-memory cache.
class SmartDestinationImage extends StatefulWidget {
  const SmartDestinationImage({
    super.key,
    required this.imageUrl,
    required this.destinationName,
    this.regency = 'Lampung',
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String? imageUrl;
  final String destinationName;
  final String regency;
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
    final rawUrl = widget.imageUrl?.trim() ?? '';
    if (rawUrl.isNotEmpty) {
      _resolvedUrl = rawUrl;
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
      () => _searchWikipediaAndCommons(widget.destinationName.trim(), widget.regency),
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

  static Future<String?> _searchWikipediaAndCommons(String query, String regency) async {
    // 1. Coba cari nama wisata langsung di Wikipedia Indonesia
    var result = await _searchWiki(query);
    if (result != null && result.isNotEmpty) return result;

    // Bersihkan nama dari tanda kurung seperti "(Banana Island)" atau "(Krui Surf Spot)"
    final cleanName = query.replaceAll(RegExp(r'\(.*?\)'), '').trim();
    if (cleanName != query) {
      result = await _searchWiki(cleanName);
      if (result != null && result.isNotEmpty) return result;
    }

    // 2. Coba tambahkan "Lampung"
    result = await _searchWiki('$cleanName Lampung');
    if (result != null && result.isNotEmpty) return result;

    // 3. Coba cari di Wikimedia Commons
    result = await _searchCommons(query);
    if (result != null && result.isNotEmpty) return result;

    result = await _searchCommons('$cleanName Lampung');
    if (result != null && result.isNotEmpty) return result;

    // 4. Fallback ke gambar alam Lampung representatif
    result = await _searchWiki('Teluk Lampung');
    if (result != null && result.isNotEmpty) return result;

    return null;
  }

  static Future<String?> _searchWiki(String term) async {
    final encoded = Uri.encodeQueryComponent(term);
    final wikiUrl =
        'https://id.wikipedia.org/w/api.php?action=query&generator=search&gsrsearch=$encoded&gsrlimit=1&prop=pageimages&pithumbsize=800&format=json';
    return _fetchJsonThumbnail(wikiUrl, isCommons: false);
  }

  static Future<String?> _searchCommons(String term) async {
    final encoded = Uri.encodeQueryComponent(term);
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
        'JelajahWisataLampung/1.0 (Mobile App; contact: wisata@lampung.id)',
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
      return _NatureFallback(width: widget.width, height: widget.height);
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, _) =>
          _ShimmerPlaceholder(width: widget.width, height: widget.height),
      errorWidget: (context, _, __) {
        if (!_primaryFailed && (widget.imageUrl?.trim().isNotEmpty ?? false)) {
          _primaryFailed = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _fetchFromPublicApi();
          });
          return _ShimmerPlaceholder(
            width: widget.width,
            height: widget.height,
          );
        }
        return _NatureFallback(
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
      duration: const Duration(milliseconds: 1200),
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

/// Fallback elegan bertema alam bernuansa gradasi Teal-Emerald
class _NatureFallback extends StatelessWidget {
  const _NatureFallback({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E),
            Color(0xFF064E3B),
          ],
        ),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.nature_people_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
