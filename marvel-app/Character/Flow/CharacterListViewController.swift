import UIKit
import SDWebImage

protocol CharacterListViewProtocol {
    func displayCharacters(characteres: [CharacterInfo?])
}

class CharacterListViewController: UIViewController, CharacterListViewProtocol {
    
    private var collectionView: UICollectionView!
    
    var interactor: CharacterListInteractorProtocol?
    
    private var characters: [[CharacterInfo]] = []
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Marvel Characters"
        
        // Configurar collection view
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 150, height: 250)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "CharacterCell")
        collectionView.dataSource = self
        
        view.addSubview(collectionView)
        
        interactor?.fetchCharacters()
    }
    
    func displayCharacters(characteres: [CharacterInfo?]) {
        guard let characteres = characteres as? [CharacterInfo] else { return }
        self.characters = characteres.compactMap { $0 }.chunked(into: 2)
        collectionView.reloadData()
    }
    
    
}

extension CharacterListViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let character = characters[indexPath.section][indexPath.row]
        cell.configure(with: character)
        return cell
    }
}

class CharacterCollectionViewCell: UICollectionViewCell {
    
    private lazy var characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(characterImageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: topAnchor),
            characterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            characterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with character: CharacterInfo) {
        nameLabel.text = character.name
        descriptionLabel.text = character.description
        
        let thumbnailPath = character.thumbnailPath
        let thumbnailExtension = character.thumbnailExtension
        
        var thumbnailURLString = thumbnailPath
        
        if thumbnailPath.hasPrefix("http://") {
            thumbnailURLString = "https://" + String(thumbnailPath.dropFirst("http://".count))
        }
        
        thumbnailURLString += "." + thumbnailExtension
        
        if let thumbnailURL = URL(string: thumbnailURLString) {
            characterImageView.sd_setImage(with: thumbnailURL, completed: nil)
        }
        
    }
}

