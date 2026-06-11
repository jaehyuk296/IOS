import UIKit

class RecordViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emojiCollectionView: UICollectionView!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var charCountLabel: UILabel!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!

    private let emojis = ["😊", "😢", "😡", "🤩", "😴", "😰", "🥹", "😌"]
    private var selectedEmoji = "😊"
    private var selectedImage: UIImage?

    var viewModel: DiaryViewModel?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "기록하기"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소", style: .plain,
            target: self, action: #selector(cancelTapped)
        )

        setupCollectionView()
        setupTextView()
        setupUI()

        // 키보드 옵저버
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // 빈 곳 탭 → 키보드 내리기 (중복 제거 후 하나만)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - 키보드 처리
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = -keyboardHeight / 2
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.view.frame.origin.y = 0
        }
    }

    // MARK: - Setup
    private func setupCollectionView() {
        emojiCollectionView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        emojiCollectionView.collectionViewLayout = layout
        emojiCollectionView.showsHorizontalScrollIndicator = false
    }

    private func setupTextView() {
        memoTextView.delegate = self
        memoTextView.isEditable = true
        memoTextView.isSelectable = true
        memoTextView.layer.cornerRadius = 10
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor.systemGray4.cgColor
        memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }

    private func setupUI() {
        saveButton.layer.cornerRadius = 22
        saveButton.backgroundColor = UIColor(red: 0.2, green: 0.78, blue: 0.67, alpha: 1.0)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.isHidden = false

        imageContainerView.isHidden = true
        addPhotoButton.isHidden = false

        selectedImageView.layer.cornerRadius = 12
        selectedImageView.clipsToBounds = true
        selectedImageView.contentMode = .scaleAspectFill

        charCountLabel.text = "0/50"
    }

    // MARK: - 사진 UI 업데이트
    private func updatePhotoUI() {
        let hasPhoto = selectedImage != nil
        imageContainerView.isHidden = !hasPhoto
        addPhotoButton.isHidden = hasPhoto
    }

    // MARK: - IBActions
    @objc func cancelTapped(_ sender: Any? = nil) {
        navigationController?.dismiss(animated: true)
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let memo = memoTextView.text, !memo.isEmpty else {
            showAlert(message: "메모를 입력해주세요.")
            return
        }
        let imageData = selectedImage?.jpegData(compressionQuality: 0.7)
        viewModel?.save(emoji: selectedEmoji, memo: memo, imageData: imageData)

        let alert = UIAlertController(title: "저장 완료", message: "오늘의 기록이 저장됐어요 ✅", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            NotificationCenter.default.post(name: NSNotification.Name("diaryDidSave"), object: nil)
            self?.navigationController?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }

    @IBAction func addPhotoTapped(_ sender: UIButton) {
        showImagePicker()
    }

    @IBAction func removeImageTapped(_ sender: UIButton) {
        selectedImage = nil
        selectedImageView.image = nil
        updatePhotoUI()
    }

    @IBAction func changePhotoTapped(_ sender: UIButton) {
        showImagePicker()
    }

    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView
extension RecordViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCell
        let emoji = emojis[indexPath.item]
        cell.configure(emoji: emoji, isSelected: emoji == selectedEmoji)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEmoji = emojis[indexPath.item]
        collectionView.reloadData()
    }
}

// MARK: - UITextViewDelegate
extension RecordViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 50 {
            textView.text = String(textView.text.prefix(50))
        }
        charCountLabel.text = "\(textView.text.count)/50"
        charCountLabel.textColor = textView.text.count >= 50 ? .systemRed : .secondaryLabel
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

// MARK: - UIImagePickerController
extension RecordViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            selectedImageView.image = image
            updatePhotoUI()
        }
        dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
}

// MARK: - EmojiCell
class EmojiCell: UICollectionViewCell {
    let emojiLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 36)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        addSubview(emojiLabel)
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(emoji: String, isSelected: Bool) {
        emojiLabel.text = emoji
        backgroundColor = isSelected ? UIColor.systemTeal.withAlphaComponent(0.2) : .clear
        layer.borderWidth = isSelected ? 1.5 : 0
        layer.borderColor = isSelected ? UIColor.systemTeal.cgColor : UIColor.clear.cgColor
    }
}
