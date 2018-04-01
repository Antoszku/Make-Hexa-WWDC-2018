import UIKit

public class GameViewController: UIViewController {

    private lazy var board: Board = UIFactory.make(in: view)
    private lazy var scoreView: ScoreView = UIFactory.make(in: view)
    private lazy var bestScoreView: ScoreView = UIFactory.make(in: view)
    private lazy var figureView: FigureView = UIFactory.make(in: view)
    private lazy var gameOverView: GameOverView = UIFactory.make(in: view)

    private let bestScore = BestScore()
    private var paningFigureCenter: CGPoint?
    private var highlightBoardTimer: Timer?
    private var figures = [Figure]()
    private var points: Int = 0 {
        didSet {
            scoreView.set(points: points)
            if bestScore.currentBestScore < points {
                bestScore.currentBestScore = points
                bestScoreView.set(points: points)
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        initializeSubviews()
        makeConstraints()
        board.addPoints = { [weak self] points in
            self?.points += points
        }
        initializeGame()
    }

    private func initializeView() {
        view.backgroundColor = .boardBackground
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    private func initializeSubviews() {
        board.backgroundColor = .clear
        figureView.backgroundColor = .clear
        gameOverView.isHidden = true
        scoreView.set(title: "SCORE")
        scoreView.set(points: 0)
        bestScoreView.set(title: "BEST SCORE")
        bestScoreView.set(points: bestScore.currentBestScore)
    }

    private func initializeGame() {
        createFigure()
        createFigure()
        createFigure()
    }

    private func makeConstraints() {
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        scoreView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        scoreView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scoreView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        bestScoreView.translatesAutoresizingMaskIntoConstraints = false
        bestScoreView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        bestScoreView.topAnchor.constraint(equalTo: view.topAnchor, constant: 24).isActive = true
        bestScoreView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        bestScoreView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        board.translatesAutoresizingMaskIntoConstraints = false
        board.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        board.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 16).isActive = true

        figureView.translatesAutoresizingMaskIntoConstraints = false
        figureView.topAnchor.constraint(equalTo: board.bottomAnchor, constant: 20).isActive = true
        figureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        figureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        figureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        gameOverView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        gameOverView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
    }


    private func createFigure() {
        let figure = FigureFactory.makeFigure()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        figure.addGestureRecognizer(tapGestureRecognizer)
        figure.addGestureRecognizer(panGestureRecognizer)
        figureView.add(figure: figure)
        figures.append(figure)
    }

    private func remove(figure: Figure) {
        figure.removeFromSuperview()
        guard let figureIndex = figures.index(of: figure) else { return }

        figures.remove(at: figureIndex)
    }

    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let figure = gestureRecognizer.view as? Figure else { return }

        figure.performRotation()
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let figure = gestureRecognizer.view as? Figure else { return }

        if gestureRecognizer.state == .began {
            onPanBegan(forFigure: figure)
        } else if gestureRecognizer.state == .changed {
            onPanChanged(withGestureRecognizer: gestureRecognizer)
        } else if gestureRecognizer.state == .ended {
            onPanEnded(forFigure: figure)
        }
    }

    private func onPanBegan(forFigure figure: Figure) {
        view.bringSubview(toFront: figureView)
        view.bringSubview(toFront: figure)
        paningFigureCenter = figure.center
    }

    private func onPanChanged(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        self.setTranslation(withGestureRecognizer: gestureRecognizer)
        self.tryHighlight(figure: gestureRecognizer.view as? Figure)
    }

    private func onPanEnded(forFigure figure: Figure) {
        if !board.tryPlace(figure: figure),
            let paningFigureCenter = paningFigureCenter {
            figure.center = paningFigureCenter
        } else {
            points += figure.triangles.count
            remove(figure: figure)
            createFigure()
            checkIfPlayerLose()
        }
    }

    @objc private func checkIfPlayerLose() {
        if board.animationInProgress {
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(checkIfPlayerLose), userInfo: nil, repeats: false)
            return
        }
        DispatchQueue.main.async { [weak self] in
            if self?.canPlaceFigureOnBoard() == false {
                self?.onPlayerLost()
            }
        }
    }

    private func canPlaceFigureOnBoard() -> Bool {
        let figuresWithoutRepetition = getReducedFigures()
        for figure in figuresWithoutRepetition {
            let figureCopy = figure.copy() as! Figure
            for _ in 0..<6 {
                if board.canPlace(figure: figureCopy) {
                    return true
                }
                figureCopy.performRotation(animated: false)
            }
        }
        return false
    }

    private func getReducedFigures() -> [Figure] {
        let sortedFigures = figures.sorted(by: ( { $0.triangles.count < $1.triangles.count }))
        let figuresWithoutRepetition = sortedFigures.reduce(into: [Figure]()) { result, element in
            if !result.contains(where: { $0.triangles.count == element.triangles.count }) {
                result.append(element)
            }
        }
        return figuresWithoutRepetition
    }

    private func setTranslation(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        guard let selectedFigure = gestureRecognizer.view else { return }

        let translation = gestureRecognizer.translation(in: view)
        selectedFigure.center = CGPoint(x: selectedFigure.center.x + translation.x, y: selectedFigure.center.y + translation.y)
        gestureRecognizer.setTranslation(.zero, in: view)
    }

    private func tryHighlight(figure: Figure?) {
        if highlightBoardTimer?.isValid != true {
            highlightBoardTimer = Timer.scheduledTimer(timeInterval: 1 / 60, target: self, selector: #selector(highlight), userInfo: figure, repeats: false)
        }
    }

    @objc private func highlight(_ timer: Timer) {
        guard let figure = timer.userInfo as? Figure else { return }

        board.unhighlight()
        board.highlight(figure: figure)
    }

    private func onPlayerLost() {
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .autoreverse, animations: { [weak self] in
            self?.gameOverView.isHidden = false
        })
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.restartGame()
        }
    }

    private func restartGame() {
        gameOverView.isHidden = true
        points = 0
        figureView.clean()
        board.clean()
        initializeGame()
    }
}

