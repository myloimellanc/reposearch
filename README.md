#  Reposearch
Github Repository Search for iOS


## 기본 사항 적용
- 디바이스 제한: 아이폰 (portrait only)
- 최소 지원 버전: iOS 12.0
- Scheme: Debug, Test, QA, Staging, Release
    - 가변 앱 이름, ID 적용, 빌드 트랙 분리
- 로컬라이징: English, Korean
- Scene 미사용
- 다크모드 미사용
- 코어 라이브러리
    - RxSwift: 반응형 코드 작업
    - R.swift: 리소스 사용
    - Alamofire: 네트워크


## 1차 스프린트 작업
- 목표 사항: 앱 기능의 기본적인 최소 요구사항 구현 
    - 도메인 영역을 제외한 데이터 + 뷰 영역 기본 작업
    - API의 검색어 패러미터만 작업
    - UISearchController를 포함한 NavigationItem을 기반으로 하는 테이블 뷰
        - 1페이지 한정 표기 
- 작업 특이사항
    - github api 타임아웃 10초 제한


## 2차 스프린트 작업
- 목표 사항: 앱의 전반적인 구조 및 세부 로직 구현
    - 레포지토리를 포함한 도메인 영역 구성
    - 이미지 다운로더 작성
    - 앱의 세부 조작 및 기능 작성
        - 검색어 입력 스로틀링 + 확인버튼 트리거 합치기
        - 검색어 변동시 우선적으로 결과 초기화
        - 로딩 및 검색결과 없음 표기
        - 잔여 결과 로드가 필요하다면, 스크롤을 끝까지 내렸을 때 아랫부분 페이지 계속 로드
        - 섬네일 이미지 로드 및 캐싱
        - 내림차순/오름차순 변경 버튼
        - 페이지 별 검색결과 수 설정


## 1차 QA 브랜치 이후 UI 수정
- 목표 사항: 앱의 세부적인 UI요소 정리
    - 페이지 레이아웃 정리 및 가변 셀 높이 구성
    - 프로젝트 폰트, 컬러, 로컬라이징
    - 앱 이름, 디바이스 회전 관련 오작동 수정
