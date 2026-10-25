import SwiftUI
import TallyCore

/// A sheet of icons grouped by theme. The first tile clears the choice, so the habit uses the
/// default icon. Tapping a tile selects it and closes the sheet.
struct IconPickerSheet: View {
    /// `nil` means no icon chosen; the default icon is shown.
    @Binding var selection: String?
    /// The habit's color, so icons are previewed the way they'll appear.
    let tint: Color
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 56), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(title: "Default") {
                        tile(symbol: HabitModel.fallbackSymbol,
                             label: "Default icon",
                             isSelected: selection == nil
                        ) {
                            selection = nil
                        }
                    }
                    ForEach(HabitAppearance.iconGroups) { group in
                        section(title: group.title) {
                            ForEach(group.symbols, id: \.self) { symbol in
                                tile(
                                    symbol: symbol,
                                    label: HabitAppearance.displayName(forSymbol: symbol),
                                    isSelected: selection == symbol
                                ) {
                                    selection = symbol
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background { DawnBackground() }
            .navigationTitle("Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
            LazyVGrid(columns: columns, spacing: 12) {
                content()
            }
        }
    }

    private func tile(symbol: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            action()
            dismiss()
        } label: {
            Image(systemName: symbol)
                .font(.title2)
                .foregroundStyle(isSelected ? .white : tint)
                .frame(width: 56, height: 56)
                .background(
                    isSelected ? AnyShapeStyle(tint.gradient) : AnyShapeStyle(AppTheme.cardBackground),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct IconPickerSheetPreview: View {
    @State private var selection: String? = "drop.fill"

    var body: some View {
        IconPickerSheet(selection: $selection, tint: Color(lightHex: 0x4C63E0, darkHex: 0x8396FF))
    }
}

#Preview {
    IconPickerSheetPreview()
}
