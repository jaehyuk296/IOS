//
//  DiaryView.swift
//  emotiondiary
//
//  Created by 이재혁 on 6/6/26.
//
import Foundation

class DiaryViewModel {
    private let storageKey = "diary_entries"
    private(set) var entries: [DiaryEntry] = []

    init() { load() }

    func save(emoji: String, memo: String, imageData: Data?) {
        let entry = DiaryEntry(date: Date(), emoji: emoji, memo: memo, imageData: imageData)
        entries.insert(entry, at: 0)
        persist()
    }

    func update(id: UUID, emoji: String, memo: String, imageData: Data?) {
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return }
        entries[index].emoji = emoji
        entries[index].memo = memo
        entries[index].imageData = imageData
        persist()
    }

    func delete(at index: Int) {
        entries.remove(at: index)
        persist()
    }

    func delete(id: UUID) {
        entries.removeAll { $0.id == id }
        persist()
    }

    // 저장소에서 다시 불러오기 (수정/삭제 후 리스트 갱신용)
    func reload() {
        load()
    }

    func entries(for date: Date) -> [DiaryEntry] {
        Calendar.current.isDateInToday(date)
            ? entries.filter { Calendar.current.isDateInToday($0.date) }
            : entries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    func hasEntry(for date: Date) -> Bool {
        !entries(for: date).isEmpty
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([DiaryEntry].self, from: data)
        else { return }
        entries = decoded
    }
}
