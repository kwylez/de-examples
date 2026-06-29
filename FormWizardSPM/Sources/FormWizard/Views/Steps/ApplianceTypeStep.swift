import SwiftUI

struct ApplianceTypeStep: View {
    @Bindable var data: FormWizardData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader(
                    title: "Appliance Type",
                    subtitle: "Select the appliance that needs repair"
                )

                VStack(spacing: 12) {
                    ForEach(ApplianceType.allCases) { type in
                        ApplianceCard(
                            type: type,
                            isSelected: data.applianceType == type
                        ) {
                            data.applianceType = type
                        }
                    }
                }

                WizardTextArea(
                    label: "Additional Comments",
                    placeholder: "Describe the issue or any relevant details…",
                    text: $data.comment
                )
            }
            .padding(24)
        }
    }
}

private struct ApplianceCard: View {
    let type: ApplianceType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : Color.accentColor)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? Color.accentColor : Color.accentColor.opacity(0.1))
                    .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(type.rawValue)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(type.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.systemFill))
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
