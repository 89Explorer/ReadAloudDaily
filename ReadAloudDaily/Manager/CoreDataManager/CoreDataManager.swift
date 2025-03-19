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
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: - Functions: Core Data CRUD
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
    
}
