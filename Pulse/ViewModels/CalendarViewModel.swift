import Foundation

@Observable
final class CalendarViewModel {
  
  // Properties
  var currentMonth: Date = Date()
  var selectedDate: Date = Date()
  var workouts: [Workout] = []
  var metadata: [String: WorkoutMetadata] = [:]
  var isLoading: Bool = false
  var errorMessage: String?
  
  private let workoutService: WorkoutDataServiceProtocol
  private let calendar = Calendar.current
  
  // Computed Properties
  var daysInMonth: [Date?] {
    generateDaysInMonth()
  }
  
  var monthYearString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: currentMonth)
  }
  
  var workoutsForSelectedDay: [Workout] {
    workouts.filter { workout in
      guard let workoutDate = workout.startDate else { return false }
      return calendar.isDate(workoutDate, inSameDayAs: selectedDate)
    }
  }
  
  // Init
  init(workoutService: WorkoutDataServiceProtocol = WorkoutDataService()) {
    self.workoutService = workoutService
    
    if let savedDate = UserDefaults.standard.object(forKey: "selectedDate") as? Date {
      self.selectedDate = savedDate
      self.currentMonth = savedDate
    }
  }
  
  // Public Methods
  @MainActor
  func loadWorkouts() async {
    isLoading = true
    errorMessage = nil
    
    do {
      async let workoutsTask = workoutService.loadWorkouts()
      async let metadataTask = workoutService.loadMetadata()
      
      self.workouts = try await workoutsTask
      self.metadata = try await metadataTask
      
    } catch {
      errorMessage = "Failed to load workouts: \(error.localizedDescription)"
    }
    
    isLoading = false
  }
  
  func selectDate(_ date: Date) {
    selectedDate = date
    UserDefaults.standard.set(date, forKey: "selectedDate")
  }
  
  func moveToNextMonth() {
    if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
      currentMonth = nextMonth
      saveCurrentMonth()
    }
  }
  
  func moveToPreviousMonth() {
    if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
      currentMonth = previousMonth
      saveCurrentMonth()
    }
  }
  
  func hasWorkouts(on date: Date) -> Bool {
    workouts.contains { workout in
      guard let workoutDate = workout.startDate else { return false }
      return calendar.isDate(workoutDate, inSameDayAs: date)
    }
  }
  
  func isToday(_ date: Date) -> Bool {
    calendar.isDateInToday(date)
  }
  
  func isSelected(_ date: Date) -> Bool {
    calendar.isDate(date, inSameDayAs: selectedDate)
  }
  
  // Private Methods
  private func generateDaysInMonth() -> [Date?] {
    guard
      let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
      let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday
    else {
      return []
    }
    
    var days: [Date?] = []
    
    // Add empty days before the first day of month
    let emptyDaysCount = (firstWeekday - calendar.firstWeekday + 7) % 7
    days.append(contentsOf: Array(repeating: nil, count: emptyDaysCount))
    
    // Add all days in the month
    var currentDate = monthInterval.start
    while currentDate < monthInterval.end {
      days.append(currentDate)
      guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
        break
      }
      currentDate = nextDate
    }
    
    return days
  }
  
  private func saveCurrentMonth() {
    UserDefaults.standard.set(currentMonth, forKey: "currentMonth")
  }
}
