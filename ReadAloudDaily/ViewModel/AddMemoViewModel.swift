//
//  AddMemoViewModel.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/26/25.
//

import Foundation
import Combine
import CoreData


class AddMemoViewModel {
    
    @Published var readItemModel: ReadItemModel? {
        didSet {
            fetchReadItem()    // 값이 바뀔 때마다 자동 변환
        }
    }
    @Published var selectedReadItem: ReadItem?  // CoreData의 ReadItem
    @Published var newReadMemo: ReadMemoModel = ReadMemoModel(
        parentID: UUID(),
        memo: "",
        page: 0)
    @Published var readMemos: [ReadMemoModel] = []
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    let coredataManager = CoreDataManager.shared
    
    
    
    // MARK: - Function: ReadItemModel 타입의 데이터를 ReadItem (엔티티) 타입으로 변환
    func fetchReadItem() {
        guard let model = readItemModel else { return }
        if let readItem = coredataManager.fetchReadItem(by: model.id) {
            self.selectedReadItem = readItem
            print("✅ CoreData에서 ReadItem 변환 완료: \(readItem.id ?? UUID())")
        } else {
            print("❌ CoreData에서 ReadItem을 찾을 수 없습니다.")
        }
    }
    
    
    
    
    // MARK: - Functions: CRUD
    // Create
    func createNewReadMemo(_ memo: ReadMemoModel) {
        print("🧑‍💻 AddMemoViewModel: 새로운 독서 메모 저장 요청")
        guard let parent = selectedReadItem else {
            print("❌ 저장 실패: selectedReadItem이 없습니다.")
            return
        }
        
        coredataManager.createReadMemo(memo, for: parent)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ AddMemoViewModel: 독서 메모 저장 완료되었습니다.!")
                case .failure(let error):
                    print("❌ AddMemoViewModel: 저장 실패 \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newMemo in
                print("🧑‍💻 AddMemoViewModel: 저장된 독서 메모 확인")
                print("   - ID: \(newMemo.id)")
                print("   - Memo: \(newMemo.memo)")
                print("   - Page: \(newMemo.page)")
                self?.newReadMemo = newMemo
                self?.readMemos.append(newMemo)
            }
            .store(in: &cancellables)
        
    }
    
    
    //    func createNewReadMemo(_ memo: ReadMemoModel, parentItem: ReadItem)  {
    //        print("🧑‍💻 AddMemoViewModel: 새로운 독서 메모 저장 요청")
    //
    //        let newMemo = ReadMemoModel(
    //            parentID: parentItem.id ?? UUID(),
    //            memo: memo.memo,
    //            page: memo.page
    //        )
    //
    //        coredataManager.createReadMemo(newMemo, for: parentItem)
    //            .sink { completion in
    //                switch completion {
    //                case .finished:
    //                    print("🧑‍💻 AddMemoViewModel: 독서 메모 저장 완료되었습니다.!")
    //                case .failure(let error):
    //                    print("❌ AddMemoViewModel: 저장 실패 - \(error.localizedDescription)")
    //                    self.errorMessage = error.localizedDescription
    //                }
    //            } receiveValue: { [weak self] newReadMemo in
    //                print("🧑‍💻 AddMemoViewModel: 저장된 독서 메모 확인")
    //                print("   - ID: \(newReadMemo.id)")
    //                print("   - Memo: \(newReadMemo.memo)")
    //                print("   - Page: \(newReadMemo.page)")
    //                self?.newReadMemo = newReadMemo
    //                self?.readMemos.append(newReadMemo)
    //            }
    //            .store(in: &cancellables)
    //    }
}
