import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class PdfUrlScreen extends StatefulWidget {
  const PdfUrlScreen({super.key});

  @override
  State<PdfUrlScreen> createState() => _PdfUrlScreenState();
}

class _PdfUrlScreenState extends State<PdfUrlScreen> {
  final _controller = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller.text = prefs.getString('pdfUrl') ?? '';
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pdfUrl', _controller.text.trim());
    setState(() => _saved = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF লিংক সেভ হয়েছে')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF সেট করুন')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'তাফসীর ইবনে কাসীর PDF-এর সরাসরি লিংক দিন।\n'
              'লিংকটি Google Drive, Dropbox বা যেকোনো\n'
              'direct download URL হতে পারে।',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'PDF URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                child: const Text('সেভ করুন', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.teal.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.teal.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 নির্দেশনা',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 8),
                  Text(
                    '• Google Drive: শেয়ার লিংকের শেষে &export=download যোগ করুন\n'
                    '• Dropbox: লিংকের শেষে ?dl=1 যোগ করুন\n'
                    '• Firebase Storage: সরাসরি download URL ব্যবহার করুন',
                    style: TextStyle(fontSize: 13, height: 1.6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
