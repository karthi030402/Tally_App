import SwiftUI

/// The rounded card each Insights section sits in.
struct AppCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
