import UIKit

class DiaryListViewController: UIViewController {

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tabelView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var calendarContainerView: UIView!

    let viewModel = DiaryViewModel()
    private var calendarVC: CalendarViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "나의 기록"
        segmentControl.selectedSegmentIndex = 0
        fixLayout()
        setupTableView()
        setupCalendarChild()
        setupTabBarIcon()
        updateView()
        NotificationCenter.default.addObserver(
            self, selector: #selector(diaryDidSave),
            name: NSNotification.Name("diaryDidSave"), object: nil)
    }

    private func fixLayout() {
        [segmentControl, tabelView, emptyView, calendarContainerView].forEach {
            $0?.translatesAutoresizingMaskIntoConstraints = false
            $0?.removeFromSuperview()
        }
        [segmentControl, tabelView, emptyView, calendarContainerView].forEach {
            view.addSubview($0!)
        }
        let s = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: s.topAnchor, constant: 8),
            segmentControl.leadingAnchor.constraint(equalTo: s.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: s.trailingAnchor, constant: -16),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),

            tabelView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            tabelView.leadingAnchor.constraint(equalTo: s.leadingAnchor),
            tabelView.trailingAnchor.constraint(equalTo: s.trailingAnchor),
            tabelView.bottomAnchor.constraint(equalTo: s.bottomAnchor),

            emptyView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            emptyView.leadingAnchor.constraint(equalTo: s.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: s.trailingAnchor),
            emptyView.bottomAnchor.constraint(equalTo: s.bottomAnchor),

            calendarContainerView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 8),
            calendarContainerView.leadingAnchor.constraint(equalTo: s.leadingAnchor),
            calendarContainerView.trailingAnchor.constraint(equalTo: s.trailingAnchor),
            calendarContainerView.bottomAnchor.constraint(equalTo: s.bottomAnchor),
        ])
    }

    @objc func diaryDidSave() {
        viewModel.reload()
        tabelView.reloadData()
        calendarVC?.reload()
        updateView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabelView.reloadData()
        calendarVC?.reload()
        updateView()
    }

    private func setupTableView() {
        tabelView.delegate = self
        tabelView.dataSource = self
        tabelView.rowHeight = 100
        tabelView.estimatedRowHeight = 100
    }

    private func setupTabBarIcon() {
        tabBarItem.image = UIImage(systemName: "book.closed")
        tabBarItem.selectedImage = UIImage(systemName: "book.closed.fill")
        tabBarItem.title = "나의 기록"
    }

    private func setupCalendarChild() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let calVC = storyboard.instantiateViewController(withIdentifier: "CalendarVC")
                as? CalendarViewController else { return }
        calVC.viewModel = viewModel
        addChild(calVC)
        calendarContainerView.addSubview(calVC.view)
        calVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calVC.view.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
            calVC.view.leadingAnchor.constraint(equalTo: calendarContainerView.leadingAnchor),
            calVC.view.trailingAnchor.constraint(equalTo: calendarContainerView.trailingAnchor),
            calVC.view.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor),
        ])
        calVC.didMove(toParent: self)
        calendarVC = calVC
        calendarContainerView.isHidden = true
    }

    private func updateView() {
        let isCalendar = segmentControl.selectedSegmentIndex == 1
        let hasEntries = !viewModel.entries.isEmpty
        tabelView.isHidden = isCalendar || !hasEntries
        emptyView.isHidden = isCalendar || hasEntries
        calendarContainerView.isHidden = !isCalendar
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) { updateView() }

    @IBAction func writeButtonTapped(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let navVC = sb.instantiateViewController(withIdentifier: "RecordNavVC") as? UINavigationController,
              let recordVC = navVC.topViewController as? RecordViewController else { return }
        recordVC.viewModel = viewModel
        navVC.modalPresentationStyle = .pageSheet
        present(navVC, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let detail = segue.destination as? DiaryDetailViewController,
           let entry = sender as? DiaryEntry {
            detail.entry = entry
            detail.viewModel = viewModel
            detail.onDelete = { [weak self] in
                self?.viewModel.delete(id: entry.id)
                self?.tabelView.reloadData()
                self?.updateView()
            }
        }
    }
}

extension DiaryListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.entries.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryCell.identifier, for: indexPath) as! DiaryCell
        cell.configure(with: viewModel.entries[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.delete(at: indexPath.row)
            tabelView.deleteRows(at: [indexPath], with: .automatic)
            updateView()
        }
    }
}

extension DiaryListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabelView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showDetail", sender: viewModel.entries[indexPath.row])
    }
}
