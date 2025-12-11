import Foundation
@testable import Pulse

class MockWorkoutDataService: WorkoutDataServiceProtocol {
  
  func loadWorkouts() async throws -> [Workout] {
    return [
      Workout(workoutKey: "7823456789012345", workoutActivityType:
                "Walking/Running", workoutStartDate: "2025-11-25 09:30:00"),
      Workout(workoutKey: "7823456789012346", workoutActivityType: "Yoga",
              workoutStartDate: "2025-11-25 18:00:00"),
      Workout(workoutKey: "7823456789012347", workoutActivityType: "Water",
              workoutStartDate: "2025-11-24 07:15:00"),
      Workout(workoutKey: "7823456789012348", workoutActivityType:
                "Walking/Running", workoutStartDate: "2025-11-24 17:45:00"),
    ]
  }
  
  func loadMetadata() async throws -> [String: WorkoutMetadata] {
    return [:]
  }
  
  func loadDiagramData() async throws -> [String: WorkoutDiagramData] {
    return [:]
  }
}
