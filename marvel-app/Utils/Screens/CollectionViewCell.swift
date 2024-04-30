import UIKit

class CharacterCollectionViewCell: UICollectionViewCell {
    
    var favoriteButtonHandler: (() -> Void)?
    var characterInfo: CharacterInfo?
    var delegate: CharacterListViewProtocol?
    var isFavorited: Bool = false
    
    private lazy var characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.isUserInteractionEnabled = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = isFavorited
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        contentView.addGestureRecognizer(tapGesture)
        
        isUserInteractionEnabled = true
        
        setupGradientBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setCell(delegate: CharacterListViewProtocol) {
        self.delegate = delegate
    }
    
    @objc private func favoriteButtonTapped(sender: UIButton) {
        isSelected.toggle()
        
        if let name = characterInfo?.name,
           let description = characterInfo?.description,
           let thumbnailPath = characterInfo?.thumbnailPath,
           let thumbnailExtension = characterInfo?.thumbnailExtension {
            // aqui passa
            delegate?.saveFavorite(with: name, description: description, imagePath: thumbnailPath, imageExtension: thumbnailExtension)
        }
        
        updateImage()
    }
    
    private func updateImage() {
        let imageName = isSelected ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupFavoriteConstraints() {
        layer.cornerRadius = 8
        
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(descriptionLabel)
        infoStackView.addArrangedSubview(favoriteButton)
        
        infoStackView.setCustomSpacing(12, after: descriptionLabel)
        
        addSubview(characterImageView)
        addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            characterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            characterImageView.widthAnchor.constraint(equalToConstant: 150),
            characterImageView.heightAnchor.constraint(equalTo: heightAnchor),
            
            infoStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 8),
            infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            
            descriptionLabel.widthAnchor.constraint(equalTo: infoStackView.widthAnchor)
        ])
    }
    
    func configure(with character: [CharacterInfo], indexPath: Int) {
        guard indexPath < character.count else {
            return
        }
        
        self.characterInfo = character[indexPath]
        characterImageView.isHidden = false
        infoStackView.isHidden = false
        
        nameLabel.text = character[indexPath].name
        descriptionLabel.text = character[indexPath].description
        
        let thumbnailURLString = ImageUtil.returnCorrectUrlToShowImage(thumbnailPath: character[indexPath].thumbnailPath, thumbnailExtension: character[indexPath].thumbnailExtension)
        
        if let thumbnailURL = URL(string: thumbnailURLString) {
            characterImageView.sd_setImage(with: thumbnailURL, completed: nil)
        }
        
        setupFavoriteConstraints()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let collectionView = superview as? UICollectionView,
              let indexPath = collectionView.indexPath(for: self) else {
            return
        }
        
        // Notificar o delegate que a célula foi tocada
        (collectionView.delegate)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
    
    private func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        gradientLayer.locations = [0.0, 1.0] // Posição das cores (início e fim)
        gradientLayer.frame = bounds
        
        layer.insertSublayer(gradientLayer, at: 0)
    }

}
