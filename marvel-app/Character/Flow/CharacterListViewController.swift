import UIKit
import CoreData

protocol CharacterListViewProtocol: AnyObject {
    func saveFavorite(with name: String, description: String, imagePath: String, imageExtension: String)
}

class CharacterListViewController: UIViewController, CharacterListViewProtocol {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var collectionViewBottomConstraint: NSLayoutConstraint?
    private var hasError: Bool = false
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        layout.itemSize = CGSize(width: collectionView.bounds.width, height: 150)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")
        collectionView.register(EmptyCollectionViewCell.self, forCellWithReuseIdentifier: "EmptyCell")
        collectionView.register(ErrorCollectionViewCell.self, forCellWithReuseIdentifier: "ErrorCell")
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
    private var filteredCharacters: [CharacterInfo] = []
    private var favoritedCharacters: [CharacterInfo] = []
    
    private var isSearching = false
    private var dataSource: [CharacterInfo] {
        if isSearching {
            return filteredCharacters
        } else {
            return characters
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        favoritedCharacters = listFavorites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSearchController()
        title = "Marvel Characters"
        
        self.setupGradientBackground()
        
        displayCharacters()
        setupCollectionView()
        observeKeyboard()
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func listFavorites() -> [CharacterInfo] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return viewModel?.returnFavorites(with: context) ?? []
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
        viewModel?.fetchCharacters(completion: { [weak self] character, error in
            
            if let error = error {
                self?.hasError = true
            }
            
            guard let characters = character else {
                return
            }
            self?.characters = characters
            self?.filteredCharacters = self?.characters ?? []
            self?.collectionView.reloadData()
            
        })
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = true
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search Characters"
        
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
    
    func updateHeartImage(for cell: CharacterCollectionViewCell, at indexPath: IndexPath) {
        let character = dataSource[indexPath.row]
        if favoritedCharacters.contains(where: { $0.name == character.name }) {
            cell.setIsFavorited()
        } else {
            cell.isFavorited = false
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionViewBottomConstraint = collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        collectionViewBottomConstraint?.isActive = true
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        collectionViewBottomConstraint?.constant = -keyboardFrame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        collectionViewBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

extension CharacterListViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {
        defer {
            collectionView.reloadData()
        }
        isSearching = !(searchController.searchBar.text?.isEmpty ?? true)
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return
        }
        print("searching for \(searchText)")
        filteredCharacters = characters.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        print("filteredCharacters.count \(filteredCharacters.count)")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.isEnabled = true
        searchController.searchBar.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        collectionView.reloadData()
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
        return dataSource.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if hasError {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ErrorCell", for: indexPath) as? ErrorCollectionViewCell else {
                return UICollectionViewCell()
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.setListDelegate(delegate: self)
        
            updateHeartImage(for: cell, at: indexPath)
            cell.configure(with: dataSource, indexPath: indexPath.row)
            return cell
        }
        return UICollectionViewCell()
    }
}
