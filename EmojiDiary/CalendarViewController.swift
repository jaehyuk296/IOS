//캘린더뷰

import UIKit

class CalendarViewController: UIViewController {

    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var entriesTableView: UITableView!

    var viewModel: DiaryViewModel!

    private let calendar = Calendar.current
    private var currentMonth = Date()
    private var selectedDate: Date?
    private var selectedEntries: [DiaryEntry] = []
    private var days: [Date?] = []
    private let weekdays = ["일", "월", "화", "수", "목", "금", "토"]

    override func viewDidLoad() {
        super.viewDidLoad()
        selectedDateLabel.text = "날짜를 선택하세요"
        setupCollectionView()
        setupTableView()
        generateDays()
        updateMonthLabel()
        fixLayout()     // ← 레이아웃 코드로 재정의
    }
 
    func reload() {
        guard isViewLoaded else { return }
        collectionView.reloadData()
        if let selected = selectedDate {
            selectedEntries = viewModel.entries(for: selected)
            entriesTableView.reloadData()
        }
    }
 
    // MARK: - 레이아웃 코드로 재정의 (컨테이너 안에서 safeArea 미사용)
    private func fixLayout() {
        [monthLabel, prevButton, nextButton, collectionView, selectedDateLabel, entriesTableView].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
        }
 
        // 컨테이너 안 child VC이므로 view.topAnchor 기준 사용 (safeArea X)
        let g = view
 
        NSLayoutConstraint.activate([
            // 이전/다음 버튼 + 월 레이블 (한 줄)
            prevButton.leadingAnchor.constraint(equalTo: g!.leadingAnchor, constant: 16),
            prevButton.topAnchor.constraint(equalTo: g!.topAnchor, constant: 12),
            prevButton.widthAnchor.constraint(equalToConstant: 36),
            prevButton.heightAnchor.constraint(equalToConstant: 36),
 
            monthLabel.centerXAnchor.constraint(equalTo: g!.centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor),
 
            nextButton.trailingAnchor.constraint(equalTo: g!.trailingAnchor, constant: -16),
            nextButton.centerYAnchor.constraint(equalTo: prevButton.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 36),
            nextButton.heightAnchor.constraint(equalToConstant: 36),
 
            // 달력 컬렉션뷰
            collectionView.topAnchor.constraint(equalTo: prevButton.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: g!.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: g!.trailingAnchor),
            // 요일 1줄(44) + 날짜 최대 6줄(44*6) = 308 고정
            collectionView.heightAnchor.constraint(equalToConstant: 308),
 
            // 선택 날짜 레이블
            selectedDateLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 12),
            selectedDateLabel.leadingAnchor.constraint(equalTo: g!.leadingAnchor, constant: 16),
            selectedDateLabel.trailingAnchor.constraint(equalTo: g!.trailingAnchor, constant: -16),
 
            // 선택 날짜의 일기 목록 테이블뷰
            entriesTableView.topAnchor.constraint(equalTo: selectedDateLabel.bottomAnchor, constant: 8),
            entriesTableView.leadingAnchor.constraint(equalTo: g!.leadingAnchor),
            entriesTableView.trailingAnchor.constraint(equalTo: g!.trailingAnchor),
            entriesTableView.bottomAnchor.constraint(equalTo: g!.bottomAnchor),
        ])
    }
 
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WeekdayCell.self, forCellWithReuseIdentifier: "WeekdayCell")
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")
        collectionView.isScrollEnabled = false
 
        let width = floor(UIScreen.main.bounds.width / 7)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: width, height: 44)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
    }
 
    private func setupTableView() {
        entriesTableView.delegate = self
        entriesTableView.dataSource = self
        entriesTableView.rowHeight = 80
        entriesTableView.estimatedRowHeight = 80
        // DiaryCell 재사용
        //entriesTableView.register(UINib(nibName: "DiaryCell", bundle: nil), forCellReuseIdentifier: DiaryCell.identifier)
    }
 
    private func generateDays() {
        days = []
        guard let interval = calendar.dateInterval(of: .month, for: currentMonth),
              let weekday = calendar.dateComponents([.weekday], from: interval.start).weekday
        else { return }
        days = Array(repeating: nil, count: weekday - 1)
        var current = interval.start
        while current < interval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        // 7의 배수 맞추기 (마지막 줄 빈칸)
        while days.count % 7 != 0 { days.append(nil) }
    }
 
    private func updateMonthLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        monthLabel.text = formatter.string(from: currentMonth)
    }
 
    // 해당 날짜의 첫 번째 이모지 반환
    private func emoji(for date: Date) -> String? {
        viewModel.entries(for: date).first?.emoji
    }

    @IBAction func prevMonthTapped(_ sender: UIButton) {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        generateDays()
        updateMonthLabel()
        collectionView.reloadData()
        resetSelection()
    }

    @IBAction func nextMonthTapped(_ sender: UIButton) {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        generateDays()
        updateMonthLabel()
        collectionView.reloadData()
        resetSelection()
    }
    
    private func resetSelection() {
        selectedDate = nil
        selectedEntries = []
        entriesTableView.reloadData()
        selectedDateLabel.text = "날짜를 선택하세요"
    }
}

