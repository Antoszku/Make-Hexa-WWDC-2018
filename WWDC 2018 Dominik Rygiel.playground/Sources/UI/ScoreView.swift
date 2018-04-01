import UIKit

public class ScoreView: UIView {

    private lazy var scoreLabel: UILabel = UIFactory.make(in: self)
    private lazy var scorePointLabel: UILabel = UIFactory.make(in: self)

    public init() {
        super.init(frame: .zero)
        initalize()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func set(points: Int) {
        scorePointLabel.text = String(points)
    }

    public func set(title: String) {
        scoreLabel.text = title
    }

    private func initalize() {
        initializeView()
        initializeSubviews()
        makeConstraints()
    }

    private func initializeView() {
        layer.cornerRadius = 10
        backgroundColor = .defaultColor
    }

    private func initializeSubviews() {
        initializeScoreLabel()
        initializeScorePointsLabel()
    }

    private func initializeScoreLabel() {
        scoreLabel.clipsToBounds = true
        scoreLabel.textColor = .boardBackground
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 20)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 0
    }

    private func initializeScorePointsLabel() {
        scorePointLabel.textColor = .white
        scorePointLabel.font = UIFont.boldSystemFont(ofSize: 26)
        scorePointLabel.textAlignment = .center
        scorePointLabel.numberOfLines = 1
    }

    private func makeConstraints() {
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        scoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true

        scorePointLabel.translatesAutoresizingMaskIntoConstraints = false
        scorePointLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8).isActive = true
        scorePointLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        scorePointLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        scorePointLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
}
