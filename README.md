# Garmin Watch Face

Garmin Forerunner 55용 경량 Connect IQ 워치페이스 프로젝트입니다. Monkey C로 작성하며, 우선 **Forerunner 55의 가독성·배터리 효율·호환성**에 집중합니다.

## 현재 범위 (초기 스캐폴드)

- 시각: 시계의 12/24시간 설정 반영
- 날짜: 요일과 일/월
- 배터리 잔량(%) 표시
- 화면은 분 단위로 갱신할 수 있도록 `onUpdate()`만 구현. 초 단위 부분 갱신·타이머·네트워크 요청 없음
- Forerunner 55만 빌드 대상으로 지정 (`fr55`)
- 최소 Connect IQ API 3.4.0, 화면 208×208, 원형 MIP, 8색
- 런처 아이콘: `resources/drawables/launcher_icon.png` (40×40), `manifest.xml`에서 참조

> 초기 소스는 SDK 빌드 및 실기기 검증 전의 초안입니다. GitHub Actions는 XML·구조 검증만 수행하며 실제 Monkey C 컴파일의 성공을 보장하지 않습니다.

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

실기기에 설치하기 전 시각(00:00/12:00/23:59), 12/24시간 설정, 자정 날짜 변경, 배터리 퍼센트, 저전력 화면·메모리 사용을 확인하세요. SDK 및 실제 기기 테스트는 별도로 필요합니다.

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
│   └── StarterFaceView.mc           # 시각·날짜·배터리 UI
├── resources/
│   ├── strings/strings.xml          # 앱 명칭
│   └── drawables/
│       ├── drawables.xml            # 런처 아이콘 리소스 정의
│       └── launcher_icon.png        # 40x40 PNG
├── tools/validate_project.py        # SDK 없이 실행하는 정적 검증
└── .github/workflows/validate.yml
```

## 개발 규칙

- 안정 브랜치: `master`; 신규 작업은 기능 브랜치와 PR 사용
- 확인하지 않은 변경을 `master`에 병합하지 않음
- Forerunner 55가 지원하지 않는 API는 사용하지 않음
- 사용자 요구에 맞춰 UI와 데이터 표시 영역을 작은 컴포넌트로 확장
- 암호·API 키·개발자 서명 키·생성된 빌드 결과물 커밋 금지

## 참고

- [Garmin - Your First Connect IQ App](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
- [Garmin - Manifest and Permissions](https://developer.garmin.com/connect-iq/articles/core-topics/Manifest_and_Permissions.html)
- [Garmin - Resources](https://developer.garmin.com/connect-iq/articles/core-topics/Resources.html)
- [Garmin - Compatible Devices](https://developer.garmin.com/connect-iq/compatible-devices/)
