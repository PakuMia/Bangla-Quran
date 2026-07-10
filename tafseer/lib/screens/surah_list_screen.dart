import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bookmark.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'reader_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDark;
    final subtext = isDark ? const Color(0xFF5b6770) : const Color(0xFF888888);

    return Scaffold(
      appBar: AppBar(
        title: const Text('তাফসীর ইবনে কাসীর'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            color: AppTheme.teal,
            tooltip: isDark ? 'লাইট মোড' : 'ডার্ক মোড',
            onPressed: provider.toggleTheme,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'সূরা'),
            Tab(text: 'পারা'),
            Tab(text: 'বুকমার্ক'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _SurahTab(
            searchController: _searchController,
            subtext: subtext,
          ),
          _ParaTab(subtext: subtext),
          _BookmarkTab(subtext: subtext),
        ],
      ),
    );
  }
}

class _SurahTab extends StatelessWidget {
  final TextEditingController searchController;
  final Color subtext;

  const _SurahTab({required this.searchController, required this.subtext});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final surahs = provider.filteredSurahs;
    final lastSurah = provider.lastOpenedSurah;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: provider.setSearchQuery,
            decoration: const InputDecoration(
              hintText: 'সূরা খুঁজুন...',
              prefixIcon: Icon(Icons.search),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: surahs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = surahs[i];
              final isLastRead = lastSurah == s.number;
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReaderScreen(surah: s),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${s.number}',
                          style: TextStyle(
                            color: AppTheme.teal,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '${s.ayat} আয়াত • ${s.type}',
                                  style: TextStyle(
                                      fontSize: 11, color: subtext),
                                ),
                                if (isLastRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.teal.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      'সর্বশেষ পঠিত',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppTheme.teal,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isLastRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: AppTheme.teal,
                            shape: BoxShape.circle,
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        'পৃ. ${s.page}',
                        style: TextStyle(fontSize: 11, color: subtext),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ParaTab extends StatelessWidget {
  final Color subtext;

  const _ParaTab({required this.subtext});

  static const _paraNames = [
    'আলিফ লাম মিম',
    'সাইয়াকুল',
    'তিলকার রুসুল',
    'লান তানালুল',
    'ওয়াল মুহসানাত',
    'লা ইউহিব্বুল্লাহ',
    'ওয়া ইযা সামিউ',
    'ওয়া লাও আন্নানা',
    'কালাল মালাউ',
    'ওয়া আলামু',
    'ইআতাযিরুন',
    'ওয়ামা মিন দাব্বাহ',
    'ওয়ামা উবাররিউ',
    'রুব্বামা',
    'সুবহানাল্লাযি',
    'কালা আলাম',
    'ইক্তারাবা',
    'কাদ আফলাহা',
    'ওয়া কালাল্লাযিনা',
    'আম্মান খালাকা',
    'উতলু মা উহিয়া',
    'ওয়ামাই ইয়াকনুত',
    'ওয়ামা লিয়া',
    'ফামান আযলামু',
    'ইলাইহি ইউরাদ্দু',
    'হা-মিম',
    'কালা ফামা খাতবুকুম',
    'কাদ সামিআল্লাহ',
    'তাবারাকাল্লাযি',
    'আম্মা',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 30,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final paraNum = i + 1;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$paraNum',
                  style: TextStyle(
                    color: AppTheme.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'পারা $paraNum',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _paraNames[i],
                      style: TextStyle(fontSize: 12, color: subtext),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookmarkTab extends StatelessWidget {
  final Color subtext;

  const _BookmarkTab({required this.subtext});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final bookmarks = provider.bookmarks;

    if (bookmarks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border,
                size: 56, color: AppTheme.teal.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'কোনো বুকমার্ক নেই',
              style: TextStyle(color: subtext, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'পড়ার সময় 🔖 আইকনে চাপ দিয়ে\nবুকমার্ক সেভ করুন',
              textAlign: TextAlign.center,
              style: TextStyle(color: subtext.withOpacity(0.7), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: bookmarks.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final b = bookmarks[i];
        return ListTile(
          leading: Icon(Icons.bookmark, color: AppTheme.teal),
          title: Text(b.surahName,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text('পৃষ্ঠা ${b.page}',
              style: TextStyle(fontSize: 12, color: subtext)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: subtext),
            onPressed: () =>
                provider.removeBookmark(b.surahNumber, b.page),
          ),
          onTap: () {
            final surah = provider.surahs
                .firstWhere((s) => s.number == b.surahNumber);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ReaderScreen(surah: surah, initialPage: b.page),
              ),
            );
          },
        );
      },
    );
  }
}
