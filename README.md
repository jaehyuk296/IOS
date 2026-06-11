# 🗒️ EmojiDiary

> 오늘 하루를 이모지 하나로 기록하는 감정 일기 앱

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2014%2B-blue.svg)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-12-blue.svg)](https://developer.apple.com/xcode/)

---

## 📱 앱 소개

EmojiDiary는 복잡한 글 대신 **이모지 + 한 줄 메모**로 하루의 감정을 빠르게 기록하는 iOS 일기 앱입니다.
캘린더에서 날짜별 감정 흐름을 한눈에 확인할 수 있어요.

---

## 🎬 데모 영상

[![YouTube](https://img.shields.io/badge/YouTube-Demo-red)](https://youtube.com/YOUR_LINK)

> ▶️ 위 링크에서 앱 소개 영상을 확인하세요 (3분 이내)

---

## ✨ 주요 기능

| 기능 | 설명 |
|------|------|
| 📝 일기 작성 | 이모지 선택 + 한 줄 메모 + 사진 첨부 |
| 📋 기록 리스트 | 작성한 일기 목록 확인 및 스와이프 삭제 |
| 📅 캘린더 뷰 | 월별 캘린더에서 날짜별 이모지 표시 |
| 🔍 상세 보기 | 이모지, 날짜, 메모, 사진 상세 확인 |
| ✏️ 수정 기능 | 메모, 이모지, 사진 개별 수정 |

---

## 📸 스크린샷

| 기록 리스트 | 기록하기 | 캘린더 | 상세 보기 | 수정하기 |
|:-----------:|:--------:|:------:|:---------:|:--------:|
| <img src="https://github.com/user-attachments/assets/c63ac391-7f43-4b8f-af9e-ce71ce0e2fc4" width="150"> | <img src="https://github.com/user-attachments/assets/ae897afe-6999-4d2a-807f-eb47ecc08be3" width="150"> | <img src="https://github.com/user-attachments/assets/fdce8c6b-a95b-4c4c-a904-903ab6096fcc" width="150"> | <img src="https://github.com/user-attachments/assets/d83adb79-3a8a-44c9-a129-c239ba187e37" width="150"> | <img src="https://github.com/user-attachments/assets/28baa27f-2f00-486a-b83d-92d48f179347" width="150"> | <img width="150" src="https://github.com/user-attachments/assets/7af761de-c950-4116-b071-b4d52f685d93" />


---

## 🏗️ 기술 스택

- **언어**: Swift 5
- **UI**: UIKit + Storyboard
- **아키텍처**: MVVM
- **데이터 저장**: UserDefaults (JSON Encoding/Decoding)
- **최소 버전**: iOS 14
- **개발 도구**: Xcode 12

---

## 🗂️ 프로젝트 구조

```
EmojiDiary/
├── Model/
│   └── DiaryEntry.swift          # 일기 데이터 모델
├── ViewModel/
│   └── DiaryViewModel.swift      # CRUD 로직, UserDefaults 관리
├── View/
│   ├── DiaryCell.swift           # 리스트 셀
│   └── Main.storyboard           # UI 레이아웃
└── Controller/
    ├── DiaryListViewController.swift    # 메인 리스트 + 캘린더 전환
    ├── CalendarViewController.swift     # 월별 캘린더
    ├── RecordViewController.swift       # 일기 작성
    ├── DiaryDetailViewController.swift  # 상세 보기 + 수정
    └── MainTabBarController.swift       # 탭바
```

---

## 📦 데이터 모델

```swift
struct DiaryEntry: Codable {
    let id: UUID
    var date: Date
    var emoji: String
    var memo: String
    var imageData: Data?
}
```

---

## 🚀 실행 방법

1. 저장소 클론
```bash
git clone https://github.com/YOUR_USERNAME/EmojiDiary.git
```

2. Xcode에서 `EmojiDiary.xcodeproj` 열기

3. 시뮬레이터 또는 실제 기기에서 실행 (iOS 14 이상)

---

## 📝 개발 과정에서 배운 점

- UIKit AutoLayout을 코드와 스토리보드 혼합 방식으로 구성하는 법
- MVVM 패턴으로 ViewController와 비즈니스 로직 분리
- NotificationCenter를 활용한 화면 간 데이터 갱신
- Child ViewController로 캘린더를 컨테이너 뷰 안에 embed하는 방법
- UserDefaults + Codable로 로컬 데이터 영속성 구현

---

## 👨‍💻 개발자

| 이름 | 역할 |
|------|------|
| 이재혁 | iOS 개발 (기획, 설계, 구현 전체) |

---

## 📄 라이선스

MIT License © 2026 이재혁
