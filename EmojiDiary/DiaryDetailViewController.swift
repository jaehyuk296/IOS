import UIKit

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var attachedImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!

    var entry: DiaryEntry!
    var viewModel: DiaryViewModel?
    var onDelete: (() -> Void)?
    var onUpdate: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "상세 기록"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "수정", style: .plain,
            target: self, action: #selector(editTapped)
        )
        setupUI()
        fixLayout()
        configure()
    }

    private func setupUI() {
        deleteButton.layer.cornerRadius = 22
        deleteButton.tintColor = .systemRed
        attachedImageView.layer.cornerRadius = 16
        attachedImageView.clipsToBounds = true
        attachedImageView.contentMode = .scaleAspectFill
    }

    private func fixLayout() {
        [emojiLabel, dateLabel, memoLabel, attachedImageView, deleteButton].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
        view.subviews.forEach { $0.constraints.forEach { $0.isActive = false } }
        view.constraints.forEach { $0.isActive = false }

        let safe = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            // 이모지: 최상단 중앙
            emojiLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 120),
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // 날짜: 이모지 아래
            dateLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // 메모: 날짜 아래
            memoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            memoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            memoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            // 사진: 메모 아래 (좌우 여백 24, 높이 200)
            attachedImageView.topAnchor.constraint(equalTo: memoLabel.bottomAnchor, constant: 60),
            attachedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            attachedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            attachedImageView.heightAnchor.constraint(equalToConstant: 240),

            // 삭제 버튼: 하단 고정
            deleteButton.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -24),
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 160),
            deleteButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func configure() {
        emojiLabel.text = entry.emoji
        emojiLabel.font = .systemFont(ofSize: 64)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = formatter.string(from: entry.date)
        dateLabel.textAlignment = .center
        dateLabel.font = .systemFont(ofSize: 15, weight: .medium)
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 0

        memoLabel.text = entry.memo
        memoLabel.numberOfLines = 0
        memoLabel.textAlignment = .center
        memoLabel.font = .systemFont(ofSize: 20, weight: .regular)
        memoLabel.textColor = .label

        if let data = entry.imageData, let image = UIImage(data: data) {
            attachedImageView.image = image
            attachedImageView.isHidden = false
        } else {
            // 사진 없으면 높이 0으로 collapse
            attachedImageView.isHidden = true
            attachedImageView.constraints
                .filter { $0.firstAttribute == .height }
                .forEach { $0.constant = 0 }
        }
    }

    // MARK: - 수정
    @objc private func editTapped() {
        let alert = UIAlertController(title: "수정하기", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "✏️ 메모 수정", style: .default) { [weak self] _ in
            self?.showMemoEditAlert()
        })
        alert.addAction(UIAlertAction(title: "😊 이모지 변경", style: .default) { [weak self] _ in
            self?.showEmojiPicker()
        })
        alert.addAction(UIAlertAction(title: "🖼️ 사진 변경", style: .default) { [weak self] _ in
            self?.showImagePicker()
        })
        if entry.imageData != nil {
            alert.addAction(UIAlertAction(title: "🗑️ 사진 삭제", style: .destructive) { [weak self] _ in
                self?.removePhoto()
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showMemoEditAlert() {
        let alert = UIAlertController(title: "메모 수정", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] tf in tf.text = self?.entry.memo }
        alert.addAction(UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self,
                  let newMemo = alert.textFields?.first?.text,
                  !newMemo.isEmpty else { return }
            self.entry.memo = newMemo
            self.memoLabel.text = newMemo
            self.saveUpdate()
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    private func showEmojiPicker() {
        let picker = EmojiPickerViewController()
        picker.onSelect = { [weak self] emoji in
            guard let self = self else { return }
            self.entry.emoji = emoji
            self.emojiLabel.text = emoji
            self.saveUpdate()
        }
        picker.modalPresentationStyle = .formSheet
        present(picker, animated: true)
    }

    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func removePhoto() {
        entry.imageData = nil
        attachedImageView.image = nil
        attachedImageView.isHidden = true
        attachedImageView.constraints
            .filter { $0.firstAttribute == .height }
            .forEach { $0.constant = 0 }
        saveUpdate()
    }

    private func saveUpdate() {
        viewModel?.update(id: entry.id, emoji: entry.emoji, memo: entry.memo, imageData: entry.imageData)
        NotificationCenter.default.post(name: NSNotification.Name("diaryDidSave"), object: nil)
        onUpdate?()
    }

    // MARK: - 삭제
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "삭제할까요?", message: "이 기록은 복구할 수 없어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.onDelete?()
            self?.navigationController?.popViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - 사진 선택
extension DiaryDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            entry.imageData = image.jpegData(compressionQuality: 0.7)
            attachedImageView.image = image
            attachedImageView.isHidden = false
            attachedImageView.constraints
                .filter { $0.firstAttribute == .height }
                .forEach { $0.constant = 200 }
            saveUpdate()
        }
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - 이모지 선택 VC
class EmojiPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var onSelect: ((String) -> Void)?
    private let emojis = ["😊", "😡", "😴", "🥹", "😢", "🤩", "😰", "😌"]

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 64, height: 64)
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.delegate = self
        cv.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "이모지 선택"
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { emojis.count }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        cell.configure(emoji: emojis[indexPath.item], isSelected: false)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(emojis[indexPath.item])
        dismiss(animated: true)
    }
}
