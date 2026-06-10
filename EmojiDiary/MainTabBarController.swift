//
//  MainTabBarController.swift
//  emotiondiary
//
//  Created by 이재혁 on 6/6/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = .systemPurple

        // RecordVC에 viewModel 주입 (직접 접근 방식)
        // 탭바 아이템 아이콘/타이틀은 스토리보드에서 설정
    }
}
