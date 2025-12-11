import Foundation

@Observable
final class WorkoutDetailViewModel {
  
  // Properties
  var workout: Workout
  var metadata: WorkoutMetadata?
  var diagramData: WorkoutDiagramData?
  var isLoading: Bool = false
  var errorMessage: String?
  
  private let workoutService: WorkoutDataServiceProtocol
  
  // Initialization
  init(workout: Workout, metadata: WorkoutMetadata?, workoutService:
       WorkoutDataServiceProtocol = WorkoutDataService()) {
    self.workout = workout
    self.metadata = metadata
    self.workoutService = workoutService
  }
  
  // Public Methods
  @MainActor
  func loadDiagramData() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let allDiagramData = try await workoutService.loadDiagramData()
      self.diagramData = allDiagramData[workout.workoutKey]
    } catch {
      errorMessage = "Failed to load diagram data: \(error.localizedDescription)"
    }
    
    isLoading = false
  }
}
