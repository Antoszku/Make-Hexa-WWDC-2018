import UIKit

private let figureColors: [UIColor] = [.firstColor, .secondColor, .thirdColor, .fourthColor, .fifthColor, .sixthColor, .seventhColor]

public class FigureFactory {
    static func makeFigure() -> Figure {
        return Figure(trianglesColor: figureColors.randomElement(), forTriangleCount: Int(arc4random_uniform(5) + 1))
    }
}

