import SwiftUI
import UIKit

/// The one text field used across forms. A `.text` field is typed into; a `.dropdown` field
/// looks the same but is read-only and runs `action` when tapped (for example to open a sheet).
/// Layout: title (with a * when required), description, the field, then an error in red.
///
/// The screen owns focus, so it can move from one field to the next. It passes its
/// `@FocusState` binding and a value that identifies this field.
struct FormTextField<Field: Hashable>: View {
    let title: String
    var placeholder = ""
    @Binding var text: String
    var type: FormFieldType = .text
    var isRequired = false
    /// Always shown under the title.
    var description: String?
    /// Shown in red under the field. The screen sets it after a failed save.
    var errorMessage: String?
    /// For `.text` fields. Number keyboards also filter what can be typed or pasted.
    var keyboard: UIKeyboardType = .default
    /// For `.text` fields: the label on the Return key.
    var submitLabel: SubmitLabel = .done
    /// For `.text` fields: runs when Return is tapped. The screen decides what comes next.
    var onSubmit: () -> Void = {}
    /// For `.dropdown` fields.
    var action: (() -> Void)?
    /// For `.dropdown` fields: true while the choice is being made, for example while its
    /// sheet is open.
    var isActive = false
    var focus: FocusState<Field?>.Binding
    var fieldID: Field

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                FormFieldTitle(title: title, isRequired: isRequired)
                if let description {
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            field
                .padding(.horizontal, 14)
                .frame(minHeight: 48)
                .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: isHighlighted ? 2 : 1)
                }
                .animation(.easeOut(duration: 0.15), value: isHighlighted)
                // Tapping anywhere in the box starts typing, not just on the text itself.
                .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .onTapGesture {
                    if type == .text { focus.wrappedValue = fieldID }
                }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var field: some View {
        switch type {
        case .text:
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .focused(focus, equals: fieldID)
                .submitLabel(submitLabel)
                .onSubmit(onSubmit)
                .onChange(of: text) { _, newValue in
                    let filtered = Self.filtered(newValue, for: keyboard)
                    if filtered != newValue { text = filtered }
                }
                .accessibilityLabel(accessibilityTitle)
        case .dropdown:
            Button {
                focus.wrappedValue = nil // close the keyboard before the choice opens
                action?()
            } label: {
                HStack {
                    Text(text.isEmpty ? placeholder : text)
                        .foregroundStyle(text.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(accessibilityTitle)
            .accessibilityValue(text.isEmpty ? placeholder : text)
            .accessibilityHint("Opens choices")
        }
    }

    /// A text field is highlighted while it has focus; a dropdown while the screen says it's active.
    private var isHighlighted: Bool {
        type == .text ? focus.wrappedValue == fieldID : isActive
    }

    private var borderColor: Color {
        if isHighlighted { return AppTheme.accent }
        return errorMessage == nil ? Color.secondary.opacity(0.25) : Color.red.opacity(0.7)
    }

    private var accessibilityTitle: String {
        isRequired ? "\(title), required" : title
    }

    /// Keeps only what the keyboard type allows: digits for `.numberPad`; digits and a single
    /// "." for `.decimalPad` (a second dot is ignored). Other keyboards pass through unchanged.
    private static func filtered(_ value: String, for keyboard: UIKeyboardType) -> String {
        switch keyboard {
        case .numberPad:
            return value.filter { ("0"..."9").contains($0) }
        case .decimalPad:
            var hasDot = false
            return value.filter { character in
                if ("0"..."9").contains(character) { return true }
                if character == ".", !hasDot {
                    hasDot = true
                    return true
                }
                return false
            }
        default:
            return value
        }
    }
}

private enum PreviewField {
    case name, goal, badGoal, color, icon
}

/// Hosts the field states so the preview can type into them.
private struct FormTextFieldPreview: View {
    @FocusState private var focus: PreviewField?
    @State private var name = ""
    @State private var goal = "2.5"
    @State private var badGoal = ""

    var body: some View {
        VStack(spacing: 20) {
            FormTextField(
                title: "Name", placeholder: "e.g. Drink water", text: $name, isRequired: true,
                submitLabel: .next, onSubmit: { focus = .goal },
                focus: $focus, fieldID: .name
            )
            FormTextField(
                title: "Goal", placeholder: "2500", text: $goal, isRequired: true,
                description: "The amount to reach each day. Decimals are fine, like 1.5.",
                keyboard: .decimalPad,
                focus: $focus, fieldID: .goal
            )
            FormTextField(
                title: "Goal", placeholder: "2500", text: $badGoal, isRequired: true,
                description: "The amount to reach each day.",
                errorMessage: "Enter a number above 0.", keyboard: .decimalPad,
                focus: $focus, fieldID: .badGoal
            )
            FormTextField(
                title: "Color", placeholder: "Choose", text: .constant("Indigo"), type: .dropdown,
                focus: $focus, fieldID: .color
            )
            FormTextField(
                title: "Icon", placeholder: "Choose", text: .constant("drop.fill"), type: .dropdown,
                isActive: true,
                focus: $focus, fieldID: .icon
            )
        }
        .padding()
        .background { DawnBackground() }
    }
}

#Preview {
    FormTextFieldPreview()
}
