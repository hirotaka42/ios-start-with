import Foundation

struct NumberGenerator {
    /// ユーザが指定した口数と桁数範囲から計算式を生成
    static func generateCalculation(
        kuchisu: Int,
        minDigits: Int,
        maxDigits: Int
    ) -> Calculation {
        var numbers: [Int] = []
        var operators: [Operator] = []

        // 最小桁数と最大桁数を確保するための位置をランダムに決定
        let minPositions = (0..<kuchisu).shuffled().prefix(1) // 最小桁数の位置
        let maxPositions = (0..<kuchisu).shuffled().first { !minPositions.contains($0) }.map { [$0] } ?? []

        // 各口の数字を生成
        for i in 0..<kuchisu {
            let digits: Int
            if minPositions.contains(i) {
                digits = minDigits
            } else if maxPositions.contains(i) {
                digits = maxDigits
            } else {
                digits = Int.random(in: minDigits...maxDigits)
            }

            let number = generateRandomNumber(digits: digits)
            numbers.append(number)
        }

        // 演算子を生成（口数-1個必要）
        for _ in 0..<(kuchisu - 1) {
            let op = Bool.random() ? Operator.add : Operator.subtract
            operators.append(op)
        }

        return Calculation(numbers: numbers, operators: operators)
    }

    /// 指定された桁数のランダムな正の自然数を生成
    private static func generateRandomNumber(digits: Int) -> Int {
        let min = Int(pow(10.0, Double(digits - 1)))
        let max = Int(pow(10.0, Double(digits))) - 1
        return Int.random(in: min...max)
    }
}

struct Calculation {
    let numbers: [Int]
    let operators: [Operator]

    /// 計算式の文字列表現（例：12345678 + 23456789 - 1234567）
    var expressionString: String {
        var result = "\(numbers[0])"
        for i in 0..<operators.count {
            let opSymbol = operators[i] == .add ? "+" : "-"
            result += " \(opSymbol) \(numbers[i + 1])"
        }
        return result
    }

    /// 計算結果を求める
    var result: Int {
        var total = numbers[0]
        for i in 0..<operators.count {
            if operators[i] == .add {
                total += numbers[i + 1]
            } else {
                total -= numbers[i + 1]
            }
        }
        return total
    }
}

enum Operator {
    case add
    case subtract
}
