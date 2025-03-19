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
        savedReadItem()
        
        viewModel.$newCreatedItem
            .sink { testItem in
                guard let testItem = testItem  else { return }
                print("ViewController: 테스트 목적 독서 계획 업데이트 됨")
                print("    - Title: \(testItem.title)")
            }
            .store(in: &cancellables)

    }
    
    // TEST
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
