import UIKit

class FigureView: UIView {

    let box1 = FigureContainter()
    let box2 = FigureContainter()
    let box3 = FigureContainter()
    var toAnimate = [TriangleView]()

    func addFigure(_ figure: Figure) {
        figure.triangles.forEach { $0.alpha = 0 }
        if box1.isEmpty {
            box1.addSubview(figure)
            figure.translatesAutoresizingMaskIntoConstraints = false
            figure.centerXAnchor.constraint(equalTo: box1.centerXAnchor).isActive = true
            figure.centerYAnchor.constraint(equalTo: box1.centerYAnchor).isActive = true
        } else if box2.isEmpty {
            box2.addSubview(figure)
            figure.translatesAutoresizingMaskIntoConstraints = false
            figure.centerXAnchor.constraint(equalTo: box2.centerXAnchor).isActive = true
            figure.centerYAnchor.constraint(equalTo: box2.centerYAnchor).isActive = true
        } else {
            box3.addSubview(figure)
            figure.translatesAutoresizingMaskIntoConstraints = false
            figure.centerXAnchor.constraint(equalTo: box3.centerXAnchor).isActive = true
            figure.centerYAnchor.constraint(equalTo: box3.centerYAnchor).isActive = true
        }
        toAnimate.append(contentsOf: figure.triangles)
        show()
    }

    @objc func show() {
        if toAnimate == [] {
            return
        }
        let triangle = toAnimate.removeFirst()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
            triangle.alpha = 1.0
            Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.show), userInfo: nil, repeats: false)
        })
    }

    func makeConstraints() {
        addSubview(box1)
        addSubview(box2)
        addSubview(box3)

        box1.translatesAutoresizingMaskIntoConstraints = false
        box1.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        box1.topAnchor.constraint(equalTo: topAnchor).isActive = true
        box1.heightAnchor.constraint(equalTo: box1.widthAnchor).isActive = true

        box2.translatesAutoresizingMaskIntoConstraints = false
        box2.leadingAnchor.constraint(equalTo: box1.trailingAnchor).isActive = true
        box2.topAnchor.constraint(equalTo: topAnchor).isActive = true
        box2.widthAnchor.constraint(equalTo: box1.widthAnchor).isActive = true
        box2.heightAnchor.constraint(equalTo: box2.widthAnchor).isActive = true

        box3.translatesAutoresizingMaskIntoConstraints = false
        box3.leadingAnchor.constraint(equalTo: box2.trailingAnchor).isActive = true
        box3.topAnchor.constraint(equalTo: topAnchor).isActive = true
        box3.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        box3.widthAnchor.constraint(equalTo: box2.widthAnchor).isActive = true
        box3.heightAnchor.constraint(equalTo: box3.widthAnchor).isActive = true
    }

}
