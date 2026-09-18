# JLPT 한자 쓰기

한자를 먼저 보고 직접 써 본 뒤, 카드를 눌러 읽기와 뜻을 확인하는 Android
학습 앱입니다. N5 103자 중 무작위 10문제를 푸는 4지선다 테스트도 포함합니다.
현재 릴리스는 카드와 화면 이동을 Flutter 네이티브로 표시합니다. 목표 구조는
이미지 앞면과 답 공개는 네이티브로 유지하고, PenX의 긴 설명만 선택적으로
WebView에서 표시하는 하이브리드 방식입니다.

기본 설치본에는 검수된 N5 추정 데이터 103자가 포함됩니다. 빌드 시
`--dart-define=PENX_BOARD_ID=<id>`를 지정하면 같은 카드 형식의 PenX
게시물을 우선 불러오며, 네트워크 실패 시 내장 데이터로 돌아갑니다.

## Data

KANJIDIC2 기반 파생 데이터는 CC BY-SA 4.0으로 제공됩니다. 자세한 출처와
현행 JLPT 급수 분류에 관한 고지는 `assets/legal/THIRD_PARTY_NOTICES.md`를
참조하세요.

전체 데이터·PenX·앱·검증·출시 흐름은
[`docs/IMPLEMENTATION_PIPELINE.md`](docs/IMPLEMENTATION_PIPELINE.md)에 고정합니다.

현재 구현과 목표 구조의 차이, 단계별 제품·수익화 계획은
[`docs/PRODUCT_ROADMAP.md`](docs/PRODUCT_ROADMAP.md)를 참조하세요. 작업을
이어받는 에이전트는 루트의 [`AGENTS.md`](AGENTS.md)와
[`docs/SESSION_STATE.md`](docs/SESSION_STATE.md)를 먼저 확인해야 합니다.

Google ARTEMIS 기반 모바일 회귀 테스트의 실제 환경 상태, 연결 절차, 증거
기준은 [`docs/ARTEMIS_TESTING.md`](docs/ARTEMIS_TESTING.md)에 기록합니다.
