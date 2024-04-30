import UIKit

enum CharacterListFactory {
    static func build() -> UINavigationController {
        let useCase = CharacterListUseCase()
        let viewModel = CharacterListViewModel(useCase: useCase)
        let view = CharacterListViewController()
        
        view.viewModel = viewModel
        let nc = UINavigationController(rootViewController: view)
        return nc
    }
}
