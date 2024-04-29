import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configurar os view controllers
        let charactersViewController = CharacterListFactory.build()
        charactersViewController.title = "Characters"
        
        let favoritesViewController = FavoritesCharacterFactory.build()
        favoritesViewController.title = "Favorites"
        
        // Configurar os ícones dos itens da barra de tabulação
        charactersViewController.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person.crop.circle"), selectedImage: nil)
        favoritesViewController.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(systemName: "heart.circle.fill"), selectedImage: nil)
        
        // Adicionar os view controllers à tab bar
        viewControllers = [charactersViewController, favoritesViewController]
    }
}
