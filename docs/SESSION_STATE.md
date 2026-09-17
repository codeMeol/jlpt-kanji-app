# JLPT 한자 앱 — 세션 연속성 체크포인트

마지막 업데이트: 2026-09-17 18:05 GMT+9

## 현재 진행 상태

### 완료된 것
1. ✅ 파이프라인 문서 (`docs/IMPLEMENTATION_PIPELINE.md`)
2. ✅ N5 학습 + N5 테스트 모드 구현
3. ✅ `flutter analyze` 0건 / 테스트 6개 통과
4. ✅ 크래시 원인: AndroidManifest 패키지와 kotlin 패키지 불일치 → `jlptkanji/`로 통일
5. ✅ Kotlin Android plugin 빌드 의존성 누락 → `build.gradle.kts`에 `id("org.jetbrains.kotlin.android")` 추가
6. ✅ 빈 `proguard-rules.pro` 생성 (R8 빌드 실패 수정)
7. ✅ `org.gradle.java.home=C:/Program Files/Android/Android Studio/jbr` → `gradle.properties`에 추가
8. ✅ Release APK 빌드 성공 → GitHub Release v1.0.0 갱신 완료
9. ✅ `test/android_entrypoint_test.dart` 추가 (패키지 불일치 회귀 방지)
10. ✅ 회귀 테스트 7/7 통과 (에뮬레이터 API 36에서 실제 동작 확인)
11. ✅ Release APK 서명 검증 완료 (apksigner)
12. ✅ AAB 생성 완료

### 다음 할 일
1. AAB를 Play Console 내부 테스트에 제출
2. ARTEMIS 멀티모달 API 키 획득 후 자연어 시나리오 실행

## 참고: ARTEMIS
- Windows `C:\artemis`에 설치됨
- 에뮬레이터 ADB 직번 인식 (`emulator-5554`)
- 멀티모달 모델 키 필요 (Gemini/OpenAI) — 아직 미연결
- 키 획득 후: `python -m artemis run --adb_serial emulator-5554`로 자연어 시나리오 실행 가능

## 커밋 히스토리
- `cb79cc1` fix: set org.gradle.java.home in gradle.properties for WSL builds
- `b5e130a` fix: add Kotlin plugin, orphan MainActivity, and proguard rules  
- `f6f29b5` fix: correct MainActivity package to match applicationId
- `4be9b58` feat: add N5 quiz mode

## APK/AAB 정보
- Release APK: `build/app/outputs/flutter-apk/app-release.apk` (44MB, SHA1: 39f5b8c0...)
- GitHub Release: v1.0.0 (app-release.apk 45,978,246바이트)
- AAB: `build/app/outputs/flutter-apk/app-release.aab`
- 서명 키: `/home/meol7485/.android-keys/poker-club-manager/upload-keystore.jks`
