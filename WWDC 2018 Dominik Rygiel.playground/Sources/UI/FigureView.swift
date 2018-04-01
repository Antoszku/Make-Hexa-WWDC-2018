import UIKit

public class FigureView: UIView {
    
    private lazy var figureContainers: [FigureContainer] = UIFactory.make(containersCount: 3, in: self)
    private var triangleToAnimate = [TriangleView]()
    
    public init() {
        super.init(frame: .zero)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(figure: Figure) {
        guard let container = figureContainers.first(where: { $0.isEmpty }) else { return }
        
        container.addSubview(figure)
        figure.translatesAutoresizingMaskIntoConstraints = false
        figure.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        figure.centerYAnchor.constraint(equalTo: container.centerYAnchor).isActive = true
        present(figure: figure)
    }
    
    public func clean() {
        for figure in figureContainers {
            figure.removeFromSuperview()
        }
        figureContainers = UIFactory.make(containersCount: 3, in: self)
        makeConstraints()
    }
    
    private func initialize() {
        makeConstraints()
    }
    
    private func makeConstraints() {
        for (index, container) in figureContainers.enumerated() {
            container.translatesAutoresizingMaskIntoConstraints = false
            container.topAnchor.constraint(equalTo: topAnchor).isActive = true
            container.heightAnchor.constraint(equalTo: container.widthAnchor).isActive = true
            if index > 0 {
                container.leadingAnchor.constraint(equalTo: figureContainers[index - 1].trailingAnchor).isActive = true
                container.widthAnchor.constraint(equalTo: figureContainers[index - 1].widthAnchor).isActive = true
            }
        }
        figureContainers.first?.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        figureContainers.last?.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func present(figure: Figure) {
        figure.triangles.forEach { $0.alpha = 0 }
        triangleToAnimate.append(contentsOf: figure.triangles)
        animate()
    }
    
    
    @objc private func animate() {
        guard triangleToAnimate != [] else { return }
        
        let triangle = triangleToAnimate.removeFirst()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, animations: { [weak self] in
            guard let `self` = self else { return }
            
            triangle.alpha = 1.0
            Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.animate), userInfo: nil, repeats: false)
        })
    }
    
}

