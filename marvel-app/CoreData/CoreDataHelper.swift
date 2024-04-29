import UIKit
import CoreData

class Character: NSManagedObject {
    @NSManaged var title: String
    @NSManaged var characterDescription: String
    @NSManaged var image: String
}

class CoreDataHelper {
    static let shared = CoreDataHelper()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CharacterModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveCharacter(title: String, description: String, image: String) {
        let context = persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Character", in: context) else { return }
        let newCharacter = Character(entity: entityDescription, insertInto: context)
        newCharacter.title = title
        newCharacter.characterDescription = description
        newCharacter.image = image
        
        do {
            try context.save()
            print("Character saved successfully!")
        } catch {
            print("Failed to save character: \(error)")
        }
    }
}

