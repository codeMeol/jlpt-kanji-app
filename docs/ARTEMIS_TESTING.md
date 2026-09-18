# ARTEMIS 모바일 테스트 환경·실행 규약

마지막 실측: 2026-09-18 09:44 KST

이 문서는 Google ARTEMIS를 JLPT 앱의 AI 기반 모바일 테스트 러너로 사용하는
방법과 현재 환경의 실제 연결 상태를 기록한다. 설치 사실, ADB 수동 테스트,
ARTEMIS AI 실행은 서로 다른 상태다.

## 1. 테스트 계층

릴리스 검증은 아래 순서로 수행한다.

1. `flutter analyze`와 `flutter test`
2. release APK 빌드·서명 검증
3. 직접 ADB로 설치·cold start·logcat 스모크 테스트
4. ARTEMIS Flash로 짧고 반복 가능한 UI 흐름
5. ARTEMIS Pro `strict`로 릴리스 후보 전체 회귀와 최종 검증
6. 가능한 경우 물리 기기 수동 확인

ARTEMIS는 단위 테스트나 직접 ADB 진단을 대체하지 않는다. 모델이 성공했다고
말한 것만으로 통과 처리하지 않고 trace, 스크린샷, 최종 보고서와 앱 로그를
함께 확인한다.

## 2. 현재 실측 환경

### ARTEMIS

- 공식 저장소: `https://github.com/google/artemis.git`
- Linux 경로: `/home/meol7485/artemis`
- 확인 커밋: `371aa6d`
- 버전: ARTEMIS Agent Platform `v1.0`
- 가상환경: `/home/meol7485/artemis/.venv`
- Python: `3.13.15`
- uv: `0.12.10`
- 설정 파일: `/home/meol7485/artemis/config/artemis.jsonc`
- 환경 파일: `/home/meol7485/artemis/.env` — 값은 출력하거나 커밋하지 않는다.

### Google 테스트 모델 설정

ARTEMIS 구성의 기본 provider는 Google이며 현재 설정상 다음 모델 계열을
사용하도록 되어 있다.

- Planner 기본: `gemini-3.8-flash`
- Planner fallback: `gemini-3.7-flash`
- 위치 탐색용 모델: `gemini-robotics-er-2-preview`
- 기본 실행 profile: `flash`

이것은 **모델 선택 설정**일 뿐, 인증과 실행 성공을 뜻하지 않는다. 마지막
점검에서는 `GEMINI_API_KEY`와 `GOOGLE_API_KEY`가 비어 있어 AI 작업을 실행할
수 없었다. 키는 채팅에 보내지 말고 다음 대화형 명령으로 로컬에 설정한다.

```bash
cd /home/meol7485/artemis
uv run artemis init
```

### Android 에뮬레이터

- Windows AVD: `JLPT_Test_API36`
- 연결 serial: `emulator-5554`
- Android: 16 / API 36
- 모델: `sdk_gphone64_x86_64`
- 화면: `1080x2400`
- 설치 확인 패키지: `com.codemeol.jlptkanji`
- Windows SDK:
  `C:\Users\hjy74\AppData\Local\Android\Sdk`

Windows ADB server를 `0.0.0.0:5037`에 listen하도록 시작하고 ARTEMIS의
`ADB_HOST`를 현재 WSL gateway `172.29.64.1`로 지정했다. `adbutils`와
`artemis doctor` 모두 `emulator-5554`를 connected로 확인한다. WSL gateway
주소는 WSL 재시작 후 바뀔 수 있으므로 연결 실패 시 `ip route`와 Windows
ADB listen 주소를 다시 확인한다.

### 현재 미완료 상태

- ARTEMIS Multimodal LLM API key 없음 — 유일한 필수 blocker
- ARTEMIS Web UI/server는 `http://localhost:8000`에서 실행 중
- Accessibility Helper v6 설치·활성화됨; protocol 2 응답 확인
- Windows 원격 ADB가 만든 forward를 WSL loopback으로 조회하던 문제는 로컬
  Artemis의 `helper_manager.py`가 원격 ADB host를 사용하도록 보정함
- OpenClaw MCP 설정·rules 설치 완료, config validation과 MCP stdio 도구 5개 확인
- 현재 실행 중인 OpenClaw Gateway에는 아직 reload/restart가 필요함
- `scrcpy` 없음: 화면 스트리밍·동영상 replay는 제한됨
- `traces/`에 완료된 JLPT ARTEMIS 실행 기록 없음

그러므로 과거의 에뮬레이터 UI 확인은 **직접 ADB 회귀 테스트**이며,
**ARTEMIS AI 회귀 테스트 통과로 기록하면 안 된다.** 첫 AI trace는 로컬에서
Google 키를 설정한 뒤 생성한다.

### 2026-09-18 연결 작업 기록

- OpenClaw config backup:
  `/home/meol7485/.openclaw/backups/openclaw.json.pre-artemis-20260918-0920`
- OpenClaw MCP config/rules 설치:
  `/home/meol7485/.openclaw/openclaw.json`, `OPENCLAW.md`, `rules/artemis.md`
- MCP stdio 초기화 성공; 노출 도구:
  `mobile_get_device_state`, `mobile_diagnose`, `mobile_inspect_trace`,
  `mobile_manage_task`, `mobile_run_task`
