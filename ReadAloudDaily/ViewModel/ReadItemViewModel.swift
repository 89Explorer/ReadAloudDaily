//
//  ReadItemViewModel.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/19/25.
//

import Foundation
import Combine
import UIKit


class ReadItemViewModel: ObservableObject {
    
    // MARK: - Variables
    @Published var newCreatedItem: ReadItemModel?
    @Published var readItems: [ReadItemModel] = []
    @Published var errorMessage: String?
    private var cancellables: Set<AnyCancellable> = []
    private let coredataManager = CoreDataManager.shared
    
    
    // MARK: - Functions: CRUD
    // 새 독서계획을 저장하는 메서드
    func createNewReadItem(_ item: ReadItemModel) {
        print("📤 ReadItemViewModel: 새로운 독서 계획 저장 요청")
        
        coredataManager.createReadItem(item)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ ReadItemViewModel: 독서 계획 저장이 완료되었습니다!")
                case .failure(let error):
                    print("❌ ReadItemViewModel: 저장 실패 - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newReadItem in
                print("🎯 ReadItemViewModel: 저장된 독서 계획 확인")
                print("   - ID: \(newReadItem.id)")
                print("   - Title: \(newReadItem.title)")
                print("   - Start Date: \(newReadItem.startDate)")
                print("   - End Date: \(newReadItem.endDate)")
                print("   - Daily Reading Time: \(newReadItem.dailyReadingTime)")
                print("   - Is Completed: \(newReadItem.isCompleted)")
                
                self?.newCreatedItem = newReadItem
                self?.readItems.append(newReadItem)
                print("📌 ReadItemViewModel: readItems 배열 업데이트 완료")
            }
            .store(in: &cancellables)
    }
    
    
    // 저장된 독서계획을 불러오는 메서드
    func fetchReadItems() {
        print("📤 ReadItemViewModel: 독서 계획 불러오기 요청")
        
        coredataManager.fetchReadItems()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ ReadItemViewModel: 독서 계획을 불러오기 완료")
                case .failure(let error):
                    print("❌ ReadItemViewModel: 불러오기 실패 - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] readItems in
                print("📌 ReadItemViewModel: 받은 독서 계획 개수: \(readItems.count) 개")
                
                for (index, item) in readItems.enumerated() {
                    print("   \(index + 1). \(item.title) - \(item.startDate) ~ \(item.endDate)")
                }
                
                self?.readItems = readItems
            }
            .store(in: &cancellables)
    }
}

