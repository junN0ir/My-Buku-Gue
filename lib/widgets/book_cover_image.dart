import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookCoverImage extends StatefulWidget {
  final String coverUrl;
  final double width;
  final double height;
  final double borderRadius;

  const BookCoverImage({
    super.key,
    required this.coverUrl,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<BookCoverImage> createState() => _BookCoverImageState();
}

class _BookCoverImageState extends State<BookCoverImage> {
  static final Map<String, Uint8List> _memCache = {};
  static final Set<String> _failedUrls = {};
  static const int _maxMemEntries = 60;
  static const int _maxDiskFiles = 100;
  static DateTime? _lastPruneTime;

  Uint8List? _bytes;
  bool _isLoading = false;
  bool _hasError = false;

  static void _saveToMemCache(String key, Uint8List data) {
    if (_memCache.length >= _maxMemEntries) {
      _memCache.remove(_memCache.keys.first);
    }
    _memCache[key] = data;
  }

  static void _pruneDiskCache(Directory cacheDir) {
    final now = DateTime.now();
    if (_lastPruneTime != null &&
        now.difference(_lastPruneTime!).inMinutes < 5) {
      return;
    }
    _lastPruneTime = now;

    try {
      final files = cacheDir.listSync().whereType<File>().toList();
      if (files.length > _maxDiskFiles) {
        files.sort(
            (a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
        final excess = files.length - _maxDiskFiles;
        for (int i = 0; i < excess; i++) {
          files[i].deleteSync();
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant BookCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coverUrl != widget.coverUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final clean = widget.coverUrl.trim();
    if (clean.isEmpty || !clean.startsWith('http')) {
      return;
    }

    if (_memCache.containsKey(clean)) {
      setState(() {
        _bytes = _memCache[clean];
        _isLoading = false;
        _hasError = false;
      });
      return;
    }

    if (_failedUrls.contains(clean)) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final safeName = 'cov_${clean.hashCode.toRadixString(16)}.jpg';
      final cacheDir = Directory('${Directory.systemTemp.path}/mybuku_covers');
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }
      final file = File('${cacheDir.path}/$safeName');

      if (file.existsSync() && file.lengthSync() > 1000) {
        final data = await file.readAsBytes();
        _saveToMemCache(clean, data);
        if (mounted) {
          setState(() {
            _bytes = data;
            _isLoading = false;
          });
        }
        return;
      }

      final resp = await http.get(Uri.parse(clean)).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200 && resp.bodyBytes.length > 1000) {
        final data = resp.bodyBytes;
        await file.writeAsBytes(data, flush: true);
        _saveToMemCache(clean, data);
        _pruneDiskCache(cacheDir);
        if (mounted) {
          setState(() {
            _bytes = data;
            _isLoading = false;
          });
        }
      } else {
        _failedUrls.add(clean);
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      _failedUrls.add(clean);
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: Colors.grey.shade300, width: 0.8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_rounded, color: Colors.grey.shade400, size: 20),
          const SizedBox(height: 4),
          Text(
            'Cover tidak\ntersedia',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8.5,
              color: Colors.grey.shade500,
              height: 1.2,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cleanPath = widget.coverUrl.trim();

    if (cleanPath.isEmpty || _hasError) {
      return _buildPlaceholder();
    }

    if (!cleanPath.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.asset(
          cleanPath,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          cacheWidth: (widget.width * 2.5).round(),
          errorBuilder: (_, _, _) => _buildPlaceholder(),
        ),
      );
    }

    if (_bytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.memory(
          _bytes!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          cacheWidth: (widget.width * 2.5).round(),
          errorBuilder: (_, _, _) => _buildPlaceholder(),
        ),
      );
    }

    if (_isLoading) {
      return _buildLoading();
    }

    return _buildPlaceholder();
  }
}
