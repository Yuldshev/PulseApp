import Foundation

final class DataCache {
  static let shared = DataCache()
  
  private var workoutsCache: [Workout]?
  private var metadataCache: [String: WorkoutMetadata]?
  private var diagramDataCache: [String: WorkoutDiagramData]?
  
  private init() {}
  
  // Workouts
  func cacheWorkouts(_ workouts: [Workout]) {
    workoutsCache = workouts
  }
  
  func getCachedWorkouts() -> [Workout]? {
    return workoutsCache
  }
  
  // Metadata
  func cacheMetadata(_ metadata: [String: WorkoutMetadata]) {
    metadataCache = metadata
  }
  
  func getCachedMetadata() -> [String: WorkoutMetadata]? {
    return metadataCache
  }
  
  // Diagram Data
  func cacheDiagramData(_ data: [String: WorkoutDiagramData]) {
    diagramDataCache = data
  }
  
  func getCachedDiagramData() -> [String: WorkoutDiagramData]? {
    return diagramDataCache
  }
  
  // Clear Cache
  func clearAll() {
    workoutsCache = nil
    metadataCache = nil
    diagramDataCache = nil
  }
}
