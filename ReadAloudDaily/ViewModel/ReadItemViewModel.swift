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
    @Published var newCreatedItem: ReadItemModel = ReadItemModel(
        title: "",
        startDate: Date(),
        endDate: Date(),
        dailyReadingTime: 0,
        isCompleted: false
    )
    
    @Published var readItems: [ReadItemModel] = []
    @Published var errorMessage: String?
    
    @Published var isFormValid: Bool = false
    @Published var isDateValid: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    private let coredataManager = CoreDataManager.shared
    
    
    // MARK: - Init
    init() {
        setupBindings()
    }
    
    /// 유효성 검사 진행 - (newCreatedItem이 변경될 때 실행)
    private func setupBindings() {
        $newCreatedItem
            .sink { [weak self] _ in
                self?.validReadItemForm()
                self?.validDateForm()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Function: 유효성 검사
    func validReadItemForm() {
        guard newCreatedItem.title.count >= 1,
              newCreatedItem.dailyReadingTime >= 60 else {
                  isFormValid = false
                  print("❌ 유효성 검사 실패: 제목 1자 이상, 독서 시간 1분 이상 필요")
                  return
              }
        
        isFormValid = true
        print("✅ 유효성 검사 통과")
    }
    
    
    func validDateForm() {
        guard newCreatedItem.endDate < newCreatedItem.startDate else {
            isDateValid = false
            print("❌ 날짜 유효성 실패 ")
            return
        }
        isDateValid = true
        print("✅ 날짜 유요성 통과")
    }

    
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
    
    
    // 저장된 독서계획을 수정하는 메서드
    func updateReadItem(_ item: ReadItemModel) {
        print("📤 ReadItemViewModel: 독서 계획 업데이트 요청 - \(item.title)")
        
        coredataManager.updateReadItem(item)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ ReadItemViewModel: 수정 완료 - \(item.title)")
                case .failure(let error):
                    print("❌ ReadItemViewModel: 수정 실패 - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedItem in
                if let index = self?.readItems.firstIndex(where: {  $0.id == updatedItem.id }) {
                    print("📌 ReadItemViewModel: 배열 내 기존 값 업데이트 - \(updatedItem.title)")
                    self?.readItems[index] = updatedItem
                } else {
                    print("⚠️ ReadItemViewModel: 업데이트할 데이터가 배열에서 찾을 수 없음")
                }
            }
            .store(in: &cancellables)
    }
    
    
    // 저장된 독서계획을 삭제하는 메서드
    func deleteReadItem(with id: String) {
        
        print("📤 ReadItemViewModel: 독서 계획 삭제 요청 - ID: \(id)")
        
        coredataManager.deleteReadItem(with: id)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ ReadItemViewModel: 삭제 완료 - ID: \(id)")
                case .failure(let error):
                    print("❌ ReadItemViewModel: 삭제 실패 - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                print("📌 ReadItemViewModel: readItems 배열에서 삭제 - ID: \(id)")
                self?.readItems.removeAll { $0.id.uuidString == id }
            }
            .store(in: &cancellables)
    }
}

