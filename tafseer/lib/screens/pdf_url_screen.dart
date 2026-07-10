import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class PdfUrlScreen extends StatefulWidget {
  const PdfUrlScreen({super.key});

  @override
  State<PdfUrlScreen> createState() => _PdfUrlScreenState();
}

class _PdfUrlScreenState extends State<PdfUrlScreen> {
  final _controller = TextEditingController();
  String? _pickedFileName;
  bool _isPickingFile = false;

  @override
  void initState() {
    super.initState();
    final source = context.read<AppProvider>().pdfSource;
    if (source.startsWith('/')) {
      _pickedFileName = source.split('/').last;
    } else {
      _controller.text = source;
    }
  }

  Future<void> _pickFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        await context.read<AppProvider>().setPdfSource(path);
        setState(() {
          _pickedFileName = result.files.single.name;
          _controller.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF সেট হয়েছে')),
          );
          Navigator.pop(context);
        }
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Future<void> _saveUrl() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;
    await context.read<AppProvider>().setPdfSource(url);
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'বিকল্প ১: ফোন থেকে PDF বেছে নিন',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            if (_pickedFileName != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.teal.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: AppTheme.teal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _pickedFileName!,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isPickingFile
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.folder_open),
                label: Text(
                  _pickedFileName == null
                      ? 'ফোন থেকে PDF বেছে নিন'
                      : 'অন্য PDF বেছে নিন',
                  style: const TextStyle(fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isPickingFile ? null : _pickFile,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'বিকল্প ২: অনলাইন লিংক দিন',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'PDF URL',
                hintText: 'https://...',
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (_) {
                if (_pickedFileName != null) {
                  setState(() => _pickedFileName = null);
                }
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveUrl,
                child: const Text('লিংক সেভ করুন',
                    style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.teal.withOpacity(0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.teal.withOpacity(0.2)),
              ),
              child: const Text(
                'Google Drive লিংক: শেষে &export=download যোগ করুন\n'
                'Dropbox লিংক: শেষে ?dl=1 যোগ করুন',
                style: TextStyle(fontSize: 12, height: 1.6),
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
