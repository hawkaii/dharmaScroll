import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_service.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';

enum _Stage { choose, phone, code }

/// The three ways in: Google, phone (with a code), or as a guest.
/// Calls [onDone] once someone is signed in. All of it is pretend for now:
/// see `FakeAuthService`.
class SignInPanel extends ConsumerStatefulWidget {
  const SignInPanel({super.key, required this.onDone, this.allowGuest = true});

  final VoidCallback onDone;
  final bool allowGuest;

  @override
  ConsumerState<SignInPanel> createState() => _SignInPanelState();
}

class _SignInPanelState extends ConsumerState<SignInPanel> {
  _Stage _stage = _Stage.choose;
  final TextEditingController _phone = TextEditingController.fromValue(
    const TextEditingValue(
      text: '+91 ',
      selection: TextSelection.collapsed(offset: 4),
    ),
  );
  final TextEditingController _code = TextEditingController();
  String? _error;
  bool _busy = false;

  String get _digits => _phone.text.replaceAll(RegExp(r'\D'), '');

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() f, {VoidCallback? then}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await f();
      if (!mounted) return;
      setState(() => _busy = false);
      (then ?? widget.onDone)();
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final AuthNotifier auth = ref.read(authProvider.notifier);
    final Widget? error = _error == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: Sp.s12),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: DType.body(c.rose, size: 16),
            ),
          );
    return AnimatedSwitcher(
      duration: Motion.select,
      child: switch (_stage) {
        _Stage.choose => Column(
          key: const ValueKey<_Stage>(_Stage.choose),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SecondaryButton(
              label: l.signInGoogle,
              onPressed: () => _run(auth.google),
            ),
            const SizedBox(height: Sp.s12),
            SecondaryButton(
              label: l.signInPhone,
              onPressed: () => setState(() => _stage = _Stage.phone),
            ),
            if (widget.allowGuest) ...<Widget>[
              const SizedBox(height: Sp.s6),
              TextAction(
                label: l.signInGuest,
                onPressed: () => _run(auth.guest),
              ),
            ],
          ],
        ),
        _Stage.phone => Column(
          key: const ValueKey<_Stage>(_Stage.phone),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Semantics(
              label: l.phoneNumber,
              child: TextField(
                controller: _phone,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
                ],
                textAlign: TextAlign.center,
                style: DType.body(c.ink, size: 24),
                decoration: InputDecoration(
                  hintText: '+91 98765 43210',
                  hintStyle: DType.body(c.faint, size: 24),
                ),
              ),
            ),
            const SizedBox(height: Sp.s12),
            Text(
              l.codeNote,
              textAlign: TextAlign.center,
              style: DType.body(c.mute, size: 16),
            ),
            ?error,
            const SizedBox(height: Sp.s18),
            PrimaryButton(
              label: l.sendCode,
              onPressed: _busy
                  ? null
                  : () => _run(
                      () => auth.sendCode(_digits),
                      then: () => setState(() => _stage = _Stage.code),
                    ),
            ),
            TextAction(
              label: l.otherWays,
              onPressed: () => setState(() {
                _stage = _Stage.choose;
                _error = null;
              }),
            ),
          ],
        ),
        _Stage.code => Column(
          key: const ValueKey<_Stage>(_Stage.code),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l.codeSentTo(_phone.text.trim()),
              textAlign: TextAlign.center,
              style: DType.body(c.mute, size: 16),
            ),
            const SizedBox(height: Sp.s12),
            _CodeBoxes(controller: _code, onChanged: () => setState(() {})),
            ?error,
            const SizedBox(height: Sp.s18),
            PrimaryButton(
              label: l.verify,
              onPressed: _busy || _code.text.length < 6
                  ? null
                  : () => _run(() => auth.verify(_digits, _code.text)),
            ),
            TextAction(
              label: l.changeNumber,
              onPressed: () => setState(() {
                _stage = _Stage.phone;
                _code.clear();
                _error = null;
              }),
            ),
          ],
        ),
      },
    );
  }
}

/// Six boxes over one hidden field: the keyboard, paste and autofill work as
/// for any text field.
class _CodeBoxes extends StatelessWidget {
  const _CodeBoxes({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final String v = controller.text;
    return SizedBox(
      height: 60,
      child: Stack(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < 6; i++)
                AnimatedContainer(
                  duration: Motion.select,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 44,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: i < v.length
                        ? Tok.marigold.withValues(alpha: 0.09)
                        : null,
                    border: Border.all(
                      color: i == v.length ? Tok.marigold : c.line,
                    ),
                  ),
                  child: Text(
                    i < v.length ? v[i] : '',
                    style: DType.hero(c.verse, size: 28),
                  ),
                ),
            ],
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              // Hidden to the eye, not to a screen reader.
              alwaysIncludeSemantics: true,
              child: Semantics(
                label: context.l.sixNumberCode,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const <String>[AutofillHints.oneTimeCode],
                  maxLength: 6,
                  showCursor: false,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(counterText: ''),
                  onChanged: (_) {
                    Haptics.tick();
                    onChanged();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
