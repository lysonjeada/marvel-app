import Foundation
import CoreData

protocol CharacterListViewModelProtocol {
    func fetchCharacters(completion: @escaping ([CharacterInfo]?) -> Void)
    var characters: [CharacterInfo] { get }
    var error: Error? { get }
}

class CharacterListViewModel: CharacterListViewModelProtocol {
    
    private let useCase: CharacterListUseCase
    
    var characters: [CharacterInfo] = []
    var error: Error?
    
    init(useCase: CharacterListUseCase) {
        self.useCase = useCase
    }
    
    func fetchCharacters(completion: @escaping ([CharacterInfo]?) -> Void) {
        useCase.fetch { [weak self] result in
            switch result {
            case .success(let characters):
                characters.data.results.forEach { character in
                    let characterInfo = CharacterInfo(name: character.name,
                                                      description: self?.returnDescriptionAndTextIfItsEmpty(character: character) ?? "",
                                                      thumbnailPath: character.thumbnail.path,
                                                      thumbnailExtension: character.thumbnail.extension)
                    self?.characters.append(characterInfo)
                    DispatchQueue.main.async {
                        completion(self?.characters)
                    }
                    
                }
            case .failure(let error):
                self?.error = error
            }
        }
    }
    
    private func returnDescriptionAndTextIfItsEmpty(character: MarvelCharacter) -> String {
        if character.description.isEmpty {
            return "No description :("
        }
        return character.description
    }
    
    func saveFavorite(with context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("error-Saving data")
        }
    }
}

struct CharacterInfo: Hashable {
    let name: String
    let description: String
    let thumbnailPath: String
    let thumbnailExtension: String
}
