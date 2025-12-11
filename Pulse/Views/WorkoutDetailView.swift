import SwiftUI
import Charts

// MARK: - View
struct WorkoutDetailView: View {
  
  @State var vm: WorkoutDetailViewModel
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        headerSection
        
        VStack(spacing: 38) {
          if let metadata = vm.metadata {
            statsSection(metadata: metadata)
          }
          
          if let diagramData = vm.diagramData {
            HeartCart(data: diagramData.data)
            SpeedCart(data: diagramData.data)
          }
          
          if let metadata = vm.metadata, !metadata.comment.isEmpty {
            commentSection(comment: metadata.comment)
          }
        }
      }
      .padding()
    }
    .navigationTitle("Workout Details")
    .navigationBarTitleDisplayMode(.inline)
    .task { await vm.loadDiagramData() }
  }
}

// MARK: - Private properties
private extension WorkoutDetailView {
  var headerSection: some View {
    VStack(spacing: 12) {
      Text(vm.workout.activityEmoji)
        .font(.system(size: 60))
      
      Text(vm.workout.workoutActivityType)
        .font(.title)
        .fontWeight(.bold)
      
      if let date = vm.workout.startDate {
        Text(formatDate(date))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical)
  }
  
  func statsSection(metadata: WorkoutMetadata) -> some View {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
      StatCard(
        title: "Distance",
        value: metadata.distanceInKm > 0 ? String(format: "%.2f km", metadata.distanceInKm) : "N/A",
        icon: "figure.walk"
      )
      
      StatCard(
        title: "Duration",
        value: metadata.durationFormatted,
        icon: "clock"
      )
      
      StatCard(
        title: "Avg Temp",
        value: "\(metadata.avg_temp)°C",
        icon: "thermometer"
      )
      
      StatCard(
        title: "Humidity",
        value: "\(metadata.avg_humidity)%",
        icon: "humidity"
      )
    }
  }
  
  func commentSection(comment: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Notes")
        .font(.headline)
      
      Text(comment)
        .font(.body)
        .foregroundStyle(.secondary)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
  
  // Helper methods
  func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMMM d, yyyy 'at' HH:mm"
    return formatter.string(from: date)
  }
  
  func calculateAverage(_ values: [Int]) -> Int? {
    guard !values.isEmpty else { return nil }
    let sum = values.reduce(0, +)
    return sum / values.count
  }
}

// MARK: - Stat Card
struct StatCard: View {
  let title: String
  let value: String
  let icon: String
  
  var body: some View {
    VStack(spacing: 8) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundStyle(.blue)
      
      Text(value)
        .font(.title3)
        .fontWeight(.semibold)
      
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    .frame(height: 80)
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

// MARK: - Heart Rate Stat
struct HRStat: View {
  let label: String
  let value: Int
  let color: Color
  
  var body: some View {
    VStack(spacing: 4) {
      Text(label)
        .font(.caption)
        .foregroundStyle(.secondary)
      
      Text("\(value)")
        .font(.title3)
        .fontWeight(.semibold)
        .foregroundStyle(color)
      
      Text("bpm")
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }
}

// MARK: - Preview
#Preview {
  NavigationStack {
    WorkoutDetailView(
      vm: WorkoutDetailViewModel(
        workout: Workout(
          workoutKey: "7823456789012345",
          workoutActivityType: "Walking/Running",
          workoutStartDate: "2025-11-25 09:30:00"
        ),
        metadata: WorkoutMetadata(
          workoutKey: "7823456789012345",
          workoutActivityType: "Walking/Running",
          workoutStartDate: "2025-11-25 09:30:00",
          distance: "5230.50",
          duration: "2700.00",
          maxLayer: 2,
          maxSubLayer: 4,
          avg_humidity: "65.00",
          avg_temp: "12.50",
          comment: "Утренняя пробежка в парке",
          photoBefore: nil,
          photoAfter: nil,
          heartRateGraph: nil,
          activityGraph: nil,
          map: nil
        )
      )
    )
  }
}
