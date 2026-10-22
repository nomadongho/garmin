# Garmin Watch Face

Garmin Forerunner 55용 경량 Connect IQ 워치페이스 프로젝트입니다. Monkey C로 작성하며, 우선 **Forerunner 55의 가독성·배터리 효율·호환성**에 집중합니다.

## 현재 범위 (미니멀 워치페이스)

- 시각: 기기 설정과 관계없이 **12시간제 고정**, AM/PM 글자는 표시하지 않음 (예: `10:08`). **오전(00:00~11:59)은 흰색**, **오후(12:00~23:59)는 노란색**으로 시간 숫자 색상을 전환
- 날짜: **요일 + 일 + 월** (예: `TUE 20 OCT`)
- 배터리: 원형 화면 안쪽의 하단 왼쪽에 남은 잔량(%) 표시
- 심박수: 원형 화면 안쪽의 하단 오른쪽에 현재 값, 없으면 최신 기록 1건을 확인하고 유효한 값이 없을 때 `--` 표시
- 레이아웃: 날짜와 시간 사이 간격을 좁히고 시간 숫자를 가운데 정렬. 별도 AM/PM 텍스트가 없어 공간을 절약하며, 날짜·배터리·심박수는 항상 흰색으로 표시. 하단 데이터는 원형 화면에서 잘리지 않도록 위쪽에 배치
- 화면은 기기에서 정한 주기에 따라 `onUpdate()`로 갱신. 초 단위 부분 갱신·타이머·네트워크 요청 없음
- Forerunner 55만 빌드 대상으로 지정 (`fr55`)
- 최소 Connect IQ API 3.4.0, 화면 208×208, 원형 MIP, 8색
- 런처 아이콘: `resources/drawables/launcher_icon.png` (40×40), `manifest.xml`에서 참조

> 워치페이스 화면의 SDK 컴파일과 실기기 표시·심박수 갱신은 별도 검증이 필요합니다. GitHub Actions는 XML·구조 검증만 수행하며 실제 Monkey C 컴파일의 성공을 보장하지 않습니다.

## 개발 환경

1. Garmin의 [Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/overview/)를 설치합니다.
2. SDK와 **Forerunner 55 (`fr55`)** 기기 패키지를 다운로드합니다.
3. VS Code에 공식 **Monkey C** 확장(`garmin.monkey-c`)을 설치합니다.
4. VS Code 명령 팔레트에서 **Monkey C: Verify Installation**을 실행합니다.
5. 개인 개발자 서명 키를 생성합니다. 파일명이 `developer_key`인 경우에도 GitHub로 커밋하지 마세요. `.gitignore`에서 이 파일을 제외합니다.

## 빌드·시뮬레이터 실행

저장소 루트에서(Connect IQ SDK의 `bin` 경로가 `PATH`에 있는 경우):

```bash
mkdir -p bin
monkeyc -f monkey.jungle -d fr55 -o bin/StarterFace.prg -y ./developer_key -w
monkeydo bin/StarterFace.prg fr55
```

위의 `developer_key`는 VS Code가 생성한 키 파일의 위치에 맞게 수정하세요. 또는 VS Code에서 Monkey C 소스 파일을 열고 **Run Without Debugging**으로 Forerunner 55 시뮬레이터를 선택합니다.

실기기에 설치하기 전 **00:00 → 흰색 `12:00`**, **11:59 → 흰색 `11:59`**, **12:00 → 노란색 `12:00`**, **23:59 → 노란색 `11:59`** 전환, 기기의 12/24시간 설정과 무관한 시각 표시, 자정 날짜·요일·월 변경, 배터리 퍼센트, 심박수 센서 데이터와 미착용 시 `--` 표시, 저전력 화면·메모리 사용을 확인하세요. 특히 **`8:18`과 `12:59`, 배터리 `100%`, 심박수 세 자리 수** 조합에서 날짜·시간·하단 정보가 겹치거나 잘리지 않는지, 배터리·심박수 및 날짜의 글자 색상이 흰색으로 유지되는지 시뮬레이터와 실기기에서 확인하세요. SDK 및 실제 기기 테스트는 별도로 필요합니다.

## 자동 검증

```bash
python3 tools/validate_project.py
```

GitHub Actions는 push/PR에서 이 정적 검증을 실행합니다. SDK/서명 키가 필요한 **실제 컴파일·시뮬레이터·기기 테스트는 현재 CI에 포함하지 않습니다.**

## 디렉터리

```text
├── manifest.xml                     # 앱 ID, 런처 아이콘, 최소 API
├── monkey.jungle                    # Monkey C 빌드 설정
├── source/
│   ├── StarterFaceApp.mc            # 앱 진입점
│   └── StarterFaceView.mc           # 12시간 시각·요일·월·배터리·심박수 UI
├── resources/
│   ├── strings/strings.xml          # 앱 명칭
│   └── drawables/
│       ├── drawables.xml            # 런처 아이콘 리소스 정의
│       └── launcher_icon.png        # 40x40 PNG
├── tools/validate_project.py        # SDK 없이 실행하는 정적 검증
└── .github/workflows/validate.yml
```

## 개발 규칙

- 안정 브랜치: `main`; 개발은 반드시 `dev`에서 진행
- 사용자 요청이 있어야 검증된 변경을 `main`으로 fast-forward 병합
- Forerunner 55가 지원하지 않는 API는 사용하지 않음
- 사용자 요구에 맞춰 UI와 데이터 표시 영역을 작은 컴포넌트로 확장
- 암호·API 키·개발자 서명 키·생성된 빌드 결과물 커밋 금지

## 참고

- [Garmin - Your First Connect IQ App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
- [Garmin - Manifest and Permissions](https://developer.garmin.com/connect-iq/articles/core-topics/Manifest_and_Permissions.html)
- [Garmin - Resources](https://developer.garmin.com/connect-iq/articles/core-topics/Resources.html)
- [Garmin - Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
