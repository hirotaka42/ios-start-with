import Foundation

struct CurrencyFormatter {
    /// 数字を金額形式にフォーマット（コンマ区切り）
    /// 例：1234567 → 1,234,567
    /// -1234567 → -1,234,567
    static func formatWithComma(_ number: Int) -> String {
        let isNegative = number < 0
        let absValue = abs(number)
        let numberString = String(absValue)

        var result = ""
        var count = 0

        for char in numberString.reversed() {
            if count > 0 && count % 3 == 0 {
                result = "," + result
            }
            result = String(char) + result
            count += 1
        }

        if isNegative {
            result = "-" + result
        }

        return result
    }

    /// 計算式を読みやすいフォーマットにする
    /// 例：[123, +, 456] → "123,456 + 456,789"
    static func formatCalculationExpression(_ numbers: [Int], _ operators: [Operator]) -> String {
        var result = ""

        for i in 0..<numbers.count {
            let formattedNumber = formatWithComma(numbers[i])
            result += formattedNumber

            if i < operators.count {
                let opSymbol = operators[i] == .add ? " + " : " - "
                result += opSymbol
            }
        }

        return result
    }
}
