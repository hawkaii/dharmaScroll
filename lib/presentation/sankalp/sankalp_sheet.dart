import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/state/sankalp.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';

/// Seal one small intention from [verse]. The line is suggested from the
/// verse and the person may change it. Returns true when sealed.
Future<bool> showSankalpSheet(
  BuildContext context,
  Verse verse, {
  String? suggestion,
}) async {
  final bool? sealed = await showDSheet<bool>(
    context,
    (BuildContext ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SankalpSheet(
        verse: verse,
        suggestion: suggestion ?? context.l.intentionFor(verse.tags),
      ),
    ),
  );
  return sealed ?? false;
}

class SankalpSheet extends ConsumerStatefulWidget {
  const SankalpSheet({
    super.key,
    required this.verse,
    required this.suggestion,
  });

  final Verse verse;
  final String suggestion;

  @override
  ConsumerState<SankalpSheet> createState() => _SankalpSheetState();
}

class _SankalpSheetState extends ConsumerState<SankalpSheet> {
  late final TextEditingController _text = TextEditingController(
    text: widget.suggestion,
  );
  bool _sealed = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _seal() async {
    ref.read(sankalpProvider.notifier).seal(_text.text, widget.verse.id);
    FocusScope.of(context).unfocus();
    Haptics.success();
    SoundService.instance.play(Sfx.bowl);
    setState(() => _sealed = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return AnimatedSize(
      duration: Motion.snap,
      curve: Motion.easeOut,
      child: _sealed ? _done(c) : _form(c),
    );
  }

  Widget _done(DharmaColors c) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: Sp.s18),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: reduceMotion(context) ? 1 : 0.3,
              end: 1,
            ),
            duration: Motion.keepBloom,
            curve: Motion.spring,
            builder: (BuildContext context, double t, Widget? child) =>
                Transform.scale(scale: t, child: child),
            child: DIcon('butter-pot', size: 64, glow: true),
          ),
          const SizedBox(height: Sp.s14),
          Semantics(
            liveRegion: true,
            child: Text(
              context.l.sealedTitle,
              style: DType.title(c.ink, compact: true),
            ),
          ),
          const SizedBox(height: Sp.s6),
          Text(
            context.l.lookBackTomorrow,
            style: DType.body(c.mute, size: 17),
          ),
          const SizedBox(height: Sp.s22),
        ],
      ),
    );
  }

  Widget _form(DharmaColors c) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rad.row),
      borderSide: BorderSide(color: c.line),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(context.l.sealSankalpCaps, style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s6),
        Text(
          context.l.oneSmallIntention,
          style: DType.title(c.ink, compact: true),
        ),
        const SizedBox(height: Sp.s6),
        Text(
          context.l.fromGitaChange(widget.verse.id),
          style: DType.body(c.mute, size: 16),
        ),
        const SizedBox(height: Sp.s18),
        TextField(
          controller: _text,
          maxLength: SankalpNotifier.maxLength,
          minLines: 2,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: Tok.marigold,
          style: DType.body(c.ink, size: 21),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: c.raised.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.all(Sp.s18),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: Tok.marigold),
            ),
            semanticCounterText: '',
          ),
        ),
        const SizedBox(height: Sp.s18),
        PrimaryButton(
          label: context.l.sealIt,
          semanticLabel: context.l.sealSankalpSemantic,
          onPressed: _text.text.trim().isEmpty ? null : _seal,
        ),
      ],
    );
  }
}

/// On Today: an earlier Sankalp, looked back on with two equal answers.
class SankalpLookBack extends ConsumerStatefulWidget {
  const SankalpLookBack({super.key});

  @override
  ConsumerState<SankalpLookBack> createState() => _SankalpLookBackState();
}

class _SankalpLookBackState extends ConsumerState<SankalpLookBack> {
  /// The reply shown after answering, for this visit only.
  String? _reply;

  void _answer(bool kept) {
    final int pts = ref.read(sankalpProvider.notifier).lookBack(kept: kept);
    Haptics.soft();
    SoundService.instance.play(Sfx.chime);
    final String reply = kept ? context.l.replyKept : context.l.replyLetGo;
    setState(() => _reply = '$reply${pts > 0 ? '  +$pts' : ''}');
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(sankalpProvider);
    final Sankalp? s = ref.read(sankalpProvider.notifier).waiting;
    final DharmaColors c = context.c;
    if (s == null && _reply == null) return const SizedBox.shrink();
    return Padding(
      // Bottom gap keeps the card off the Today button when the calendar
      // line is also showing.
      padding: const EdgeInsets.symmetric(vertical: Sp.s12),
      child: DCard(
        padding: const EdgeInsets.fromLTRB(Sp.s18, Sp.s14, Sp.s18, Sp.s6),
        child: _Resize(
          child: _reply != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: Sp.s12),
                  child: Row(
                    children: <Widget>[
                      DIcon('butter-pot', size: 26, glow: true),
                      const SizedBox(width: Sp.s12),
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Text(
                            _reply!,
                            style: DType.body(c.ink, size: 17),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        DIcon('butter-pot', size: 20),
                        const SizedBox(width: Sp.s6),
                        Text(context.l.yourSankalpCaps, style: DType.eyebrow(c.accent)),
                      ],
                    ),
                    const SizedBox(height: Sp.s6),
                    Text(
                      s!.text,
                      style: DType.body(
                        c.ink,
                        size: 19,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextAction(
                            label: context.l.keptIt,
                            onPressed: () => _answer(true),
                          ),
                        ),
                        Container(width: 1, height: 22, color: c.line),
                        Expanded(
                          child: TextAction(
                            label: context.l.letItGo,
                            onPressed: () => _answer(false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// AnimatedSize, except under reduce motion: then the card swaps at once, so
/// Today's measured height stays true on the frame it changes.
class _Resize extends StatelessWidget {
  const _Resize({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => reduceMotion(context)
      ? child
      : AnimatedSize(duration: Motion.snap, child: child);
}
