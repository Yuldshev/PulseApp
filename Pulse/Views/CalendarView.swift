import SwiftUI

// MARK: - View
struct CalendarView: View {
  
  @State var vm: CalendarViewModel
  var onWorkoutSelected: (Workout, WorkoutMetadata?) -> Void
  
  private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
  private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
  
  var body: some View {
    VStack(spacing: 20) {
      monthNavigationHeader
      weekdayHeaders
      calendarGrid
      workoutsList
      
      Spacer()
    }
    .padding()
    .task { await vm.loadWorkouts() }
  }
}

// MARK: - Private properties
private extension CalendarView {
  var monthNavigationHeader: some View {
    HStack {
      Button { vm.moveToPreviousMonth() } label: {
        Image(systemName: "chevron.left")
          .font(.title2)
          .foregroundStyle(.primary)
      }
      
      Spacer()
      
      Text(vm.monthYearString)
        .font(.title2)
        .fontWeight(.semibold)
      
      Spacer()
      
      Button { vm.moveToNextMonth() } label: {
        Image(systemName: "chevron.right")
          .font(.title2)
          .foregroundStyle(.primary)
      }
    }
    .padding(.horizontal)
  }
  
  var weekdayHeaders: some View {
    LazyVGrid(columns: columns, spacing: 8) {
      ForEach(weekdays, id: \.self) { weekday in
        Text(weekday)
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundStyle(.secondary)
      }
    }
  }
  
  var calendarGrid: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(Array(vm.daysInMonth.enumerated()), id: \.offset) { _, date in
        if let date = date {
          DayCell(
            date: date,
            isToday: vm.isToday(date),
            isSelected: vm.isSelected(date),
            hasWorkouts: vm.hasWorkouts(on: date)
          ) {
            vm.selectDate(date)
          }
        } else {
          Color.clear
            .frame(height: 44)
        }
      }
    }
  }
  
  var workoutsList: some View {
    VStack(alignment: .leading, spacing: 12) {
      if !vm.workoutsForSelectedDay.isEmpty {
        Text("Workouts")
          .font(.headline)
          .padding(.horizontal)
        
        ForEach(vm.workoutsForSelectedDay) { workout in
          WorkoutRow(
            workout: workout,
            metadata: vm.metadata[workout.workoutKey]
          ) {
            onWorkoutSelected(workout, vm.metadata[workout.workoutKey])
          }
        }
      } else {
        Text("No workouts for this day")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding()
      }
    }
  }
}

// MARK: - Day Cell
struct DayCell: View {
  let date: Date
  let isToday: Bool
  let isSelected: Bool
  let hasWorkouts: Bool
  let action: () -> Void
  
  private var dayNumber: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: date)
  }
  
  var body: some View {
    Button(action: action) {
      VStack(spacing: 4) {
        Text(dayNumber)
          .font(.body)
          .fontWeight(isToday ? .bold : .regular)
          .foregroundStyle(foregroundColor)
        
        if hasWorkouts {
          Circle()
            .fill(dotColor)
            .frame(width: 6, height: 6)
        } else {
          Circle()
            .fill(.clear)
            .frame(width: 6, height: 6)
        }
      }
      .frame(height: 44)
      .frame(maxWidth: .infinity)
      .background(backgroundColor)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(borderColor, lineWidth: isToday ? 2 : 0)
      )
    }
    .buttonStyle(.plain)
  }
  
  private var foregroundColor: Color {
    if isSelected {
      return .white
    } else if isToday {
      return .primary
    } else {
      return .primary
    }
  }
  
  private var backgroundColor: Color {
    if isSelected {
      return .blue
    } else {
      return Color(.systemBackground)
    }
  }
  
  private var dotColor: Color {
    if isSelected {
      return .white
    } else {
      return .blue
    }
  }
  
  private var borderColor: Color {
    if isToday {
      return .blue
    } else {
      return .clear
    }
  }
}

// MARK: - Workout Row
struct WorkoutRow: View {
  let workout: Workout
  let metadata: WorkoutMetadata?
  let action: () -> Void
  
  private var timeString: String {
    guard let date = workout.startDate else { return "" }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
  }
  
  var body: some View {
    Button(action: action) {
      HStack(spacing: 12) {
        Text(workout.activityEmoji)
          .font(.title2)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(workout.workoutActivityType)
            .font(.headline)
            .foregroundStyle(.primary)
          
          HStack(spacing: 8) {
            Text(timeString)
              .font(.subheadline)
              .foregroundStyle(.secondary)
            
            if let metadata = metadata, metadata.distanceInKm > 0 {
              Text("•")
                .foregroundStyle(.secondary)
              Text(String(format: "%.2f km", metadata.distanceInKm))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            if let metadata = metadata {
              Text("•")
                .foregroundStyle(.secondary)
              Text(metadata.durationFormatted)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
          }
        }
        
        Spacer()
        
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding()
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
    .padding(.horizontal)
  }
}

// MARK: - Preview
#Preview {
  CalendarView(vm: CalendarViewModel(), onWorkoutSelected: { _, _ in })
}
