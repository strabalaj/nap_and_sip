import SwiftUI

struct DateRangeSelector: View {
    @Binding var selectedRange: SleepAnalytics.DateRange

    var body: some View {
        Picker("Date Range", selection: $selectedRange) {
            ForEach(SleepAnalytics.DateRange.allCases, id: \.self) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }
}

struct DateRangeSelectorCompact: View {
    @Binding var selectedRange: SleepAnalytics.DateRange

    var body: some View {
        Menu {
            ForEach(SleepAnalytics.DateRange.allCases, id: \.self) { range in
                Button(action: { selectedRange = range }) {
                    HStack {
                        Text(range.displayName)
                        if selectedRange == range {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedRange.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
}

struct DateNavigator: View {
    @Binding var currentDate: Date
    let range: SleepAnalytics.DateRange

    var body: some View {
        HStack {
            Button(action: navigateBackward) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(dateRangeText)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            Button(action: navigateForward) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(canNavigateForward ? .primary : .secondary)
            }
            .disabled(!canNavigateForward)
        }
        .padding(.horizontal)
    }

    private var dateRangeText: String {
        let calendar = Calendar.current

        switch range {
        case .today:
            if calendar.isDateInToday(currentDate) {
                return "Today"
            } else if calendar.isDateInYesterday(currentDate) {
                return "Yesterday"
            }
            return currentDate.formatted(date: .abbreviated, time: .omitted)

        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            return "\(weekStart.formatted(.dateTime.month(.abbreviated).day())) - \(weekEnd.formatted(.dateTime.month(.abbreviated).day()))"

        case .month:
            return currentDate.formatted(.dateTime.month(.wide).year())

        case .custom:
            return "Custom Range"
        }
    }

    private var canNavigateForward: Bool {
        let calendar = Calendar.current
        switch range {
        case .today:
            return !calendar.isDateInToday(currentDate)
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            let nextWeekStart = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
            return nextWeekStart <= Date()
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return nextMonthStart <= Date()
        case .custom:
            return false
        }
    }

    private func navigateBackward() {
        let calendar = Calendar.current
        switch range {
        case .today:
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        case .custom:
            break
        }
    }

    private func navigateForward() {
        guard canNavigateForward else { return }
        let calendar = Calendar.current
        switch range {
        case .today:
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        case .week:
            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: currentDate) ?? currentDate
        case .month:
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        case .custom:
            break
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        DateRangeSelector(selectedRange: .constant(.week))
            .padding()

        DateRangeSelectorCompact(selectedRange: .constant(.week))

        DateNavigator(currentDate: .constant(Date()), range: .week)
    }
}
