import Foundation

enum CharacterListFactory {
    static func build() -> CharacterListViewController {
        let useCase = CharacterListUseCase()
        let viewModel = CharacterListViewModel(useCase: useCase)
        let view = CharacterListViewController()
        
        view.viewModel = viewModel
        
        return view
    }
}
