import UIKit
import CoreData
import SDWebImage

protocol FavoritesCharacterViewProtocol {
    
}

class FavoritesCharacterViewController: UIViewController, FavoritesCharacterViewProtocol {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 250)
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        return collectionView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "buscar"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    var viewModel: FavoritesCharacterViewModel?
    
    private var charactersInfo: [CharacterInfo] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        title = "Marvel Characters"
        
        displayCharacters()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func displayCharacters() {
        DispatchQueue.main.async { [weak self] in
            let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
            let characters = self?.viewModel?.returnFavorites(with: context)
            guard let characters = characters else { return }
            self?.collectionView.reloadData()
        }
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Cryptos"
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsBookmarkButton = true
        //        searchController.searchBar.setImage(UIImage(systemName: "line.horizontal.3.decrease"), for: .bookmark, state: .normal)
    }
}

extension FavoritesCharacterViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {
        //        self.viewModel.updateSearchController(searchBarText: searchController.searchBar.text)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Search bar button called!")
    }
}

extension FavoritesCharacterViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let characterDetailVC = CharacterDetailViewController(character: charactersInfo[indexPath.row])
        let navigationController = UINavigationController(rootViewController: characterDetailVC)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension FavoritesCharacterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return charactersInfo.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return charactersInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
        var characters = viewModel?.returnFavorites(with: context)
        characters?.forEach({ character in
            if let name = character.name,
               let thumbnailPath = character.imagePath,
               let thumbnailExtension = character.imageExtension {
                let characterInfo = CharacterInfo(name: name, description: character.description, thumbnailPath: thumbnailPath, thumbnailExtension: thumbnailExtension)
                cell.configure(with: characterInfo)
                charactersInfo.append(characterInfo)
            }
        })
        
        cell.isFavorited = true
        
        return cell
    }
}
