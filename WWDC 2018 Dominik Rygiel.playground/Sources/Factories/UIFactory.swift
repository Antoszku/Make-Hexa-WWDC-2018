
import UIKit

public class UIFactory {
    
    class func make(in view: UIView) -> UILabel {
        let label = UILabel()
        view.addSubview(label)
        return label
    }
    
    class func make(in view: UIView) -> UIButton {
        let button = UIButton()
        view.addSubview(button)
        return button
    }
    
    class func make(in view: UIView) -> Board {
        let board = Board()
        view.addSubview(board)
        return board
    }
    
    class func make(in view: UIView) -> ScoreView {
        let scoreView = ScoreView()
        view.addSubview(scoreView)
        return scoreView
    }
    
    class func make(in view: UIView) -> FigureView {
        let figureView = FigureView()
        view.addSubview(figureView)
        return figureView
    }
    
    class func make(in view: UIView) -> GameOverView {
        let gameOverView = GameOverView()
        view.addSubview(gameOverView)
        return gameOverView
    }
    
    class func make(containersCount: Int, in view: UIView) -> [FigureContainer] {
        var figureContainers = [FigureContainer]()
        for _ in 0..<containersCount {
            let figureContainer = FigureContainer()
            view.addSubview(figureContainer)
            figureContainers.append(figureContainer)
        }
        return figureContainers
    }
}
