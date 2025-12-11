import Foundation

// MARK: - Protocol
protocol WorkoutDataServiceProtocol {
  func loadWorkouts() async throws -> [Workout]
  func loadMetadata() async throws -> [String: WorkoutMetadata]
  func loadDiagramData() async throws -> [String: WorkoutDiagramData]
}

// MARK: - Implementation
final class WorkoutDataService: WorkoutDataServiceProtocol {
  
  enum DataError: Error {
    case fileNotFound
    case invalidJSON
    case decodingFailed(Error)
  }
  
  func loadWorkouts() async throws -> [Workout] {
    if let cached = DataCache.shared.getCachedWorkouts() { return cached }
    
    let response: WorkoutListResponse = try await loadJSON(fileName: "list_workouts")
    DataCache.shared.cacheWorkouts(response.data)
    return response.data
  }
  
  func loadMetadata() async throws -> [String: WorkoutMetadata] {
    if let cached = DataCache.shared.getCachedMetadata() { return cached }
    
    let response: MetadataResponse = try await loadJSON(fileName: "metadata")
    DataCache.shared.cacheMetadata(response.workouts)
    return response.workouts
  }
  
  func loadDiagramData() async throws -> [String: WorkoutDiagramData] {
    if let cached = DataCache.shared.getCachedDiagramData() { return cached }
    let response: DiagramDataResponse = try await loadJSON(fileName: "diagram_data")
    DataCache.shared.cacheDiagramData(response.workouts)
    return response.workouts
  }
  
  private func loadJSON<T: Decodable>(fileName: String) async throws -> T {
    var url: URL?
    
    url = Bundle.main.url(
      forResource: fileName,
      withExtension: "json",
      subdirectory:
        "Resources/data"
    )
    
    if url == nil {
      url = Bundle.main.url(
        forResource: fileName,
        withExtension: "json",
        subdirectory:
          "Resources"
      )
    }
    
    if url == nil {
      url = Bundle.main.url(
        forResource: fileName,
        withExtension: "json",
        subdirectory:
          "data"
      )
    }
    
    if url == nil {
      url = Bundle.main.url(forResource: fileName, withExtension: "json")
    }
    
    guard let fileURL = url else {
      throw DataError.fileNotFound
    }
    
    do {
      let data = try Data(contentsOf: fileURL)
      let decoder = JSONDecoder()
      return try decoder.decode(T.self, from: data)
    } catch let decodingError as DecodingError {
      throw DataError.decodingFailed(decodingError)
    } catch {
      throw DataError.invalidJSON
    }
  }
}

