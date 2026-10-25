/// How a form field behaves when the user taps it.
enum FormFieldType {
    /// Opens the keyboard so the user can type.
    case text
    /// Read-only. Shows the current choice with a chevron, and runs an action when tapped,
    /// such as opening a sheet.
    case dropdown
}
