# JLPT 한자 앱 — 세션 연속성 체크포인트

마지막 업데이트: 2026-09-18 09:44 GMT+9

## 현재 진행 상태

### 완료된 것
1. ✅ 파이프라인 문서 (`docs/IMPLEMENTATION_PIPELINE.md`)
2. ✅ N5 학습 + N5 테스트 모드 구현
3. ✅ `flutter analyze` 0건 / 테스트 6개 통과
4. ✅ 크래시 원인: AndroidManifest의 `com.codemeol.jlptkanji.MainActivity` 패키지가 실제/kotlin 경로와 불일치 → 수정 완료
5. ✅ Kotlin Android plugin 빌드 의존성 누락 → `build.gradle.kts`에 `id("org.jetbrains.kotlin.android")` 추가
6. ✅ 빈 `proguard-rules.pro` 생성 (R8 빌드 실패 수정)
7. ✅ Release APK 빌드 성공 (43MB) — JDK 21 WSL 설치로 해결
8. ✅ GitHub Release `v1.0.0` APK 교체 업로드 완료
9. ✅ AAB 빌드 성공 (40MB) — `build/app/outputs/bundle/release/app-release.aab`
10. ✅ `apksigner verify` — `CN=codeMeol` 서명 정상
11. ✅ 에뮬레이터 회귀 테스트 — 홈/학습/테스트 화면 모두 정상 진입
12. ✅ GitHub Release `v1.0.0`에 APK와 AAB 업로드 확인
13. ✅ 현재 구조 비교 및 제품·수익화 로드맵 (`docs/PRODUCT_ROADMAP.md`)
14. ✅ Fallback AI 실행 지침 (`AGENTS.md`)
15. ✅ ARTEMIS 설치·모델·ADB 환경 실측 및 실행 규약 (`docs/ARTEMIS_TESTING.md`)
16. ✅ Windows ADB와 ARTEMIS 연결; `emulator-5554` doctor OK
17. ✅ ARTEMIS Helper v6 설치·활성화
18. ✅ OpenClaw MCP config/rules 설치 및 MCP stdio 도구 5개 확인
19. ✅ Artemis Web UI `http://localhost:8000` 실행

### 남은 것
1. P0: `android/keystore.properties` Git 추적 제거 및 노출/회전 판단
2. P0: `aab.zip`, `android/build/` 생성물 정리와 ignore 확인
3. P0: JLPT 앱 전용 개인정보처리방침·라이선스 공개 링크 준비
4. P0: ARTEMIS UI 또는 로컬 `artemis init`으로 Google 모델 키 설정
5. P0: OpenClaw Gateway reload/restart 후 현재 세션에서 MCP 도구 노출 확인
6. P0: ARTEMIS Flash/Pro strict trace 생성
7. P1: PenX 이미지 앞면 + 답 공개 + 선택적 상세 WebView 구조 구현
8. P1: PenX runtime endpoint와 캐시/fallback 검증
9. Play Console 업로드 (bundle ID: `com.codemeol.jlptkanji`)
10. 스토어 자료(아이콘, 스크린샷, 설명) 준비

### 다음 작업자가 시작할 위치

1. 루트 `AGENTS.md`의 startup 명령 실행
2. `docs/PRODUCT_ROADMAP.md`의 P0부터 수행
3. signing 파일의 내용은 출력하지 말고 Git 추적 여부만 다룸
4. 현재 미커밋 파일을 임의 삭제하거나 덮어쓰지 않음
5. 모바일 테스트 전 `docs/ARTEMIS_TESTING.md`에서 현재 blocker와 증거 기준 확인

### ARTEMIS 현재 상태 (2026-09-18 09:44 KST 실측)

- ✅ `/home/meol7485/artemis`, 공식 Google 저장소, v1.0, commit `371aa6d`
- ✅ Python 3.13.15 가상환경과 uv 0.12.10
- ✅ Google provider 및 Gemini 모델 계열이 config에 선택됨
- ✅ Windows ADB에서 `emulator-5554`와 JLPT 패키지 확인
- ✅ ARTEMIS doctor에서도 emulator connected
- ✅ Helper v6 설치·활성화
- ✅ OpenClaw MCP 설정·rules 설치, stdio 도구 목록 검증
- ✅ Artemis UI/server 실행 (`http://localhost:8000`)
- ❌ Gemini/Google API key 없음
- ⏳ 실행 중 Gateway reload 후 MCP 도구 노출 확인 필요
- ❌ JLPT ARTEMIS AI trace 없음
- ⚠️ scrcpy 없음; 영상 replay 제한
- ⚠️ PATH 기본 OpenClaw CLI 2026.9.2는 구버전; 2026.9.4 절대 경로 사용
- 결론: 이전 UI 회귀는 직접 ADB 테스트이며 ARTEMIS AI 테스트 완료가 아님

### 현재 확인된 작업 트리

- 문서 작업: `README.md`, `docs/SESSION_STATE.md` 수정
- 문서 작업: `AGENTS.md`, `docs/PRODUCT_ROADMAP.md`, `docs/ARTEMIS_TESTING.md` 추가
- 추적 안 됨: `aab.zip`, `android/build/`

## 파일 경로
- Release APK: `build/app/outputs/flutter-apk/app-release.apk` (43MB)
- AAB: `build/app/outputs/bundle/release/app-release.aab` (40MB)
- Release 서명: `CN=codeMeol, OU=Mobile, O=codeMeol, L=Seoul, ST=Seoul, C=KR`
- GitHub Release: https://github.com/codeMeol/jlpt-kanji-app/releases/tag/v1.0.0

## 빌드 환경
- Flutter: `/mnt/d/git/flutter/flutter/bin/flutter`
- JAVA_HOME: `/tmp/jdk-21.0.12.1` (JDK 21 WSL 설치)
- Gradle: bundled via AGP 8.7.2
- Android SDK: `C:\Users\hjy74\AppData\Local\Android\Sdk`
- APK 서명 키스토어: `android/app/codeMeol.jks`

## 회귀 테스트 결과 (에뮬레이터 API 36)
- ✅ 앱 시작 → 홈 화면 정상
- ✅ "학습 시작" 버튼 → 학습 화면 진입
- ✅ "테스트 시작" 버튼 → 테스트 화면 진입
- ✅ N5 테스트 10문제 완료 (로그 확인)
