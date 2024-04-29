import UIKit

class CharacterDetailViewController: UIViewController {
    
    private let character: CharacterInfo
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
//        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Construtor para receber os dados do personagem
    init(character: CharacterInfo) {
        self.character = character
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = character.name
        
        // Configurar a imagem do personagem
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
        
        view.addSubview(favoriteButton)
        
        view.addSubview(characterImageView)
        // Configurar o nome do personagem
        nameLabel.text = character.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.textAlignment = .center
        view.addSubview(nameLabel)
        
        // Configurar a descrição do personagem
        descriptionLabel.text = character.description
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        view.addSubview(descriptionLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            characterImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            characterImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            characterImageView.heightAnchor.constraint(equalToConstant: 400),
            
            nameLabel.topAnchor.constraint(equalTo: characterImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

