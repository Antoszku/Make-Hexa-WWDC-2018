import UIKit

public class GameViewController: UIViewController {
    
    private let board = Board()
    private let figureView = FigureView()
    private let scoreView = UIView()
    private let scoreLabel = UILabel()
    private let scorePointLabel = UILabel()
    
    private var paningFigureCenter: CGPoint?
    private var highlightBoardTimer: Timer?
    private var figures = [Figure]()
    private var points: Int = 0 {
        didSet {
            scorePointLabel.text = String(points)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(board)
        view.addSubview(figureView)
        view.addSubview(scoreView)
        scoreView.addSubview(scoreLabel)
        scoreView.addSubview(scorePointLabel)
        figureView.makeConstraints()
        
        addFigure()
        addFigure()
        addFigure()
        
        scoreLabel.clipsToBounds = true
        scoreView.layer.cornerRadius = 10
        scoreView.backgroundColor = .defaultColor
        
        scoreLabel.text = "SCORE"
        scoreLabel.textColor = .boardBackground
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.textAlignment = .center
        scoreLabel.numberOfLines = 1
        
        scorePointLabel.text = "0"
        scorePointLabel.textColor = .white
        scorePointLabel.font = UIFont.boldSystemFont(ofSize: 30)
        scorePointLabel.textAlignment = .center
        scorePointLabel.numberOfLines = 1
        
        view.backgroundColor = .boardBackground
        figureView.backgroundColor = .clear
        board.backgroundColor = .clear
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        createConstraints()
        
        board.addPoint = { [weak self] points in
            self?.points += points
        }
        
    }
    
    private func addFigure() {
        let figure = FigureFactory.makeFigure()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        figure.addGestureRecognizer(tapGestureRecognizer)
        figure.addGestureRecognizer(panGestureRecognizer)
        figureView.addFigure(figure)
        figures.append(figure)
    }
    
    private func removeFigure(_ figure: Figure) {
        figure.removeFromSuperview()
        if let figureIndex = figures.index(of: figure) {
            figures.remove(at: figureIndex)
        }
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let figure = gestureRecognizer.view as? Figure else { return }
        
        figure.performRotation()
    }
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let figure = gestureRecognizer.view as? Figure else { return }
        view.bringSubview(toFront: figure)
        
        if gestureRecognizer.state == .began {
            onPanBegan(forFigure: figure)
        } else if gestureRecognizer.state == .changed {
            onPanChanged(withGestureRecognizer: gestureRecognizer)
        } else if gestureRecognizer.state == .ended {
            onPanEnded(forFigure: figure)
        }
    }
    
    private func onPanBegan(forFigure figure: Figure) {
        paningFigureCenter = figure.center
    }
    
    private func onPanChanged(withGestureRecognizer gestureRecognizer: UIPanGestureRecognizer) {
        self.setTranslation(withGestureRecognizer: gestureRecognizer)
        self.tryHighlight(figure: gestureRecognizer.view as? Figure)
    }
    
    private func onPanEnded(forFigure figure: Figure) {
        if !board.tryPlace(figure),
            let paningFigureCenter = paningFigureCenter {
            figure.center = paningFigureCenter
        } else {
            points += figure.triangles.count
            removeFigure(figure)
            addFigure()
            checkIfPlayerLose()
        }
    }
    
    
    @objc private func checkIfPlayerLose() {
        if board.animationInProgress {
            Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkIfPlayerLose), userInfo: nil, repeats: false)
            return
        }
        DispatchQueue.main.async { [weak self] in
            
            if self?.check() == false {
                self?.view.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                
            }
        }
        
    }
    
    
    func check() -> Bool {
        let sortedFigures = figures.sorted(by: ( { $0.triangles.count < $1.triangles.count }))
        let figuresWithoutRepetition = sortedFigures.reduce(into: [Figure]()) { result, element in
            if !result.contains(where: { $0.triangles.count == element.triangles.count }) {
                result.append(element)
            }
        }
        for figure in figuresWithoutRepetition {
            let figureCopy = figure.copy() as! Figure
            for _ in 0..<6 {
                
                if board.canPlace(figureCopy) {
                    return true
                    
                }
                figureCopy.performRotation(animated: false)
            }
            
        }
        return false
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
        board.highlight(figure)
    }
    
    private func createConstraints() {
        scoreView.translatesAutoresizingMaskIntoConstraints = false
        scoreView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scoreView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        scoreView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        scoreView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.topAnchor.constraint(equalTo: scoreView.topAnchor, constant: 8).isActive = true
        scoreLabel.leadingAnchor.constraint(equalTo: scoreView.leadingAnchor, constant: 8).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: scoreView.trailingAnchor, constant: -8).isActive = true
        
        scorePointLabel.translatesAutoresizingMaskIntoConstraints = false
        scorePointLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 8).isActive = true
        scorePointLabel.leadingAnchor.constraint(equalTo: scoreView.leadingAnchor, constant: 8).isActive = true
        scorePointLabel.trailingAnchor.constraint(equalTo: scoreView.trailingAnchor, constant: -8).isActive = true
        scorePointLabel.bottomAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: -8).isActive = true
        
        board.translatesAutoresizingMaskIntoConstraints = false
        board.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        board.topAnchor.constraint(equalTo: scoreView.bottomAnchor, constant: 16).isActive = true
        
        figureView.translatesAutoresizingMaskIntoConstraints = false
        figureView.topAnchor.constraint(equalTo: board.bottomAnchor, constant: 20).isActive = true
        figureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        figureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        figureView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
