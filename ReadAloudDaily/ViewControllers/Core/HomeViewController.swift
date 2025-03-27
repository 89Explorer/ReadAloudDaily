//
//  ViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit
import Combine


class HomeViewController: UIViewController {
    
    // MARK: - Variables
    private let viewModel: ReadItemViewModel = ReadItemViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    
    
    // MARK: - UI Components
    private let addItemButton: UIButton = UIButton(type: .system)
    private let readItemTableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground
        didTappedAddItemButton()
        setupUI()
        
        setupNavigationLeftTitle()
        setupBinding()

        //testViewBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("🔄 HomeViewController: viewWillAppear - 데이터 갱신 실행")
        viewModel.fetchReadItems()
    }
    
    
    // MARK: - Functions
    private func setupBinding() {
        viewModel.$readItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.readItemTableView.reloadData()
                print("📢 HomeViewController: TableView 데이터 업데이트 ")
            }
            .store(in: &cancellables)
    }
    
    
    private func didTappedAddItemButton() {
        addItemButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addItem() {
        let addItemVC = AddPlanViewController(mode: .create, readItem: nil)
        
        if let sheet = addItemVC.sheetPresentationController {
            
            //sheet.detents = [.medium()]
            sheet.detents = [
                .custom { _ in
                    450.0
                }
            ]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 25
        }
        present(addItemVC, animated: true)
    }
}


// MARK: - Setting UI
extension HomeViewController {
    
    private func setupUI() {
        
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        
        addItemButton.setImage(plusImage, for: .normal)
        addItemButton.tintColor = .label
        addItemButton.backgroundColor = .systemIndigo
        addItemButton.layer.cornerRadius = 20
        addItemButton.layer.masksToBounds = true
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        
        readItemTableView.showsVerticalScrollIndicator = false
        readItemTableView.backgroundColor = .clear
        readItemTableView.separatorStyle = .none
        readItemTableView.register(ReadItemCell.self, forCellReuseIdentifier: ReadItemCell.reuseIdentifier)
        readItemTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        readItemTableView.delegate = self
        readItemTableView.dataSource = self
        readItemTableView.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(readItemTableView)
        view.addSubview(addItemButton)
        
        NSLayoutConstraint.activate([
            
            
            readItemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            readItemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            readItemTableView.topAnchor.constraint(equalTo: view.topAnchor),
            readItemTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            
            addItemButton.centerXAnchor.constraint(equalTo: readItemTableView.centerXAnchor),
            addItemButton.bottomAnchor.constraint(equalTo: readItemTableView.bottomAnchor, constant: -40),
            addItemButton.widthAnchor.constraint(equalToConstant: 40),
            addItemButton.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }
}


// MARK: - 폰트 확인 메서드
extension HomeViewController {
    func printAllFonts() {
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print(" - \(fontName)")
            }
        }
    }
    
}


