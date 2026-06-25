import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/name_of_allah.dart';
import '../theme/app_theme.dart';

/// Lists Allah's 99 Beautiful Names (আসমাউল হুসনা) with Arabic script,
/// English transliteration, and Bengali meaning. Purely static/offline —
/// no network or audio dependency.
class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  List<NameOfAllah> _all = [];
  List<NameOfAllah> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/asma_ul_husna.json');
    final list = (json.decode(raw) as List)
        .map((e) => NameOfAllah.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _all = list;
      _filtered = list;
    });
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all
              .where((n) =>
                  n.nameTransliteration.toLowerCase().contains(q) ||
                  n.nameBengali.contains(query.trim()) ||
                  n.meaningBengali.contains(query.trim()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_all.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: 'নাম খুঁজুন...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('কোনো নাম পাওয়া যায়নি'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final n = _filtered[index];
                    return _NameCard(name: n);
                  },
                ),
        ),
      ],
    );
  }
}

class _NameCard extends StatelessWidget {
  final NameOfAllah name;

  const _NameCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.islamicGreenLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.islamicGreen,
              child: Text(
                '${name.number}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name.nameBengali,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        name.nameArabic,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.islamicGreenDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name.nameTransliteration,
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(name.meaningBengali),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
