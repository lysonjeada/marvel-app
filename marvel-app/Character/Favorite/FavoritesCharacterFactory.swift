import Foundation

enum FavoritesCharacterFactory {
    static func build() -> FavoritesCharacterViewController {
        let useCase = CharacterListUseCase()
        let viewModel = FavoritesCharacterViewModel()
        let view = FavoritesCharacterViewController()
        
        view.viewModel = viewModel
        
        return view
    }
}
