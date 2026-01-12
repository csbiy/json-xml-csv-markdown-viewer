# Play Store 출시 정보

## 앱 정보

### 앱 이름 (30자 제한)
```
Data Viewer - JSON XML CSV MD
```

### 짧은 설명 (80자 제한)
```
JSON, XML, CSV, Markdown 파일을 쉽게 보고 편집하세요. 포맷팅, 검색, 내보내기 지원.
```

### 전체 설명 (4000자 제한)
```
📄 Data Viewer는 개발자와 데이터 분석가를 위한 올인원 파일 뷰어입니다.

🔍 주요 기능:
• JSON: 트리 뷰로 구조 확인, Pretty Print/Minify, 경로 복사 ($.users[0].name)
• XML: 트리 뷰, XPath 검색 (//tag, //tag[@attr='value']), 요소 복사
• CSV: 테이블 뷰, 열 정렬/필터링, 행/열 추가/삭제
• Markdown: 실시간 프리뷰, 분할 화면 에디터, 포맷팅 툴바

✨ 편집 기능:
• 구문 하이라이팅으로 가독성 향상
• 실시간 유효성 검사 (JSON, XML)
• Undo/Redo 지원
• 자동 저장 옵션

📁 파일 관리:
• 로컬 파일 열기
• 클립보드에서 가져오기
• 최근 파일 목록
• 파일 내보내기 (공유)

🎨 사용자 설정:
• 다크/라이트 테마
• 폰트 크기 조절
• CSV 구분자 선택
• 파일 인코딩 선택

개발자, 데이터 분석가, 기술 문서 작업자에게 필수 앱!
```

### 카테고리
```
도구 (Tools)
```

### 태그/키워드
```
json viewer, xml viewer, csv viewer, markdown editor, data viewer, file viewer, json editor, xml editor, code viewer, developer tools, data analysis
```

---

## 그래픽 자산

### 필수 항목
- [ ] 앱 아이콘: 512x512 PNG (완료 - assets/icon/app_icon.png)
- [ ] 기능 그래픽: 1024x500 PNG
- [ ] 스크린샷: 최소 2장 (폰 기준 16:9 또는 9:16)
  - 홈 화면
  - JSON 뷰어
  - XML 뷰어 (XPath 검색)
  - CSV 뷰어
  - Markdown 에디터
  - 설정 화면

### 스크린샷 촬영 방법
```bash
# 에뮬레이터에서 앱 실행
flutter run

# 스크린샷 캡처 (Android Studio 또는 시뮬레이터에서)
# 권장 해상도: 1080x1920 또는 1440x2560
```

---

## 개인정보 처리방침

Play Store 제출 시 개인정보 처리방침 URL이 필요합니다.

### 방법 1: GitHub Pages
1. GitHub에 저장소 생성
2. `privacy-policy.md` 파일 추가
3. GitHub Pages 활성화
4. URL: `https://username.github.io/repo/privacy-policy`

### 방법 2: Google Sites
무료로 간단한 페이지 생성 가능

### 개인정보 처리방침 예시
```
# 개인정보 처리방침

Data Viewer 앱은 사용자의 개인정보를 수집하지 않습니다.

## 수집하는 정보
- 이 앱은 어떠한 개인정보도 수집하지 않습니다.
- 모든 데이터는 사용자의 기기에만 저장됩니다.

## 데이터 저장
- 앱 설정 및 최근 파일 목록은 로컬 저장소에만 저장됩니다.
- 외부 서버로 데이터가 전송되지 않습니다.

## 제3자 공유
- 사용자 데이터를 제3자와 공유하지 않습니다.

## 문의
질문이 있으시면 [이메일]로 연락해 주세요.

최종 업데이트: 2026년 1월
```

---

## 출시 체크리스트

### 1. 앱 빌드
- [x] flutter analyze 통과
- [x] flutter test 통과
- [x] 앱 아이콘 생성
- [ ] Keystore 생성
- [ ] Release AAB 빌드

### 2. Play Console 설정
- [ ] Google Play Console 계정 생성 ($25 등록비)
- [ ] 앱 생성
- [ ] 스토어 등록정보 입력
- [ ] 그래픽 자산 업로드
- [ ] 콘텐츠 등급 설문 작성
- [ ] 가격 및 배포 설정

### 3. 앱 제출
- [ ] AAB 파일 업로드
- [ ] 출시 노트 작성
- [ ] 검토 제출

---

## AAB 빌드 명령어

Keystore 설정 완료 후:
```bash
flutter build appbundle --release
```

빌드 결과물:
```
build/app/outputs/bundle/release/app-release.aab
```
