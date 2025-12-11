import Foundation

// MARK: - Model
struct WorkoutMetadata: Codable {
  let workoutKey: String
  let workoutActivityType: String
  let workoutStartDate: String
  let distance: String
  let duration: String
  let maxLayer: Int
  let maxSubLayer: Int
  let avg_humidity: String
  let avg_temp: String
  let comment: String
  let photoBefore: String?
  let photoAfter: String?
  let heartRateGraph: String?
  let activityGraph: String?
  let map: String?
  
  var distanceInMeters: Double {
    Double(distance) ?? 0
  }
  
  var distanceInKm: Double {
    distanceInMeters / 1000
  }
  
  var durationInSeconds: Double {
    Double(duration) ?? 0
  }
  
  var durationFormatted: String {
    let hours = Int(durationInSeconds) / 3600
    let minutes = (Int(durationInSeconds) % 3600) / 60
    let seconds = Int(durationInSeconds) % 60
    
    if hours > 0 {
      return String(format: "%dh %dm %ds", hours, minutes, seconds)
    } else if minutes > 0 {
      return String(format: "%dm %ds", minutes, seconds)
    } else {
      return String(format: "%ds", seconds)
    }
  }
}

// MARK: - Response Model
struct MetadataResponse: Codable {
  let description: String
  let workouts: [String: WorkoutMetadata]
}
