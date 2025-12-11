import SwiftUI
import Charts

// MARK: - View
struct SpeedCart: View {
  
  let data: [DiagramDataPoint]
  @State private var selectedPoint: DiagramDataPoint?
  @State private var plotWidth: CGFloat = 0
  
  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      headerView
      chartView
        .frame(height: 200)
    }
  }
}

// MARK: - Private Properties
private extension SpeedCart {
  var headerView: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text("Speed")
        .font(.headline)
        .foregroundStyle(.secondary)
      
      if let selected = selectedPoint {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text(String(format: "%.1f", selected.speed_kmh))
            .font(.system(size: 32, weight: .semibold))
          Text("km/h")
            .font(.title3)
            .foregroundStyle(.secondary)
        }
        
        Text(formatTime(selected.currentTimestamp))
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } else {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text(String(format: "%.1f", averageSpeed))
            .font(.system(size: 32, weight: .semibold))
          Text("km/h")
            .font(.title3)
            .foregroundStyle(.secondary)
        }
        
        Text("Average")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
  }
  
  // Chart View
  var chartView: some View {
    Chart {
      ForEach(data) { point in
        AreaMark(
          x: .value("Time", point.time_numeric),
          y: .value("Speed", point.speed_kmh)
        )
        .foregroundStyle(
          LinearGradient(
            colors: [
              Color.blue.opacity(0.3),
              Color.blue.opacity(0.1),
              Color.blue.opacity(0.05)
            ],
            startPoint: .top,
            endPoint: .bottom
          )
        )
        .interpolationMethod(.catmullRom)
        
        LineMark(
          x: .value("Time", point.time_numeric),
          y: .value("Speed", point.speed_kmh)
        )
        .foregroundStyle(.blue)
        .lineStyle(StrokeStyle(lineWidth: 2))
        .interpolationMethod(.catmullRom)
      }
      
      if let selectedPoint = selectedPoint {
        RuleMark(x: .value("Selected", selectedPoint.time_numeric))
          .foregroundStyle(.gray.opacity(0.3))
          .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
        
        PointMark(
          x: .value("Selected", selectedPoint.time_numeric),
          y: .value("Speed", selectedPoint.speed_kmh)
        )
        .foregroundStyle(.blue)
        .symbolSize(100)
        
        PointMark(
          x: .value("Selected", selectedPoint.time_numeric),
          y: .value("Speed", selectedPoint.speed_kmh)
        )
        .foregroundStyle(.white)
        .symbolSize(200)
      }
    }
    .chartXAxis {
      AxisMarks(values: .automatic(desiredCount: 5)) { value in
        AxisValueLabel {
          if let intValue = value.as(Int.self) {
            Text("\(intValue) min")
              .font(.caption2)
          }
        }
        AxisGridLine()
      }
    }
    .chartYAxis {
      AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
        AxisValueLabel()
        AxisGridLine()
      }
    }
    .chartYScale(domain: yAxisRange)
    .overlay(
      GeometryReader { geometry in
        Rectangle()
          .fill(.clear)
          .contentShape(Rectangle())
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                updateSelectedPoint(at: value.location, in: geometry.size)
              }
              .onEnded { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                  withAnimation(.easeOut(duration: 0.3)) {
                    selectedPoint = nil
                  }
                }
              }
          )
          .onAppear {
            plotWidth = geometry.size.width
          }
      }
    )
    .padding()
    .background(Color(.secondarySystemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
  
  // Computed Properties
  var minSpeed: Double {
    data.map { $0.speed_kmh }.min() ?? 0
  }
  
  var maxSpeed: Double {
    data.map { $0.speed_kmh }.max() ?? 0
  }
  
  var averageSpeed: Double {
    guard !data.isEmpty else { return 0 }
    let sum = data.map { $0.speed_kmh }.reduce(0, +)
    return sum / Double(data.count)
  }
  
  var yAxisRange: ClosedRange<Double> {
    let min = minSpeed
    let max = maxSpeed
    let padding = (max - min) / 5
    return (min - padding)...(max + padding)
  }
  
  // Helper Methods
  func updateSelectedPoint(at location: CGPoint, in size: CGSize) {
    let chartWidth = size.width - 32
    let xPosition = location.x - 16
    
    guard xPosition >= 0 && xPosition <= chartWidth else {
      return
    }
    
    let dataRange = CGFloat(data.count - 1)
    let relativeX = xPosition / chartWidth
    let dataIndex = Int(round(relativeX * dataRange))
    let clampedIndex = max(0, min(dataIndex, data.count - 1))
    
    withAnimation(.easeInOut(duration: 0.1)) {
      selectedPoint = data[clampedIndex]
    }
  }
  
  func formatTime(_ timestamp: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    
    guard let date = formatter.date(from: timestamp) else {
      return timestamp
    }
    
    let displayFormatter = DateFormatter()
    displayFormatter.dateFormat = "HH:mm"
    return displayFormatter.string(from: date)
  }
}

// MARK: - Preview
#Preview {
  let sampleData = (0..<20).map { index in
    DiagramDataPoint(
      time_numeric: index,
      heartRate: 120,
      speed_kmh: Double.random(in: 8...12),
      distanceMeters: index * 100,
      steps: index * 50,
      elevation: 45.0,
      latitude: 55.75,
      longitude: 37.61,
      temperatureCelsius: 12.0,
      currentLayer: 0,
      currentSubLayer: 0,
      currentTimestamp: "2025-11-25 09:\(30 + index):00"
    )
  }
  
  SpeedCart(data: sampleData)
    .padding()
}
