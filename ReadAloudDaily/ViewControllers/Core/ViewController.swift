//
//  ViewController.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/17/25.
//

import UIKit
import Combine


class ViewController: UIViewController {
    
    
    // MARK: - UI Components
    private let addItemButton: UIButton = UIButton(type: .system)
    private let viewModel: ReadItemViewModel = ReadItemViewModel()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
        didTappedAddItemButton()
        setupUI()
        
        viewModel.fetchReadItems()
        
        testViewBinding()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateTestReadItem()
        }
    }
    
    
    // MARK: - Functions
    private func didTappedAddItemButton() {
        addItemButton.addTarget(self, action: #selector(addItem), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func addItem() {
        let addItemVC = AddPlanViewController()
        
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
extension ViewController {
    
    private func setupUI() {
        
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let plusImage = UIImage(systemName: "plus", withConfiguration: config)
        
        addItemButton.setImage(plusImage, for: .normal)
        addItemButton.tintColor = .label
        addItemButton.backgroundColor = .systemBackground
        addItemButton.layer.cornerRadius = 20
        addItemButton.layer.masksToBounds = true
        addItemButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(addItemButton)
        
        NSLayoutConstraint.activate([
            
            addItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addItemButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addItemButton.widthAnchor.constraint(equalToConstant: 40),
            addItemButton.heightAnchor.constraint(equalToConstant: 40)
            
            
        ])
    }
}


// MARK: - 폰트 확인 메서드
extension ViewController {
    func printAllFonts() {
        for family in UIFont.familyNames {
            print("Font Family: \(family)")
            for fontName in UIFont.fontNames(forFamilyName: family) {
                print(" - \(fontName)")
            }
        }
    }
    
}


// MARK: - 독서계획의 CRUD 동작 확인을 목적으로 한 메서드 모음 (Combine + MVVM)
extension ViewController {
    
    // MARK: - Function
    func testViewBinding() {
        
        // Create
        //        viewModel.$newCreatedItem
        //            .sink { testItem in
        //                guard let testItem = testItem  else { return }
        //                print("ViewController: 테스트 목적 독서 계획 업데이트 됨")
        //                print("    - Title: \(testItem.title)")
        //            }
        //            .store(in: &cancellables)
        
        // Read 메서드 확인 목적
        //        viewModel.$readItems
        //            .sink { readItems in
        //                print("🎯 ViewController: ReadItemViewModel에서 업데이트된 독서 계획 개수: \(readItems.count) 개")
        //            }
        //            .store(in: &cancellables)
        
        // Update 메서드 확인 목적
        viewModel.$readItems
            .sink { readItems in
                print("🎯 ViewController: 업데이트된 독서 계획 개수: \(readItems.count) 개")
                for item in readItems {
                    print("   - \(item.title) | 완료 여부: \(item.isCompleted)")
                }
            }
            .store(in: &cancellables)
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
    func updateTestReadItem() {
        guard let existingItem = viewModel.readItems.first(where: { $0.title == "CoreDataManager & ViewModel 확인 목적" }) else {
            print("❌ ViewController: 수정할 테스트 데이터가 없음!")
            return
        }
        
        var updatedItem = existingItem
        updatedItem.title = "✅ 수정된 CoreData 테스트 데이터"
        updatedItem.isCompleted = true
        
        print("🔨ViewController: updateReadItem() 호출")
        viewModel.updateReadItem(existingItem)
    }
    
}
