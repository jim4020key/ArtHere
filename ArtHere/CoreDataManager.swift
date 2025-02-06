//
//  CoreDataManager.swift
//  ArtHere
//
//  Created by kimjimin on 2/4/25.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ArtHere")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    func addFavorite(museumName: String) {
        let context = persistentContainer.viewContext
        let museum = FavoriteMuseum(context: context)
        museum.name = museumName
        museum.lastUpdated = Date()
        
        saveContext()
    }
    
    func removeFavorite(museumName: String) {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteMuseum> = FavoriteMuseum.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", museumName)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let museum = results.first {
                context.delete(museum)
                saveContext()
            }
        } catch {
            print("Failed to remove favorite: \(error)")
        }
    }
    
    func isFavorite(museumName: String) -> Bool {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteMuseum> = FavoriteMuseum.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", museumName)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check favorite: \(error)")
            return false
        }
    }
    
    private func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save Core Data context: \(error)")
            }
        }
    }
}
