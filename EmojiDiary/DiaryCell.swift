//
//  DiaryCell.swift
//  emotiondiary
//
//  Created by 이재혁 on 6/6/26.
//

import UIKit

class DiaryCell: UITableViewCell {
    static let identifier = "DiaryCell"

    // MARK: - UI 요소 (스토리보드에서 연결)
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    // 스토리보드 constraint 중복 방지용 플래그
    private var didSetupLayout = false
 
    override func awakeFromNib() {
        super.awakeFromNib()
        setupStyle()
    }
 
    // constraint는 bounds가 확정된 후 한 번만 실행
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !didSetupLayout else { return }
        didSetupLayout = true
        setupLayoutConstraints()
    }
 
    // MARK: - 스타일만 (constraint 없음)
    private func setupStyle() {
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 8
 
        emojiLabel.font = .systemFont(ofSize: 28)
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textColor = .secondaryLabel
        memoLabel.font = .systemFont(ofSize: 14)
        memoLabel.textColor = .label
        memoLabel.numberOfLines = 2
    }
 
    // MARK: - constraint 재정의 (스토리보드 constraint 모두 비활성화 후 새로 설정)
    private func setupLayoutConstraints() {
        // 스토리보드에서 걸린 모든 constraint 제거
        contentView.constraints.forEach { $0.isActive = false }
 
        [emojiLabel, dateLabel, memoLabel, thumbnailImageView].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
 
        NSLayoutConstraint.activate([
            // 썸네일: 오른쪽 고정 72x72
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 72),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 72),
 
            // 이모지: 왼쪽, 세로 중앙
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 36),
 
            // 날짜: 이모지 오른쪽, 상단 정렬
            dateLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -8),
 
            // 메모: 날짜 아래
            memoLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            memoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            memoLabel.trailingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor, constant: -8),
            memoLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14),
        ])
    }
 
    func configure(with entry: DiaryEntry) {
        emojiLabel.text = entry.emoji
 
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        formatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = formatter.string(from: entry.date)
 
        memoLabel.text = entry.memo
 
        if let data = entry.imageData, let image = UIImage(data: data) {
            thumbnailImageView.image = image
            thumbnailImageView.isHidden = false
        } else {
            thumbnailImageView.image = nil
            thumbnailImageView.isHidden = true
        }
    }
}
