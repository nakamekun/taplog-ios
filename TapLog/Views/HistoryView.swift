import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var moodStore: MoodStore

    @State private var displayedMonth = Calendar.current.startOfMonth(for: Date())
    @State private var selectedDate = Date()

    private let calendar = Calendar.current

    init(
        displayedMonth: Date = Calendar.current.startOfMonth(for: Date()),
        selectedDate: Date = Date()
    ) {
        _displayedMonth = State(initialValue: Calendar.current.startOfMonth(for: displayedMonth))
        _selectedDate = State(initialValue: selectedDate)
    }

    private var monthTitle: String {
        displayedMonth.formatted(.dateTime.year().month(.wide))
    }

    private var days: [CalendarDay] {
        makeDays(for: displayedMonth)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header
                weekdayHeader
                calendarGrid
                selectedDayCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                    selectedDate = displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground), in: Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Text(monthTitle)
                .font(.title3.bold())

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                    selectedDate = displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .frame(width: 36, height: 36)
                    .background(Color(.secondarySystemBackground), in: Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var weekdayHeader: some View {
        let symbols = calendar.shortStandaloneWeekdaySymbols

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
            ForEach(symbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 10) {
            ForEach(days) { day in
                if let date = day.date {
                    DayCellView(
                        dayNumber: calendar.component(.day, from: date),
                        mood: moodStore.entry(for: date)?.mood,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        action: {
                            withAnimation(.easeInOut(duration: 0.16)) {
                                selectedDate = date
                            }
                        }
                    )
                } else {
                    Color.clear
                        .frame(height: 56)
                }
            }
        }
    }

    private var selectedDayCard: some View {
        let entry = moodStore.entry(for: selectedDate)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Selected day")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.headline)

            if let entry {
                HStack(spacing: 10) {
                    Text(entry.mood.emoji)
                        .font(.title2)
                    Text(entry.mood.title)
                        .font(.body.weight(.medium))
                    Spacer()
                }
            } else {
                Text("No log for this day.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func makeDays(for month: Date) -> [CalendarDay] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7

        var result = Array(repeating: CalendarDay(date: nil), count: leadingEmptyDays)

        for day in monthRange {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)
            result.append(CalendarDay(date: date))
        }

        while result.count % 7 != 0 {
            result.append(CalendarDay(date: nil))
        }

        return result
    }
}

private struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}

private struct DayCellView: View {
    let dayNumber: Int
    let mood: Mood?
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.subheadline.weight(isToday ? .bold : .medium))
                    .foregroundStyle(.primary)

                if let mood {
                    Text(mood.emoji)
                        .font(.caption)
                } else {
                    Circle()
                        .fill(isSelected ? selectionColor.opacity(0.30) : Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(borderColor, lineWidth: isSelected || isToday ? 1.5 : 0)
            )
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(backgroundColor)
    }

    private var backgroundColor: Color {
        if let mood {
            return mood.color.opacity(isSelected ? 0.18 : 0.14)
        }

        if isSelected {
            return selectionColor.opacity(0.12)
        }

        return Color(.secondarySystemBackground)
    }

    private var selectionColor: Color {
        mood?.color ?? Color.primary.opacity(0.35)
    }

    private var borderColor: Color {
        if isSelected {
            return selectionColor.opacity(0.72)
        }

        if isToday {
            return selectionColor.opacity(0.30)
        }

        return .clear
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? date
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HistoryView()
                .environmentObject(MoodStore.preview)
        }
    }
}
