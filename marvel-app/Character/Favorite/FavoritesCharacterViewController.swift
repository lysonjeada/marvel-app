import UIKit
import CoreData
import SDWebImage

protocol FavoritesCharacterViewProtocol {
    func deleteFavorite(with name: String)
}

class FavoritesCharacterViewController: UIViewController, FavoritesCharacterViewProtocol {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 150)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        title = "Favorites Characters"
        
        setupGradientBackground()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        displayCharacters()
    }
    
    func displayCharacters() {
        DispatchQueue.main.async { [weak self] in
            let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
            if let characters = self?.viewModel?.returnFavorites(with: context) {
                self?.charactersInfo = characters.map { character in
                    return CharacterInfo(name: character.name, description: character.description, thumbnailPath: character.thumbnailPath, thumbnailExtension: character.thumbnailExtension)
                }
                self?.collectionView.reloadData()
            }
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
    
    func deleteFavorite(with name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.viewModel?.deleteFavorite(withName: name, from: context)
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
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
        
        let context = (UIApplication.shared.delegate as!AppDelegate).persistentContainer.viewContext
        let characters = viewModel?.returnFavorites(with: context)
        
        characters?.forEach({ character in
            let characterInfo = CharacterInfo(name: character.name, description: character.description, thumbnailPath: character.thumbnailPath, thumbnailExtension: character.thumbnailExtension)
            charactersInfo.append(characterInfo)
        })
        
        if charactersInfo.count == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as? EmptyCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: charactersInfo, indexPath: indexPath.row)
            
            cell.setFavoriteDelegate(delegate: self)
            
            cell.setIsFavorited()
            
            return cell
        }
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.locations = [0.0, 1.0] // Posição das cores (início e fim)
        gradientLayer.frame = view.bounds
        
        collectionView.layer.insertSublayer(gradientLayer, at: 0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
