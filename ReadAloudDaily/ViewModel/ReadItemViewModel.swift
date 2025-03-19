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
}

