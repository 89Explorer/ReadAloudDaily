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
    @Published var isFormValid: Bool = false
    
    private var cancellables: Set<AnyCancellable> = []
    let coredataManager = CoreDataManager.shared
    
    
    init() {
        observeCoreDataChanges()
    }
    
    
    // 유효성 검사 진행 - newReadMemo가 변경될 때 실행
    private func setupBindings() {
        $newReadMemo
            .sink { [weak self] _ in
                self?.validReadMemoForm()
            }
            .store(in: &cancellables)
    }
    
    
    
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
    
    
    
    // MARK: - Function: 유효성 검사
    func validReadMemoForm() {
        guard newReadMemo.memo.count < 300 else {
            
            isFormValid = false
            print("❌ 유효성 검사 실패: ")
            return
        }
        
        isFormValid = true
        print("✅ 유효성 검사 통과")
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
    
    
    // Read
    func fetchReadMemos() {
        guard let parent = selectedReadItem else {
            print("❌ AddMemoViewModel: selectedReadItem이 nil이라 fetch 중단!")
            return }
        
        print("📍 AddMemoViewModel: 독서 메모 불러오기 요청")
        
        coredataManager.fetchReadMemos(for: parent.id!)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ AddMemoViewModel: 독서 메모 불러오기 완료")
                case .failure(let error):
                    print("❌ AddMemoViewModel: 불러오기 실패 - \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] readMemos in
                print("📍 AddMemoViewModel: 받은 독서 메모 갯수: \(readMemos.count) 개")
                
                self?.readMemos = readMemos
            }
            .store(in: &cancellables)
    }
    
    /// 🧮 CoreData 변경 감지, 메서드
    private func observeCoreDataChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: coredataManager.context)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("🔄 CoreData (메모) 변경 감지 - 데이터 재로딩")
                self?.fetchReadMemos()
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
