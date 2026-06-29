import SwiftUI

struct DateTimeStep: View {
    @Bindable var data: FormWizardData

    private var minimumDate: Date {
        Calendar.current.date(byAdding: .day, value: 1, to: .now) ?? .now
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stepHeader(
                    title: "Schedule Repair",
                    subtitle: "Choose your preferred date and time"
                )

                VStack(spacing: 0) {
                    DatePicker(
                        "Date",
                        selection: $data.scheduledDateTime,
                        in: minimumDate...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .accentColor(.accentColor)
                    .padding(.horizontal, 8)

                    Divider()
                        .padding(.horizontal, 16)

                    DatePicker(
                        "Time",
                        selection: $data.scheduledDateTime,
                        displayedComponents: .hourAndMinute
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))

                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    Text("A technician will confirm the appointment within 24 hours.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill))
                .clipShape(.rect(cornerRadius: 10))
            }
            .padding(24)
        }
    }
}
