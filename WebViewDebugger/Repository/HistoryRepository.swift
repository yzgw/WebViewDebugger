//
//  History.swift
//  WebViewPlayground
//
//  Created by Takuto Yoshikawa on 2022/09/24.
//

import UIKit
import CoreData

class HistoryRepository {

    private var persistentContainer: NSPersistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer

    func save(value: History) {
        persistentContainer.viewContext.insert(value)
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                return;
            }
        }
    }

    func get(limit: Int = 100) -> [History] {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<History>(entityName: "History")
        request.fetchLimit = limit
        let sortDescripter = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sortDescripter]
        do {
            let histories = try context.fetch(request)
            return histories
        }
        catch {
            fatalError()
        }
    }
}

extension History {
    static func create() -> History {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "History", in: context)!
        let history = History(entity: entity, insertInto: nil)
        return history
    }
}
