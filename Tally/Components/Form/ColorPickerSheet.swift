import SwiftUI
import TallyCore

/// A sheet showing every habit color as a swatch. Tapping one selects it and closes the sheet.
struct ColorPickerSheet: View {
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(HabitAppearance.colorOptions, id: \.key) { option in
                        colorView(key: option.key, color: option.color)
                    }
                }
                .padding(20)
            }
            .background { DawnBackground() }
            .navigationTitle("Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func colorView(key: String, color: Color) -> some View {
        let isSelected = key == selection
        return Button {
            selection = key
            dismiss()
        } label: {
            Circle()
                .fill(color.gradient)
                .frame(width: 52, height: 52)
                .overlay {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
                .padding(5)
                .overlay {
                    Circle().strokeBorder(isSelected ? color : .clear, lineWidth: 3)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(key.capitalized)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct ColorPickerSheetPreview: View {
    @State private var selection = "indigo"

    var body: some View {
        ColorPickerSheet(selection: $selection)
    }
}

#Preview {
    ColorPickerSheetPreview()
}
