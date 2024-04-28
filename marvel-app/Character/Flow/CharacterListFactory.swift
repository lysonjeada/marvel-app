import Foundation

enum CharacterListFactory {
    static func build() -> CharacterListViewController {
        let useCase = CharacterListUseCase()
        let view = CharacterListViewController()
        let presenter = CharacterListPresenter(view: view)
        let interactor = CharacterListInteractor(useCase: useCase, presenter: presenter)
        
        view.interactor = interactor
        
        return view
    }
}