// MARK: - CollectionView
extension CalendarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekdays.count + days.count
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 요일 헤더 (첫 7칸)
        if indexPath.item < 7 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeekdayCell", for: indexPath) as! WeekdayCell
            cell.label.text = weekdays[indexPath.item]
            cell.label.textColor = indexPath.item == 0 ? .systemRed : .secondaryLabel
            return cell
        }
 
        // 날짜 셀
        let dayIndex = indexPath.item - 7
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell
 
        if let date = days[dayIndex] {
            let day = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            let isSelected = selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false
            let emojiStr = emoji(for: date)     // ← 이모지 전달
            cell.configure(day: day, isToday: isToday, isSelected: isSelected, emoji: emojiStr)
        } else {
            cell.configureEmpty()
        }
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item >= 7 else { return }
        let dayIndex = indexPath.item - 7
        guard let date = days[dayIndex] else { return }
 
        selectedDate = date
        selectedEntries = viewModel.entries(for: date)
 
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 기록"
        selectedDateLabel.text = formatter.string(from: date)
 
        entriesTableView.reloadData()
        collectionView.reloadData()
    }
}
 
// MARK: - TableView (선택 날짜 일기 목록)
extension CalendarViewController: UITableViewDataSource, UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedEntries.isEmpty ? 1 : selectedEntries.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedEntries.isEmpty {
            let cell = UITableViewCell()
            cell.textLabel?.text = "이 날의 기록이 없어요"
            cell.textLabel?.textColor = .secondaryLabel
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            return cell
        }

        // DiaryCell NIB 없으므로 CalendarDiaryCell 사용
        let identifier = "CalendarDiaryCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? CalendarDiaryCell(reuseIdentifier: identifier)
        (cell as? CalendarDiaryCell)?.configure(with: selectedEntries[indexPath.row])
        return cell
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !selectedEntries.isEmpty else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let entry = selectedEntries[indexPath.row]
        if let listVC = parent as? DiaryListViewController {
            listVC.performSegue(withIdentifier: "showDetail", sender: entry)
        }
    }
}
 
// MARK: - WeekdayCell
class WeekdayCell: UICollectionViewCell {
    let label: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 12, weight: .medium)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
 
// MARK: - DayCell (이모지 표시 추가)
class DayCell: UICollectionViewCell {
 
    // 이모지 레이블 (일기가 있으면 표시)
    let emojiLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 18)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
 
    // 날짜 숫자
    let dayLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 11)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.addSubview(emojiLabel)
        contentView.addSubview(dayLabel)
 
        NSLayoutConstraint.activate([
            // 이모지: 위쪽
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
 
            // 날짜: 이모지 아래
            dayLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 0),
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
 
    func configure(day: Int, isToday: Bool, isSelected: Bool, emoji: String?) {
        dayLabel.text = "\(day)"
        dayLabel.isHidden = false
        emojiLabel.text = emoji ?? ""   // 일기 없으면 빈 문자열
 
        if isSelected {
            contentView.backgroundColor = .systemPurple.withAlphaComponent(0.15)
            dayLabel.textColor = .systemPurple
            dayLabel.font = .systemFont(ofSize: 11, weight: .bold)
        } else if isToday {
            contentView.backgroundColor = .systemPurple.withAlphaComponent(0.08)
            dayLabel.textColor = .systemPurple
            dayLabel.font = .systemFont(ofSize: 11, weight: .medium)
        } else {
            contentView.backgroundColor = .clear
            dayLabel.textColor = .label
            dayLabel.font = .systemFont(ofSize: 11)
        }
    }
 
    func configureEmpty() {
        dayLabel.text = ""
        emojiLabel.text = ""
        contentView.backgroundColor = .clear
    }
}
 
// MARK: - CalendarDiaryCell (캘린더 전용 셀, NIB 불필요)
class CalendarDiaryCell: UITableViewCell {

    private let emojiLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 26)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let memoLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .label
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let thumbImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    init(reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        [emojiLabel, memoLabel, dateLabel, thumbImageView].forEach { contentView.addSubview($0) }
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 34),

            thumbImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            thumbImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbImageView.widthAnchor.constraint(equalToConstant: 56),
            thumbImageView.heightAnchor.constraint(equalToConstant: 56),

            dateLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: thumbImageView.leadingAnchor, constant: -8),

            memoLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 8),
            memoLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            memoLabel.trailingAnchor.constraint(equalTo: thumbImageView.leadingAnchor, constant: -8),
            memoLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14),
        ])
    }

    func configure(with entry: DiaryEntry) {
        emojiLabel.text = entry.emoji
        memoLabel.text = entry.memo
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        dateLabel.text = f.string(from: entry.date)

        if let data = entry.imageData, let img = UIImage(data: data) {
            thumbImageView.image = img
            thumbImageView.isHidden = false
        } else {
            thumbImageView.isHidden = true
        }
    }
}
