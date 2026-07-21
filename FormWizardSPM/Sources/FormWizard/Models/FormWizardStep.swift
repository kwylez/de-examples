import SwiftUI

/// Conform to this protocol to supply the UI and validation for a single step
/// in a `FormWizardView`. `FormWizardView` owns navigation, progress, and the
/// Continue/Submit button — you own everything in between.
///
/// ```swift
/// struct UserInfoStep: FormWizardStep {
///     var id: String { "userInfo" }
///
///     func content(data: FormWizardData) -> some View {
///         UserInfoStepView(data: data)
///     }
///
///     func isValid(data: FormWizardData) -> Bool {
///         !data.name.isEmpty
///     }
/// }
///
/// private struct UserInfoStepView: View {
///     @Bindable var data: FormWizardData
///
///     var body: some View {
///         TextField("Name", text: $data.name)
///     }
/// }
/// ```
public protocol FormWizardStep: Identifiable {
    associatedtype Content: View

    var id: String { get }

    @ViewBuilder @MainActor
    func content(data: FormWizardData) -> Content

    @MainActor
    func isValid(data: FormWizardData) -> Bool
}

public extension FormWizardStep {
    func isValid(data: FormWizardData) -> Bool { true }
}
