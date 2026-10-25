import SwiftUI
import TallyCore

/// A titled list of options where exactly one is selected, drawn with radio buttons.
struct RadioGroup<Option: Hashable>: View {
    let title: String
    var isRequired = false
    let options: [Option]
    @Binding var selection: Option
    let optionTitle: (Option) -> String
    var optionDescription: (Option) -> String? = { _ in nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FormFieldTitle(title: title, isRequired: isRequired)

            VStack(spacing: 0) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selection = option
                        }
                    } label: {
                        row(for: option)
                    }
                    .buttonStyle(.plain)

                    if option != options.last {
                        Divider().padding(.leading, 50)
                    }
                }
            }
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isRequired ? "\(title), required" : title)
    }

    private func row(for option: Option) -> some View {
        let isSelected = option == selection
        return HStack(alignment: .top, spacing: 12) {
            radioCircle(isSelected: isSelected)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: 2) {
                Text(optionTitle(option))
                if let description = optionDescription(option) {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func radioCircle(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? AppTheme.accent : Color.secondary.opacity(0.5), lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .fill(AppTheme.accent)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

private struct RadioGroupPreview: View {
    @State private var kind = HabitKind.checkOff

    var body: some View {
        RadioGroup(
            title: "Type", isRequired: true,
            options: HabitKind.allCases, selection: $kind,
            optionTitle: \.title, optionDescription: { $0.summary }
        )
        .padding()
        .background { DawnBackground() }
    }
}

#Preview {
    RadioGroupPreview()
}
