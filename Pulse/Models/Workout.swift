import Foundation

// MARK: - Model
struct Workout: Identifiable, Codable {
  let workoutKey: String
  let workoutActivityType: String
  let workoutStartDate: String
  
  var id: String { workoutKey }
  
  var startDate: Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter.date(from: workoutStartDate)
  }
  
  var activityEmoji: String {
    switch workoutActivityType {
      case "Walking/Running": return "🏃"
      case "Yoga": return "🧘"
      case "Water": return "🏊"
      case "Cycling": return "🚴"
      case "Strength": return "💪"
      default: return "🏋️"
    }
  }
}

// MARK: - Response Model
struct WorkoutListResponse: Codable {
  let description: String
  let data: [Workout]
}
