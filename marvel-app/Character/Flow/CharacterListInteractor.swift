import Foundation

protocol CharacterListInteractorProtocol {
    func fetchCharacters()
}

class CharacterListInteractor: CharacterListInteractorProtocol {
    
    private let useCase: CharacterListUseCase
    private let presenter: CharacterListPresenterProtocol
    
    init(useCase: CharacterListUseCase, presenter: CharacterListPresenterProtocol) {
        self.useCase = useCase
        self.presenter = presenter
    }
    
    func fetchCharacters() {
        useCase.fetch { [weak self] result in
            switch result {
            case .success(let characters):
                self?.presenter.didFetchCharacters(characters: characters.data.results)
            case .failure(let error):
                self?.presenter.didFailToFetchCharacters(error: error)
            }
        }
    }
    
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map { startIndex in
            let endIndex = Swift.min(startIndex + size, count)
            return Array(self[startIndex..<endIndex])
        }
    }
}

