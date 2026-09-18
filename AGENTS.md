# Repository agent instructions

These instructions apply to every agent working in this repository. They exist
so a fallback model can resume work from evidence instead of reconstructing the
project from chat history.

## Start every resumed session here

Run these read-only checks before changing files:

```bash
git status --short
git log -8 --oneline
sed -n '1,260p' docs/SESSION_STATE.md
sed -n '1,320p' docs/PRODUCT_ROADMAP.md
sed -n '1,240p' docs/IMPLEMENTATION_PIPELINE.md
sed -n '1,320p' docs/ARTEMIS_TESTING.md
```

Then inspect the source files involved in the next unchecked roadmap item. Do
not infer the current implementation from README text, a previous assistant
message, or an old APK.

## Sources of truth

Use this order when sources disagree:

1. Current source code and Gradle configuration.
2. Reproducible test, build, emulator, and device output.
3. `docs/SESSION_STATE.md`, after comparing it with 1 and 2.
4. `docs/PRODUCT_ROADMAP.md` for intended future behavior.
5. Conversation summaries and previous assistant claims.

Never report an intended or documented feature as implemented until the code
and a relevant test prove it.

## Product invariants

- The product is a paper-first recall trainer for Korean JLPT learners. The user
  sees a kanji, writes it on paper, and then reveals the answer.
- Page navigation, study state, quizzes, progress, and purchases belong to the
  native Flutter shell.
- The target card flow is: cached PenX kanji image on the front, structured
  meaning/readings on reveal, and an optional sanitized PenX detail page in a
  WebView. The current release does not yet implement this complete target.
- Published app content is read-only. Only a PenX administrator may create or
  edit source posts. Draft/admin-only content must never be exposed by the app.
- The reviewed bundled N5 dataset must remain a working offline fallback.
- Current JLPT levels are estimates, not official lists. Preserve that notice
  and the KANJIDIC2 CC BY-SA attribution.
- Do not add a handwriting canvas, AI features, accounts, ads, or subscriptions
  unless the active user request explicitly expands scope.

## Work order

Follow the milestones and gates in `docs/PRODUCT_ROADMAP.md`. Unless the user
overrides the order, finish P0 release integrity before product expansion, then
finish the card pipeline before retention or monetization work.

Keep unrelated work separate. In particular:

- Do not combine crash diagnosis with UI redesign.
- Do not combine signing changes with feature changes.
- Do not remove or restore WebView merely as a guess at a crash cause.
- Do not overwrite or delete existing uncommitted user changes.

## Verification requirements

For Dart/Flutter changes, the minimum automated gate is:

```bash
flutter analyze
flutter test
```

For Android entrypoint, plugin, WebView, signing, or release changes, also:

1. Build the release APK or AAB that will actually ship.
2. Install the release APK on the connected emulator or physical device.
3. Cold-start the app and capture logcat for startup crashes.
4. Exercise home, study reveal, previous/next, persistence, quiz completion,
   offline fallback, and restart.
5. Verify the APK signature and record artifact checksum/size.

Use Google ARTEMIS as the AI mobile test runner after its model credential and
ADB device checks pass. Follow `docs/ARTEMIS_TESTING.md`. A direct ADB script is
a valid deterministic fallback, but label it as direct ADB testing. Never call
it an ARTEMIS run unless an ARTEMIS trace and final result exist.

Automated unit tests do not prove that an Android release starts. Do not call a
release "normal", "fixed", or "ready" without the applicable evidence above.

## Secrets and release safety

- Never print keystore passwords, API keys, tokens, or secret file contents.
- Never commit keystores or signing properties. `android/keystore.properties`
  is currently tracked and is a P0 security debt; remove it from Git tracking
  and assess rotation without exposing its contents.
- If an upload key was reused by another app, treat possible exposure as a
  cross-project incident and verify the affected apps before rotation.
- A GitHub artifact upload, Play Console upload, track promotion, and review
  submission are different actions. Do not claim one when only another ran.
- Do not submit or promote a Play production release without an explicit active
  user request.

## Continuity checkpoint

Before a long build, external wait, model fallback, or end of work:

1. Update `docs/SESSION_STATE.md` using verified facts only.
2. Record the exact next command or file to inspect.
3. Record tests that actually ran and their result.
4. Record blockers and decisions still requiring the user.
5. Keep generated artifacts out of commits.

Do not repeatedly re-check the checkpoint instead of doing the next listed
task. Read it once, validate the relevant fact, and continue.
