# JLPT 한자 쓰기

한자를 먼저 보고 직접 써 본 뒤, 카드를 눌러 읽기와 뜻을 확인하는 Android
학습 앱입니다. 화면 이동과 복습 상태는 Flutter가 담당하고 카드 본문은
WebView로 표시합니다.

기본 설치본에는 검수된 N5 추정 데이터 103자가 포함됩니다. 빌드 시
`--dart-define=PENX_BOARD_ID=<id>`를 지정하면 같은 카드 형식의 PenX
게시물을 우선 불러오며, 네트워크 실패 시 내장 데이터로 돌아갑니다.

## Data

KANJIDIC2 기반 파생 데이터는 CC BY-SA 4.0으로 제공됩니다. 자세한 출처와
현행 JLPT 급수 분류에 관한 고지는 `assets/legal/THIRD_PARTY_NOTICES.md`를
참조하세요.

전체 데이터·PenX·앱·검증·출시 흐름은
[`docs/IMPLEMENTATION_PIPELINE.md`](docs/IMPLEMENTATION_PIPELINE.md)에 고정합니다.
