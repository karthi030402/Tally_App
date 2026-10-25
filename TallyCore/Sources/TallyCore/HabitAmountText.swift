import Foundation

public extension Double {
    /// 2500 -> "2500", 0.2 -> "0.2". No thousands separator, no trailing ".0".
    var habitAmountText: String {
        formatted(.number.grouping(.never).precision(.fractionLength(0...2)))
    }
}
