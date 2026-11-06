import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/choice_chip_tag.dart';

/// Book mode: the answer to "where am I" for the serious reader.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';

  static const List<
    ({int chapter, String name, int verses, int read, double progress})
  >
  _chapters =
      <({int chapter, String name, int verses, int read, double progress})>[
        (
          chapter: 1,
          name: 'Arjuna Vishada Yoga',
          verses: 47,
          read: 47,
          progress: 1,
        ),
        (chapter: 2, name: 'Sankhya Yoga', verses: 72, read: 43, progress: 0.6),
        (chapter: 3, name: 'Karma Yoga', verses: 43, read: 5, progress: 0.12),
        (
          chapter: 4,
          name: 'Jnana Karma Sannyasa',
          verses: 42,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 5,
          name: 'Karma Sannyasa Yoga',
          verses: 29,
          read: 0,
          progress: 0,
        ),
        (chapter: 6, name: 'Dhyana Yoga', verses: 47, read: 0, progress: 0),
        (
          chapter: 7,
          name: 'Jnana Vijnana Yoga',
          verses: 30,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 8,
          name: 'Aksara Brahma Yoga',
          verses: 28,
          read: 0,
          progress: 0,
        ),
        (chapter: 9, name: 'Raja Vidya Yoga', verses: 34, read: 0, progress: 0),
        (chapter: 10, name: 'Vibhuti Yoga', verses: 42, read: 0, progress: 0),
        (
          chapter: 11,
          name: 'Visvarupa Darshana',
          verses: 55,
          read: 0,
          progress: 0,
        ),
        (chapter: 12, name: 'Bhakti Yoga', verses: 20, read: 0, progress: 0),
        (
          chapter: 13,
          name: 'Kshetra Kshetrajna',
          verses: 35,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 14,
          name: 'Gunatraya Vibhaga',
          verses: 27,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 15,
          name: 'Purushottama Yoga',
          verses: 20,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 16,
          name: 'Daivasura Sampad',
          verses: 24,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 17,
          name: 'Shraddhatraya Vibhaga',
          verses: 28,
          read: 0,
          progress: 0,
        ),
        (
          chapter: 18,
          name: 'Moksha Sannyasa Yoga',
          verses: 78,
          read: 0,
          progress: 0,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final String query = _query.trim().toLowerCase();
    final List<
      ({int chapter, String name, int verses, int read, double progress})
    >
    results = query.isEmpty
        ? _chapters
        : _chapters
              .where(
                (
                  ({
                    int chapter,
                    String name,
                    int verses,
                    int read,
                    double progress,
                  })
                  c,
                ) =>
                    c.name.toLowerCase().contains(query) ||
                    c.chapter.toString() == query,
              )
              .toList();

    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      appBar: AppBar(
        title: Text(
          'Library',
          style: AppType.t1.copyWith(color: context.colors.ink),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s20,
          0,
          AppSpace.s20,
          AppSpace.s32,
        ),
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s16,
              vertical: AppSpace.s12,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceRaised,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.thin,
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, size: 18, color: context.colors.inkMuted),
                const SizedBox(width: AppSpace.s8),
                Expanded(
                  child: TextField(
                    onChanged: (String value) => setState(() => _query = value),
                    style: AppType.b2.copyWith(color: context.colors.ink),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'Search "anger", "2.47", "Arjuna"',
                      hintStyle: AppType.b3.copyWith(
                        color: context.colors.inkFaint,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          Wrap(
            spacing: AppSpace.s8,
            children: <Widget>[
              const ChoiceChipTag(label: 'Bhagavad Gita', selected: true),
              const ChoiceChipTag(label: 'Ramayana · soon'),
              const ChoiceChipTag(label: 'Upanishads · soon'),
            ],
          ),
          const SizedBox(height: AppSpace.s16),
          if (results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s40),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.search_off,
                    size: 40,
                    color: context.colors.inkFaint,
                  ),
                  const SizedBox(height: AppSpace.s12),
                  Text(
                    'Kuch nahi mila. \'2.47\' ya \'gussa\' try karein.',
                    textAlign: TextAlign.center,
                    style: AppType.b3.copyWith(color: context.colors.inkMuted),
                  ),
                ],
              ),
            )
          else
            for (final ({
                  int chapter,
                  String name,
                  int verses,
                  int read,
                  double progress,
                })
                chapter
                in results)
              _ChapterRow(
                chapter: chapter.chapter,
                name: chapter.name,
                verses: chapter.verses,
                read: chapter.read,
                progress: chapter.progress,
              ),
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.chapter,
    required this.name,
    required this.verses,
    required this.read,
    required this.progress,
  });

  final int chapter;
  final String name;
  final int verses;
  final int read;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final bool locked = chapter > 3;

    return Opacity(
      opacity: locked ? 0.6 : 1,
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: context.colors.borderQuiet, width: 1),
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 34,
              child: Text(
                '$chapter',
                style: AppType.d3.copyWith(color: context.colors.field),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: AppType.h1.copyWith(color: context.colors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locked
                        ? 'opens in week $chapter · $verses shlokas'
                        : '$verses shlokas',
                    style: AppType.c1.copyWith(color: context.colors.inkFaint),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.s8),
            if (locked)
              Icon(Icons.lock_outline, size: 15, color: context.colors.inkFaint)
            else
              Text(
                progress >= 1 ? 'read' : '${(progress * 100).round()}%',
                style: AppType.m1.copyWith(
                  fontSize: 9,
                  color: progress >= 1
                      ? context.colors.success
                      : context.colors.inkMuted,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
