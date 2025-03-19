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
    
}
