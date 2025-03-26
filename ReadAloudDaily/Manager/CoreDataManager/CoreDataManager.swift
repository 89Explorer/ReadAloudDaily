//
//  CoreDataManager.swift
//  ReadAloudDaily
//
//  Created by 권정근 on 3/18/25.
//

import Foundation
import CoreData
import UIKit
import Combine


final class CoreDataManager {
    
    // MARK: - Variables
    static let shared: CoreDataManager = CoreDataManager()
    
    // CRUD 목적의 viewcontext 호출
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - Functions: Core Data CRUD - 독서 계획
    // CREATE
    func createReadItem(_ item: ReadItemModel) -> AnyPublisher<ReadItemModel, Error> {
        return Future<ReadItemModel, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(Error.self as! Error))
                return
            }
            
            let createdItem: ReadItemModel = item
            
            let readItem = ReadItem(context: self.context)
            readItem.id = createdItem.id
            readItem.title = createdItem.title
            readItem.startDate = createdItem.startDate
            readItem.endDate = createdItem.endDate
            readItem.dailyReadingTime = createdItem.dailyReadingTime
            readItem.isCompleted = createdItem.isCompleted
            
            print("📝 CoreDataManager: 저장할 데이터 확인")
            print("   - ID: \(createdItem.id)")
            print("   - Title: \(createdItem.title)")
            print("   - Start Date: \(createdItem.startDate)")
            print("   - End Date: \(createdItem.endDate)")
            print("   - Daily Reading Time: \(createdItem.dailyReadingTime)")
            print("   - Is Completed: \(createdItem.isCompleted)")
            
            do {
                try self.context.save()
                print("✅ CoreDataManager: 독서 계획이 성공적으로 저장되었습니다 🎊")
                promise(.success(createdItem))
            } catch {
                print("독서 계획의 저장을 실패했습니다.: \(error)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // Read
    func fetchReadItems() -> AnyPublisher<[ReadItemModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                print("❌ CoreDataManager: self가 nil이므로 종료")
                return
            }
            
            let request: NSFetchRequest<ReadItem> = ReadItem.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
            
            do {
                let results = try self.context.fetch(request)
                print("📥 CoreDataManager: Fetch 성공, 총 \(results.count)개의 데이터")
                
                let readItems = results.compactMap { readItem -> ReadItemModel? in
                    guard let id = readItem.id,
                          let title = readItem.title,
                          let startDate = readItem.startDate,
                          let endDate = readItem.endDate else {
                        print("❌ Core Data에서 nil 값이 포함된 항목 발견, 해당 항목 제외")
                        return nil
                    }
                    
                    print("📌 CoreDataManager: 데이터 변환 성공 - \(title)")
                    return ReadItemModel(
                        id: id,
                        title: title,
                        startDate: startDate,
                        endDate: endDate,
                        dailyReadingTime: readItem.dailyReadingTime,
                        isCompleted: readItem.isCompleted
                    )
                }
                
                promise(.success(readItems))
                print("✅ CoreDataManager: 최종 반환할 독서 계획 개수: \(readItems.count) 개")
            } catch {
                promise(.failure(error))
                print("❌ CoreDataManager: 독서 계획 불러오기 실패 - \(error.localizedDescription)")
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // Read: Id를 통해서 해당하는 데이터 불러오기
    func fetchReadItem(by id: UUID) -> ReadItem? {
        let request: NSFetchRequest<ReadItem> = ReadItem.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg) // ✅ 특정 ID만 필터링
        
        do {
            let results = try context.fetch(request)
            return results.first // ✅ 결과가 있으면 첫 번째 항목 반환
        } catch {
            print("❌ CoreDataManager: ReadItem(id: \(id)) 찾기 실패 - \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
    
    // Update
    func updateReadItem(_ readItem: ReadItemModel) -> AnyPublisher<ReadItemModel, Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                print("❌ CoreDataManager: self가 nil이므로 종료")
                return
            }
            
            print("📤 CoreDataManager: 업데이트 요청 - ID: \(readItem.id), 제목: \(readItem.title)")
            
            let request: NSFetchRequest<ReadItem> = ReadItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", readItem.id as CVarArg)
            
            do {
                let results = try self.context.fetch(request)
                print("📥 CoreDataManager: Fetch 성공, 총 \(results.count)개의 데이터")
                
                guard let readItemToUpdate = results.first else {
                    print("❌ CoreDataManager: 해당 ID의 데이터가 존재하지 않음")
                    throw NSError(domain: "CoreDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "ReadItem not found."])
                }
                
                print("✏️ CoreDataManager: 기존 값 → 제목: \(readItemToUpdate.title ?? "실패"), 시작일: \(readItemToUpdate.startDate ?? Date()), 완료 여부: \(readItemToUpdate.isCompleted)")
                
                
                // ✅ 값 업데이트
                readItemToUpdate.title = readItem.title
                readItemToUpdate.startDate = readItem.startDate
                readItemToUpdate.endDate = readItem.endDate
                readItemToUpdate.dailyReadingTime = readItem.dailyReadingTime
                readItemToUpdate.isCompleted = readItem.isCompleted
                
                try self.context.save()
                print("✅ CoreDataManager: 수정 완료! - 새 제목: \(readItemToUpdate.title ?? "실패"), 완료 여부: \(readItemToUpdate.isCompleted)")
                
                promise(.success(readItem)) // ✅ 성공 시 업데이트된 데이터 반환
                
            } catch {
                print("❌ CoreDataManager: 수정 실패: \(error.localizedDescription)")
                promise(.failure(error)) // ❌ 실패 시 에러 반환
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // Delete
    func deleteReadItem(with id: String) -> AnyPublisher<Void, Error> {
        return Future{ [weak self] promise in
            guard let self = self else {
                print("❌ CoreDataManager: self가 nil이므로 종료")
                return
            }
            
            print("📤 CoreDataManager: 삭제 요청 - ID: \(id)")
            
            let request: NSFetchRequest<ReadItem> = ReadItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            do {
                let results = try self.context.fetch(request)
                
                print("📥 CoreDataManager: Fetch 성공, 삭제할 데이터 개수: \(results.count) 개")
                
                guard let readItemToDelete = results.first else {
                    print("❌ CoreDataManager: 해당 ID의 데이터가 존재하지 않음")
                    throw NSError(domain: "CoreDataError", code: 404, userInfo: [NSLocalizedDescriptionKey: "ReadItem not found."])
                }
                
                print("🗑 CoreDataManager: 삭제할 데이터 → 제목: \(readItemToDelete.title ?? "삭제 실패")")
                
                self.context.delete(readItemToDelete)
                try self.context.save()
                
                print("✅ CoreDataManager: 삭제 완료 - \(readItemToDelete.title ?? "삭제 성공")")
                
                promise(.success(()))
            } catch {
                print("❌ CoreDataManager: 삭제 실패 - \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // MARK: - Functions: Core Data CRUD - 독서 메모
    
    // Create
    func createReadMemo(_ memoModel: ReadMemoModel, for parentItem: ReadItem) -> AnyPublisher<ReadMemoModel, Error> {
        
        return Future<ReadMemoModel, Error> { [weak self] promise in
            guard let self = self else {
                print("❌ CoreDataManager: self가 nil이므로 종료")
                return
            }
            
            let memo = ReadMemo(context: self.context)
            memo.id = memoModel.id
            memo.memo = memoModel.memo
            memo.page = Int32(memoModel.page)
            memo.createOn = Date()
            memo.parent = parentItem   // ✅ 관계설정
            
            print("📝 CoreDataManager: 저장할 메모 데이터 확인")
            print("   - ID: \(memoModel.id)")
            print("   - Memo: \(memoModel.memo)")
            print("   - page: \(memoModel.page)")
            print("   - createOn: \(memo.createOn ?? Date())")
            
            do {
                try self.context.save()
                print("✅ CoreDataManager: 독서 메모 저장 완료!")
                promise(.success(memoModel))
            } catch {
                print("❌ CoreDataManager: 메모 저장 실패: \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    // Read
    func fetchReadMemos(for readItemID: UUID) -> AnyPublisher<[ReadMemoModel], Error> {
        return Future { [weak self] promise in
            guard let self = self else {
                print("❌ CoreDataManager: self가 nil이므로 종료")
                return
            }
            
            let request: NSFetchRequest<ReadMemo> = ReadMemo.fetchRequest()
            
            // id에서 readItemID를 추출하여 필터링 조건을 추가
            let readItemIDString = readItemID.uuidString
            
            
            // "readItemID_readMemoID" 형식의 ID에서 readItemID 부분만 필터링하여 사용
            request.predicate = NSPredicate(format: "id BEGINSWITH %@", readItemIDString as CVarArg)
            request.sortDescriptors = [NSSortDescriptor(key: "createOn", ascending: false)]
            
            do {
                let results = try self.context.fetch(request)
                print("⭐️ CoreDataManager: Fetch 성공, 총 \(results.count) 개의 데이터")
                
                let readMemos = results.compactMap { readMemo -> ReadMemoModel? in
                    guard let id = readMemo.id,
                          let memo = readMemo.memo,
                          let createOn = readMemo.createOn else {
                        print("❌ Core Data에서 nil 값이 포함된 항목 발견, 해당 항목 제외")
                        return nil
                    }
                    
                    return ReadMemoModel(
                        id: id,
                        memo: memo,
                        page: Int(readMemo.page))
                }
                promise(.success(readMemos))
            } catch {
                promise(.failure(error))
                print("❌ CoreDataManager: ReadMemo 불러오기 실패 - \(error.localizedDescription)")
            }
        }
        .eraseToAnyPublisher()
    }
}
