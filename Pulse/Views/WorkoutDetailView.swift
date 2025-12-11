import SwiftUI
import Charts

// MARK: - View
struct WorkoutDetailView: View {
  
  @State var vm: WorkoutDetailViewModel
  @Environment(\.dismiss) var dismiss
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        headerSection
        
        if let metadata = vm.metadata {
          statsSection(metadata: metadata)
        }
        
        if let diagramData = vm.diagramData {
          heartRateChart(data: diagramData.data)
          additionalMetrics(data: diagramData.data)
        }
        
        if let metadata = vm.metadata, !metadata.comment.isEmpty {
          commentSection(comment: metadata.comment)
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
    VStack(spacing: 16) {
      Text("Stats")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
      
      LazyVGrid(columns: [
        GridItem(.flexible()),
        GridItem(.flexible())
      ], spacing: 16) {
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
  }
  
  func heartRateChart(data: [DiagramDataPoint]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Heart Rate")
        .font(.headline)
      
      Chart(data) { point in
        LineMark(
          x: .value("Time", point.time_numeric),
          y: .value("Heart Rate", point.heartRate)
        )
        .foregroundStyle(.red)
        .interpolationMethod(.catmullRom)
        
        AreaMark(
          x: .value("Time", point.time_numeric),
          y: .value("Heart Rate", point.heartRate)
        )
        .foregroundStyle(
          LinearGradient(
            colors: [.red.opacity(0.3), .red.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .interpolationMethod(.catmullRom)
      }
      .chartYAxis {
        AxisMarks(position: .leading)
      }
      .chartXAxis {
        AxisMarks(values: .automatic) { _ in
          AxisValueLabel()
        }
      }
      .frame(height: 250)
      .padding()
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12))
      
      // Heart rate stats
      if let minHR = data.map({ $0.heartRate }).min(),
         let maxHR = data.map({ $0.heartRate }).max(),
         let avgHR = calculateAverage(data.map({ $0.heartRate })) {
        HStack(spacing: 20) {
          HRStat(label: "Min", value: minHR, color: .green)
          HRStat(label: "Avg", value: avgHR, color: .orange)
          HRStat(label: "Max", value: maxHR, color: .red)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }
  
  func additionalMetrics(data: [DiagramDataPoint]) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Additional Metrics")
        .font(.headline)
      
      // Speed chart
      if data.contains(where: { $0.speed_kmh > 0 }) {
        Chart(data.filter { $0.speed_kmh > 0 }) { point in
          LineMark(
            x: .value("Time", point.time_numeric),
            y: .value("Speed", point.speed_kmh)
          )
          .foregroundStyle(.blue)
          .interpolationMethod(.catmullRom)
        }
        .frame(height: 150)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
          Text("Speed (km/h)")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(8),
          alignment: .topLeading
        )
      }
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
        metadata: nil
      )
    )
  }
}
