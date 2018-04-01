import UIKit

public class BestScore {

    public var currentBestScore: Int {
        get {
            return self.getPoints() ?? 0
        }
        set {
            save(score: newValue)
        }
    }

    private func save(score: Int) {
        do {
            guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }

            let fileURL = documentDirectory.appendingPathComponent("BestScore.text")
            let text = String(score)
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
        } catch { }
    }

    private func getPoints() -> Int? {
        var points: Int?
        do {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            if let fileURL = documentDirectory?.appendingPathComponent("BestScore.text") {
                let savedPoints = try String(contentsOf: fileURL)
                points = Int(savedPoints)
            }
        } catch { }
        return points
    }
}
