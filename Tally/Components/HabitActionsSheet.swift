import SwiftUI
import TallyCore

/// The "more options" sheet for a habit: Archive (or Unarchive) and Delete.
/// Archive and Unarchive happen at once. Delete asks first, using `deleteMessage`.
struct HabitActionsSheet: View {
    let habit: HabitModel
    let deleteMessage: String
    let onToggleArchive: () -> Void
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showsDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: habit.iconName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(habit.color.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(habit.name).font(.headline)
                            if habit.isArchived {
                                Text("Archived").font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                }

                Section {
                    if habit.isArchived {
                        actionRow(
                            title: "Unarchive", symbol: "tray.and.arrow.up",
                            description: "Brings it back from today. The days it was archived stay off."
                        ) {
                            onToggleArchive()
                            dismiss()
                        }
                    } else {
                        actionRow(
                            title: "Archive", symbol: "archivebox",
                            description: "Hides it from Today. Past days stay in Insights."
                        ) {
                            onToggleArchive()
                            dismiss()
                        }
                    }
                    actionRow(
                        title: "Delete", symbol: "trash", isDestructive: true,
                        description: "Removes the habit and all its logs. This can't be undone."
                    ) {
                        showsDeleteAlert = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background { DawnBackground() }
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Delete \(habit.name)?", isPresented: $showsDeleteAlert) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(deleteMessage)
            }
        }
        .presentationDetents([.medium])
    }

    private func actionRow(
        title: String, symbol: String, isDestructive: Bool = false,
        description: String, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbol)
                    .font(.title3)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                    Text(description)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .foregroundStyle(isDestructive ? Color.red : Color.primary)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview("Active") {
    HabitActionsSheet(habit: SampleHabits.water, deleteMessage: "This permanently removes the habit.",
                      onToggleArchive: {}, onDelete: {})
}

#Preview("Archived") {
    HabitActionsSheet(habit: SampleHabits.meditation.archiving(from: .now), deleteMessage: "This permanently removes the habit.",
                      onToggleArchive: {}, onDelete: {})
}
