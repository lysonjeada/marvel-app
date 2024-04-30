import UIKit
import CoreData
import SDWebImage

protocol CharacterListViewProtocol: AnyObject {
    func saveFavorite(with name: String, description: String, imagePath: String, imageExtension: String)
    
}

class CharacterListViewController: UIViewController, CharacterListViewProtocol {
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 150)
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
    
    var viewModel: CharacterListViewModel?
    
    private var characters: [CharacterInfo] = []
    
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
        
        self.setupGradientBackground()
        
        displayCharacters()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.locations = [0.0, 1.0] // Posição das cores (início e fim)
        gradientLayer.frame = view.bounds
        
        collectionView.layer.insertSublayer(gradientLayer, at: 0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func displayCharacters() {
        viewModel?.fetchCharacters(completion: { characteres in
            guard let characteres = characteres else { return }
            self.characters = characteres
            self.collectionView.reloadData()
        })
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
    
    func saveFavorite(with name: String, description: String, imagePath: String, imageExtension: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Characters", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(name, forKey: "name")
        newUser.setValue(imagePath, forKey: "imagePath")
        newUser.setValue(imageExtension, forKey: "imageExtension")
        newUser.setValue(description, forKey: "text")
        
        viewModel?.saveFavorite(with: context)
    }
}

extension CharacterListViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {
        //        self.viewModel.updateSearchController(searchBarText: searchController.searchBar.text)
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        print("Search bar button called!")
    }
}

extension CharacterListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let characterDetailVC = CharacterDetailViewController(character: characters[indexPath.row])
        let navigationController = UINavigationController(rootViewController: characterDetailVC)
        self.present(navigationController, animated: true, completion: nil)
    }
}

extension CharacterListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.setListDelegate(delegate: self)
        cell.isFavorited = false
        cell.configure(with: characters, indexPath: indexPath.row)
        return cell
    }
}

