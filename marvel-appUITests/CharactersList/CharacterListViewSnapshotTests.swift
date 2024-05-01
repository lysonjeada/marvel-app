import XCTest
import CoreData
import SnapshotTesting

@testable import marvel_app

class MockCharacterListUseCase: CharacterListUseCase {
    var fetchCalled = false
    var isSuccess = false
    var methodsCalled: [MethodsCalled] = []
    
    enum MethodsCalled: Equatable {
        case successFetch
        case failureFetch
        case fetchCharactersFailureCalled
        case showErrorCalled(error: String)
    }
    
    func fetch(completion: @escaping (Result<MarvelCharacter, Error>) -> Void) {
        if isSuccess {
            let characterLoadedFromJson = loadMarvelCharacters(from: "characters-list")
            characterLoadedFromJson?.forEach({ character in
                completion(.success(character))
            })
            methodsCalled.append(.successFetch)
        } else {
            self.methodsCalled.append(.showErrorCalled(error: "Unknown Error"))
            self.methodsCalled.append(.fetchCharactersFailureCalled)
        }
        
        fetchCalled = true
    }
    
    func loadMarvelCharacters(from filename: String) -> [MarvelCharacter]? {
        if let url = Bundle.main.url(forResource: filename, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let characters = try decoder.decode([MarvelCharacter].self, from: data)
                return characters
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }
}


class CharacterListViewSnapshotTests: XCTestCase {
    
    func testViewWhenHasError() {
        let useCase = MockCharacterListUseCase()
        let viewModel = CharacterListViewModel(useCase: useCase)
        let view = CharacterListViewController()
        
        viewModel.error = .errorConnection
        
        view.viewModel = viewModel
        
                let vc = CharacterListViewController()
        
        assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
    }
}