- `mobile_diagnose`: 필수 점검 4/5 통과, Google 모델 키만 필수 blocker
- OpenClaw CLI는 Gateway와 동일한 `2026.9.4` 경로를 사용해야 함:
  `/home/meol7485/.nvm/versions/node/v24.16.0/bin/openclaw`
- PATH의 구버전 `2026.9.2` CLI는 현재 schema 17 DB를 읽지 못하므로 사용 금지

## 3. 연결 완료 절차

### 3.1 사전 진단

```bash
cd /home/meol7485/artemis
uv run artemis --version
uv run artemis doctor
uv run artemis status
```

### 3.2 ADB 경로 통일

Windows `adb.exe`와 Linux ADB 서버 중 하나만 ARTEMIS의 기준 endpoint로
선택한다. 현재는 두 서버가 분리돼 있으므로 다음 작업자는:

1. 실행 중인 에뮬레이터를 Windows ADB에서 확인한다.
2. ARTEMIS `.env`의 `ADB_HOST`/`ADB_PORT`가 실제 기기 목록을 반환하는 ADB
   server를 가리키게 한다.
3. `adbutils.AdbClient(...).device_list()`와 `artemis doctor` 양쪽에서
   `emulator-5554`가 보이는지 확인한다.

ADB server 재시작은 다른 Android 작업을 끊을 수 있으므로 실행 전에 현재
프로세스와 연결 기기를 확인한다. 확인 없이 Windows와 Linux ADB server를
번갈아 시작하지 않는다.

### 3.3 로컬에서 모델 인증

```bash
cd /home/meol7485/artemis
uv run artemis init
uv run artemis doctor
```

`doctor`에서 최소한 다음 두 항목이 OK여야 한다.

- Multimodal LLM API Key
- Device / Emulator Connected

### 3.4 OpenClaw MCP 연결

설정 변경 전 현재 OpenClaw MCP 구성을 백업·확인한 다음 ARTEMIS 공식 설치
명령을 사용한다.

```bash
cd /home/meol7485/artemis
uv run artemis mcp --generate-config openclaw
uv run artemis mcp --install openclaw
```

설치 후 새 OpenClaw 세션에서 ARTEMIS 모바일 도구가 노출되는지 확인한다.
MCP host가 실행 가능하다는 `doctor` 결과와 OpenClaw에 실제 도구가 등록된
상태는 다르므로 둘 다 확인한다.

### 3.5 Helper와 선택 도구

```bash
cd /home/meol7485/artemis
uv run artemis helper install
uv run artemis helper status
```

영상 replay가 필요하면 `scrcpy`와 FFmpeg를 설치한다. 영상이 없어도 XML과
스크린샷 기반 테스트는 가능하지만 최종 보고서에 제한을 기록한다.

## 4. JLPT 앱 ARTEMIS 회귀 시나리오

### Flash — 빠른 스모크

- release APK 설치
- 앱 cold start
- 홈에서 `학습 시작`과 `테스트 시작` 확인
- 학습 화면 진입, 카드 reveal, 다음/이전
- 홈 복귀, 시험 화면 진입
- crash dialog와 ANR 없음 확인

예시 명령:

```bash
cd /home/meol7485/artemis
uv run artemis run \
  "Install and cold-start the JLPT app. Verify Home, Study reveal, Previous/Next, and Quiz entry without crash or ANR. Return observed evidence." \
  --profile flash \
  --device-serial emulator-5554 \
  --locked-app com.codemeol.jlptkanji \
  --app-path /home/meol7485/jlpt-kanji-app/build/app/outputs/flutter-apk/app-release.apk \
  --test-name jlpt-release-smoke \
  --traces-path /home/meol7485/jlpt-kanji-app/artifacts/artemis
```

### Pro strict — 릴리스 후보

- 앱 데이터 초기화 후 첫 실행
- 내장 N5 카드 로드와 오프라인 fallback
- reveal 전/후 내용 검증
- 이전/다음/셔플과 앱 재시작 후 위치 보존
- 모름/암기 상태 보존(구현된 범위만)
- N5 10문제 완료, 점수·최고점·재시험
- 빠른 화면 전환과 반복 cold start
- logcat에 fatal exception/ANR 없음

예시 명령:

```bash
cd /home/meol7485/artemis
uv run artemis run \
  "Run the complete JLPT release regression. Verify every observed result, collect screenshots and crash evidence, and fail if any checkpoint cannot be proven." \
  --profile pro \
  --verification-level strict \
  --device-serial emulator-5554 \
  --locked-app com.codemeol.jlptkanji \
  --app-path /home/meol7485/jlpt-kanji-app/build/app/outputs/flutter-apk/app-release.apk \
  --test-name jlpt-release-pro-strict \
  --traces-path /home/meol7485/jlpt-kanji-app/artifacts/artemis
```

## 5. 통과 증거

ARTEMIS 테스트를 완료라고 기록하려면 다음을 체크포인트에 남긴다.

- ARTEMIS commit/version
- 모델 provider와 profile (키 값은 금지)
- emulator serial/API
- APK SHA-256와 versionCode/versionName
- 실행 명령 또는 test name
- trace ID와 trace 경로
- 각 checkpoint pass/fail
- 최종 보고서
- logcat fatal/ANR 검색 결과
- 발견된 결함과 재현 단계

trace가 없거나 모델 키·기기 연결이 막힌 경우 결과를 `ARTEMIS 미실행`으로
표기하고 직접 ADB 테스트 결과와 섞지 않는다.
