//
//  DiaryEntry.swift
//  emotiondiary
//
//  Created by 이재혁 on 6/6/26.
//

import Foundation

struct DiaryEntry: Codable {
    var id: UUID = UUID()
    var date: Date
    var emoji: String
    var memo: String
    var imageData: Data?
}
