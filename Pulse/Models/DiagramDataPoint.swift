import Foundation

// MARK: - Model
struct DiagramDataPoint: Codable, Identifiable {
  let time_numeric: Int
  let heartRate: Int
  let speed_kmh: Double
  let distanceMeters: Int
  let steps: Int
  let elevation: Double
  let latitude: Double
  let longitude: Double
  let temperatureCelsius: Double
  let currentLayer: Int
  let currentSubLayer: Int
  let currentTimestamp: String
  
  var id: Int { time_numeric }
}

// MARK: - Data Model
struct WorkoutDiagramData: Codable {
  let description: String
  let data: [DiagramDataPoint]
  let states: [String]
}

// MARK: - Response Model
struct DiagramDataResponse: Codable {
  let description: String
  let workouts: [String: WorkoutDiagramData]
}

