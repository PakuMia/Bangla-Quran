import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../models/surah_info.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'pdf_url_screen.dart';

class ReaderScreen extends StatefulWidget {
  final SurahInfo surah;
  final int? initialPage;

  const ReaderScreen({super.key, required this.surah, this.initialPage});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _pdfController = PdfViewerController();
  final _jumpController = TextEditingController();
  int _currentPage = 1;
  int _totalPages = 1;
  bool _showJump = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final saved = provider.getLastPage(widget.surah.number);
    _currentPage =
        widget.initialPage ?? (saved > 0 ? saved : widget.surah.page);
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _jumpController.dispose();
    super.dispose();
  }

  void _jumpToPage() {
    final page = int.tryParse(_jumpController.text);
    if (page != null && page >= 1 && page <= _totalPages) {
      _pdfController.jumpToPage(page);
      setState(() => _showJump = false);
    }
    _jumpController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final bookmarked = provider.isBookmarked(widget.surah.number, _currentPage);
    final subtext = isDark ? const Color(0xFF66747f) : const Color(0xFF888888);
    final pdfSource = provider.pdfSource;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surah.name),
        actions: [
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: bookmarked ? AppTheme.teal : null,
            ),
            onPressed: () => provider.toggleBookmark(
              widget.surah.number,
              widget.surah.name,
              _currentPage,
            ),
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            color: AppTheme.teal,
            onPressed: provider.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(context, subtext),
          Expanded(child: _buildPdfView(pdfSource, isDark)),
          _buildBottomBar(context, subtext, bookmarked),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, Color subtext) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.chevron_left, size: 18),
            label: const Text('পূর্ববর্তী', style: TextStyle(fontSize: 13)),
            onPressed: _currentPage > 1
                ? () => _pdfController.previousPage()
                : null,
          ),
          Text(
            'পৃষ্ঠা $_currentPage / $_totalPages',
            style: TextStyle(fontSize: 13, color: subtext),
          ),
          TextButton.icon(
            icon: const Icon(Icons.chevron_right, size: 18),
            label: const Text('পরবর্তী', style: TextStyle(fontSize: 13)),
            onPressed: _currentPage < _totalPages
                ? () => _pdfController.nextPage()
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPdfView(String pdfSource, bool isDark) {
    if (pdfSource.isEmpty) {
      return _NoPdfPlaceholder(surahName: widget.surah.name);
    }

    final isLocalFile = pdfSource.startsWith('/');

    void onPageChanged(PdfPageChangedDetails details) {
      setState(() => _currentPage = details.newPageNumber);
      context.read<AppProvider>().saveLastPage(
            widget.surah.number,
            details.newPageNumber,
          );
    }

    void onDocumentLoaded(PdfDocumentLoadedDetails details) {
      setState(() => _totalPages = details.document.pages.count);
    }

    void onLoadFailed(PdfDocumentLoadFailedDetails details) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF লোড হয়নি: ${details.description}')),
      );
    }

    if (isLocalFile) {
      return SfPdfViewer.file(
        File(pdfSource),
        controller: _pdfController,
        initialPageNumber: _currentPage,
        enableDoubleTapZooming: true,
        pageLayoutMode: PdfPageLayoutMode.single,
        onPageChanged: onPageChanged,
        onDocumentLoaded: onDocumentLoaded,
        onDocumentLoadFailed: onLoadFailed,
      );
    }

    return SfPdfViewer.network(
      pdfSource,
      controller: _pdfController,
      initialPageNumber: _currentPage,
      enableDoubleTapZooming: true,
      pageLayoutMode: PdfPageLayoutMode.single,
      onPageChanged: onPageChanged,
      onDocumentLoaded: onDocumentLoaded,
      onDocumentLoadFailed: onLoadFailed,
    );
  }

  Widget _buildBottomBar(
      BuildContext context, Color subtext, bool bookmarked) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (_showJump) ...[
            SizedBox(
              width: 60,
              height: 36,
              child: TextField(
                controller: _jumpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (_) => _jumpToPage(),
                autofocus: true,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size(56, 36),
                padding: EdgeInsets.zero,
              ),
              onPressed: _jumpToPage,
              child: const Text('যান', style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _showJump = false),
              child: Text('বাতিল', style: TextStyle(color: subtext)),
            ),
          ] else ...[
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('PDF সেট করুন', style: TextStyle(fontSize: 12)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfUrlScreen()),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.teal,
                side: BorderSide(color: AppTheme.teal.withOpacity(0.5)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.keyboard, size: 16),
              label: const Text('পৃষ্ঠায় যান', style: TextStyle(fontSize: 12)),
              onPressed: () => setState(() => _showJump = true),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.teal,
                side: BorderSide(color: AppTheme.teal.withOpacity(0.5)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoPdfPlaceholder extends StatelessWidget {
  final String surahName;

  const _NoPdfPlaceholder({required this.surahName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              size: 72,
              color: AppTheme.teal.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              surahName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 12),
            Text(
              'তাফসীর PDF এখনো সেট করা হয়নি।\nফোন থেকে PDF বেছে নিন বা লিংক দিন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF66747f)
                    : const Color(0xFF888888),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_link),
              label: const Text('PDF লিংক সেট করুন'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.teal,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfUrlScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
