import SwiftUI

@Observable
final class AppCoordinator {
  
  // Nav state
  var path = NavigationPath()
  var selectedWorkout: (Workout, WorkoutMetadata?)?
  
  // Deps
  private let workoutService: WorkoutDataServiceProtocol
  
  // Init
  init(service: WorkoutDataServiceProtocol = WorkoutDataService()) {
    self.workoutService = service
  }
  
  // Nav methods
  func showWorkoutDetail(workout: Workout, metadata: WorkoutMetadata?) {
    selectedWorkout = (workout, metadata)
    path.append(WorkoutDetailDestination(
        workout: workout,
        metadata:
          metadata
      ))
  }
  
  func popToRoot() { path.removeLast(path.count) }
  
  func pop() {
    if !path.isEmpty { path.removeLast() }
  }
  
  // View Builder
  @ViewBuilder
  func build() -> some View {
    @Bindable var coordinator = self
    NavigationStack(path: $coordinator.path) {
      buildCalendarView()
        .navigationDestination(for: WorkoutDetailDestination.self) { destination in
          self.buildWorkoutDetailView(
            workout: destination.workout,
            metadata: destination.metadata
          )
        }
    }
  }
  
  @ViewBuilder
  private func buildCalendarView() -> some View {
    CalendarView(
      vm: CalendarViewModel(workoutService: workoutService),
      onWorkoutSelected: { [weak self] workout, metadata in
        self?.showWorkoutDetail(workout: workout, metadata: metadata)
      }
    )
    .navigationTitle("Pulse")
  }
  
  @ViewBuilder
  private func buildWorkoutDetailView(workout: Workout, metadata: WorkoutMetadata?) ->
  some View {
    WorkoutDetailView(
      vm: WorkoutDetailViewModel(
        workout: workout,
        metadata: metadata,
        workoutService: workoutService
      )
    )
  }
}

// MARK: - Navigation Destinations
struct WorkoutDetailDestination: Hashable {
  let workout: Workout
  let metadata: WorkoutMetadata?
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(workout.workoutKey)
  }
  
  static func == (lhs: WorkoutDetailDestination, rhs: WorkoutDetailDestination) -> Bool {
    lhs.workout.workoutKey == rhs.workout.workoutKey
  }
}
