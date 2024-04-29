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
        return imageView
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        stackView.alignment = .leading
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = isFavorited
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        contentView.addGestureRecognizer(tapGesture)
        
        setupConstraints()
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
            delegate?.saveFavorite(with: name, description: description, imagePath: thumbnailPath, imageExtension: thumbnailExtension)
        }
        
        updateImage()
    }
    
    private func updateImage() {
        let imageName = isSelected ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupConstraints() {
        characterImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(descriptionLabel)
        infoStackView.addArrangedSubview(favoriteButton)
        
        infoStackView.setCustomSpacing(12, after: descriptionLabel)
        
        addSubview(characterImageView)
        addSubview(infoStackView)
        
        NSLayoutConstraint.activate([
            characterImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            characterImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            characterImageView.heightAnchor.constraint(equalToConstant: 150),
            
            infoStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            infoStackView.leadingAnchor.constraint(equalTo: characterImageView.trailingAnchor, constant: 8),
        ])
    }
    
    func configure(with character: CharacterInfo) {
        nameLabel.text = character.name
        descriptionLabel.text = character.description
        
        let thumbnailURLString = ImageUtil.returnCorrectUrlToShowImage(thumbnailPath: character.thumbnailPath, thumbnailExtension: character.thumbnailExtension)
        
        if let thumbnailURL = URL(string: thumbnailURLString) {
            characterImageView.sd_setImage(with: thumbnailURL, completed: nil)
        }
        
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let collectionView = superview as? UICollectionView,
              let indexPath = collectionView.indexPath(for: self) else {
            return
        }
        
        // Notificar o delegate que a célula foi tocada
        (collectionView.delegate)?.collectionView?(collectionView, didSelectItemAt: indexPath)
    }
}



