import SwiftUI

/// A form field's title, with a red * after it when the field is required.
struct FormFieldTitle: View {
    let title: String
    var isRequired = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 3) {
            Text(title)
                .font(.subheadline.weight(.semibold))
            if isRequired {
                // VoiceOver hears "required" from the control's label instead.
                Text("*")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.red)
                    .accessibilityHidden(true)
            }
        }
    }
}
