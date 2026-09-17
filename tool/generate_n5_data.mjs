import fs from 'node:fs';

const [kanjidicPath, outputPath] = process.argv.slice(2);
if (!kanjidicPath || !outputPath) {
  throw new Error('Usage: node tool/generate_n5_data.mjs <kanjidic2.xml> <output.json>');
}

const koreanMeanings = {
  '安':'편안할 안','一':'한 일','飲':'마실 음','右':'오른 우','雨':'비 우','駅':'역 역',
  '円':'둥글 원','下':'아래 하','何':'어찌 하','火':'불 화','花':'꽃 화','会':'모일 회',
  '外':'바깥 외','学':'배울 학','間':'사이 간','気':'기운 기','休':'쉴 휴','魚':'물고기 어',
  '金':'쇠 금','九':'아홉 구','空':'빌 공','月':'달 월','見':'볼 견','言':'말씀 언',
  '古':'옛 고','五':'다섯 오','午':'낮 오','後':'뒤 후','語':'말씀 어','口':'입 구',
  '校':'학교 교','行':'다닐 행','高':'높을 고','国':'나라 국','今':'이제 금','左':'왼 좌',
  '三':'석 삼','山':'메 산','四':'넉 사','子':'아들 자','時':'때 시','耳':'귀 이',
  '七':'일곱 칠','社':'모일 사','車':'수레 차','手':'손 수','週':'주일 주','十':'열 십',
  '出':'날 출','書':'글 서','女':'여자 녀','小':'작을 소','少':'적을 소','上':'위 상',
  '食':'먹을 식','新':'새 신','人':'사람 인','水':'물 수','生':'날 생','西':'서녘 서',
  '先':'먼저 선','千':'일천 천','川':'내 천','前':'앞 전','足':'발 족','多':'많을 다',
  '大':'큰 대','男':'사내 남','中':'가운데 중','長':'길 장','天':'하늘 천','店':'가게 점',
  '電':'번개 전','土':'흙 토','東':'동녘 동','道':'길 도','読':'읽을 독','南':'남녘 남',
  '二':'두 이','日':'날 일','入':'들 입','年':'해 년','買':'살 매','白':'흰 백',
  '八':'여덟 팔','半':'반 반','百':'일백 백','父':'아버지 부','分':'나눌 분','聞':'들을 문',
  '母':'어머니 모','北':'북녘 북','本':'근본 본','毎':'매양 매','万':'일만 만','名':'이름 명',
  '木':'나무 목','目':'눈 목','友':'벗 우','来':'올 래','立':'설 립','六':'여섯 육','話':'말씀 화',
};

const decodeXml = (value) => value
  .replaceAll('&amp;', '&')
  .replaceAll('&lt;', '<')
  .replaceAll('&gt;', '>')
  .replaceAll('&quot;', '"')
  .replaceAll('&apos;', "'");

const text = fs.readFileSync(kanjidicPath, 'utf8');
const blocks = text.match(/<character>[\s\S]*?<\/character>/g) ?? [];

const cards = blocks
  .filter((block) => /<jlpt>4<\/jlpt>/.test(block))
  .map((block) => {
    const literal = decodeXml(block.match(/<literal>(.*?)<\/literal>/)?.[1] ?? '');
    const strokeCount = Number(block.match(/<stroke_count>(\d+)<\/stroke_count>/)?.[1] ?? 0);
    const frequency = Number(block.match(/<freq>(\d+)<\/freq>/)?.[1] ?? 99999);
    const radicalNumber = Number(block.match(/<rad_value rad_type="classical">(\d+)<\/rad_value>/)?.[1] ?? 0);
    const getReadings = (type) => [...block.matchAll(new RegExp(`<reading r_type="${type}">(.*?)<\\/reading>`, 'g'))]
      .map((match) => decodeXml(match[1]));
    const meaningsEn = [...block.matchAll(/<meaning>(.*?)<\/meaning>/g)]
      .map((match) => decodeXml(match[1]));

    if (!koreanMeanings[literal]) {
      throw new Error(`Missing Korean meaning for ${literal}`);
    }

    return {
      id: literal.codePointAt(0).toString(16).toUpperCase(),
      kanji: literal,
      level: 'N5',
      meaningKo: koreanMeanings[literal],
      koreanReadings: getReadings('korean_r'),
      onReadings: getReadings('ja_on'),
      kunReadings: getReadings('ja_kun'),
      meaningsEn,
      strokeCount,
      radicalNumber,
      frequency,
      sourceRefs: ['KANJIDIC2'],
    };
  })
  .sort((a, b) => a.frequency - b.frequency || a.kanji.localeCompare(b.kanji));

if (cards.length !== 103) {
  throw new Error(`Expected 103 legacy JLPT level 4 cards, got ${cards.length}`);
}

const payload = {
  schemaVersion: 1,
  generatedAt: new Date().toISOString(),
  levelNoticeKo: '현행 JLPT는 공식 한자 목록을 공개하지 않습니다. 이 N5 분류는 KANJIDIC2의 구 JLPT 4급 정보를 기반으로 한 학습용 추정치입니다.',
  sources: [
    {
      id: 'KANJIDIC2',
      url: 'https://www.edrdg.org/wiki/index.php/KANJIDIC_Project',
      license: 'CC BY-SA 4.0',
      licenseUrl: 'https://www.edrdg.org/edrdg/licence.html',
    },
  ],
  cards,
};

fs.mkdirSync(new URL('../assets/data/', import.meta.url), { recursive: true });
fs.writeFileSync(outputPath, `${JSON.stringify(payload, null, 2)}\n`);
console.log(`Generated ${cards.length} cards at ${outputPath}`);
