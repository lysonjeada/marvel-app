import UIKit

class EmptyCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupEmptyViewConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var emptyView: UIView = {
        let emptyView = UIView()
        emptyView.backgroundColor = .white
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        return emptyView
    }()
    
    private lazy var iconImageView: UIImageView = {
        let iconImageView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        return iconImageView
    }()
    
    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Nenhum personagem encontrado"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 4
        return label
    }()
    
    private func setupEmptyViewConstraints() {
        emptyView.addSubview(emptyLabel)
        emptyView.addSubview(iconImageView)
        
        addSubview(emptyView)
        
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: emptyView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
        ])
    }
}