// MARK: - Extension: UITableViewDelegate 설정
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    private var progressReadItems: [ReadItemModel] {
        return viewModel.readItems.filter { !$0.isCompleted }
    }
    
    private var completedReadItems: [ReadItemModel] {
        return viewModel.readItems.filter { $0.isCompleted }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ReadItemTableSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = ReadItemTableSection.allCases[section]
        
        switch section {
        case .progress:
            return progressReadItems.count
        case .completed:
            return completedReadItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = ReadItemTableSection.allCases[indexPath.section]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ReadItemCell.reuseIdentifier, for: indexPath) as? ReadItemCell else { return UITableViewCell() }
        
        switch section {
        case .progress:
            cell.configure(progressReadItems[indexPath.row])
            cell.selectionStyle = .none
            cell.delegate = self
            return cell
        case .completed:
            cell.configure(completedReadItems[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let section = ReadItemTableSection.allCases[indexPath.section]
        
        switch section {
        case .progress:
            let selectedItem = progressReadItems[indexPath.item]
            let detailVC = DetailViewController(readItem: selectedItem)
            self.navigationController?.pushViewController(detailVC, animated: true)
        case .completed:
            let seletedItem = completedReadItems[indexPath.item]
            let detailVC = DetailViewController(readItem: seletedItem)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ReadItemTableSection.allCases[section].title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont(name: "HakgyoansimDunggeunmisoTTF-R", size: 20)
        header.textLabel?.textColor = .label
    }
}


// MARK: - Extension: 네비게이션바 왼쪽에 타이틀 설정
extension HomeViewController {
    
    private func setupNavigationLeftTitle() {
        let today = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "M월 dd일"
        let dateString = dateFormat.string(from: today)
        
        let titleLabel: UILabel = UILabel()
        titleLabel.text = dateString
        titleLabel.font = UIFont.boldSystemFont(ofSize: 28)
        titleLabel.textColor = .label
        
        let leftBarButton = UIBarButtonItem(customView: titleLabel)
        navigationItem.leftBarButtonItem = leftBarButton
    }
}



// MARK: - Enum: ReadItemTableSection의 셀 관리 목적 섹션
enum ReadItemTableSection: CaseIterable {
    case progress
    case completed
    
    var title: String {
        switch self {
        case .progress:
            return "📖 진행 중인 도서 계획"
        case .completed:
            return "📘 완료된 도서 계획"
        }
    }
}




// MARK: - Extension: ReadItemSettingButtonDelegate
extension HomeViewController: ReadItemSettingButtonDelegate {
    
    func didTappedStartButton(for item: ReadItemModel, from sender: UIButton) {
        print("⏰ 타이머 버튼 누름 - ID: \(item.id)")
        
//        let timerVC = TimerViewController(readItem: item)
//        
//        if let sheet = timerVC.sheetPresentationController {
//            sheet.detents = [
//                .custom { _ in
//                    450.0
//                }
//            ]
//            sheet.preferredCornerRadius = 25
//            sheet.prefersGrabberVisible = true
//        }
//        self.present(timerVC, animated: true)
        
        let timerVC = TimerViewController(readItem: item)
        navigationController?.pushViewController(timerVC, animated: true)
    }
    
    
    func didTappedSettingButton(for item: ReadItemModel, from sender: UIButton) {
        print("⚙️ 설정 버튼 누름 - ID: \(item.id)")
        
        let alert = UIAlertController(title: "수정 또는 삭제를 하시겠습니까?", message: nil, preferredStyle: .actionSheet)
        
        let edit = UIAlertAction(title: "수정", style: .default) { _ in
            print("✏️ 수정 - \(item.title)")
            // 수정 뷰로 push/present
            let addItemVC = AddPlanViewController(mode: .edit, readItem: item)
            
            if let sheet = addItemVC.sheetPresentationController {
                
                //sheet.detents = [.medium()]
                sheet.detents = [
                    .custom { _ in
                        450.0
                    }
                ]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 25
            }
            self.present(addItemVC, animated: true)
        }
        
        let delete = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            print("🗑️ 삭제 - \(item.id)")
            self?.viewModel.deleteReadItem(with: item.id.uuidString)
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(edit)
        alert.addAction(delete)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}




// MARK: - 독서계획의 CRUD 동작 확인을 목적으로 한 메서드 모음 (Combine + MVVM)
extension HomeViewController {
    
    // MARK: - Function
    func testViewBinding() {
        
        // Create
        viewModel.$newCreatedItem
            .sink { testItem in
                print("ViewController: 테스트 목적 독서 계획 업데이트 됨")
                print("    - Title: \(testItem.title)")
            }
            .store(in: &cancellables)
        
        // Read 메서드 확인 목적
        //        viewModel.$readItems
        //            .sink { readItems in
        //                print("🎯 ViewController: ReadItemViewModel에서 업데이트된 독서 계획 개수: \(readItems.count) 개")
        //            }
        //            .store(in: &cancellables)
        
        // Update 메서드 확인 목적
        //        viewModel.$readItems
        //            .sink { readItems in
        //                print("🎯 ViewController: 업데이트된 독서 계획 개수: \(readItems.count) 개")
        //                for item in readItems {
        //                    print("   - \(item.title) | 완료 여부: \(item.isCompleted)")
        //                }
        //            }
        //            .store(in: &cancellables)
    }
    
    
    // 독서 계획 생성
    func savedReadItem() {
        let testReadItem = ReadItemModel(
            title: "CoreDataManager & ViewModel 확인 목적",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            dailyReadingTime: 60 * 3,
            isCompleted: false)
        
        print("📍 ViewController: createNewReadItem() 호출")
        viewModel.createNewReadItem(testReadItem)
    }
    
    // 독서 계획 수정
    //    func updateTestReadItem() {
    //        guard let existingItem = viewModel.readItems.first(where: { $0.title == "CoreDataManager & ViewModel 확인 목적" }) else {
    //            print("❌ ViewController: 수정할 테스트 데이터가 없음!")
    //            return
    //        }
    //
    //        var updatedItem = existingItem
    //        updatedItem.title = "✅ 수정된 CoreData 테스트 데이터"
    //        updatedItem.isCompleted = true
    //
    //        print("🔨ViewController: updateReadItem() 호출")
    //        viewModel.updateReadItem(existingItem)
    //    }
    
    func deleteTestReadItem() {
        guard let itemToDelete = viewModel.readItems.first(where: { $0.title == "✅ 수정된 CoreData 테스트 데이터" }) else {
            print("❌ ViewController: 삭제할 테스트 데이터가 없음!")
            return
        }
        
        print("🗑 ViewController: deleteReadItem() 호출 - ID: \(itemToDelete.id.uuidString)")
        viewModel.deleteReadItem(with: itemToDelete.id.uuidString)
    }
}


