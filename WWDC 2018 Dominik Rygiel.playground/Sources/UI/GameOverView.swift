import UIKit

public class GameOverView: UIView {
    
    lazy var outOfMovesLabel: UILabel = UIFactory.make(in: self)
    
    public init() {
        super.init(frame: .zero)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        initializeView()
        initializeOutOfMovesLabel()
        makeConstraints()
    }
    
    private func initializeView() {
        clipsToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .boardBackground
    }
    
    private func initializeOutOfMovesLabel() {
        outOfMovesLabel.text = "OUT OF MOVES!"
        outOfMovesLabel.textAlignment = .center
        outOfMovesLabel.font = UIFont.boldSystemFont(ofSize: 32)
        outOfMovesLabel.textColor = .white
    }
    
    private func makeConstraints() {
        outOfMovesLabel.translatesAutoresizingMaskIntoConstraints = false
        outOfMovesLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        outOfMovesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        outOfMovesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        outOfMovesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16).isActive = true
    }
}
