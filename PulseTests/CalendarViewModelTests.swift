import XCTest
@testable import Pulse

final class CalendarViewModelTests: XCTestCase {
  
  var sut: CalendarViewModel!
  var mockService: MockWorkoutDataService!
  
  override func setUp() {
    super.setUp()
    mockService = MockWorkoutDataService()
    sut = CalendarViewModel(workoutService: mockService)
  }
  
  override func tearDown() {
    sut = nil
    mockService = nil
    super.tearDown()
  }
  
  // MARK: - Date Selection Tests
  func testSelectDate_ShouldUpdateSelectedDate() {
    let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    sut.selectDate(testDate)
    XCTAssertTrue(Calendar.current.isDate(sut.selectedDate, inSameDayAs: testDate))
  }
  
  func testSelectDate_ShouldSaveToUserDefaults() {
    let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    sut.selectDate(testDate)
    let savedDate = UserDefaults.standard.object(forKey: "selectedDate") as? Date
    XCTAssertNotNil(savedDate)
    XCTAssertTrue(Calendar.current.isDate(savedDate!, inSameDayAs: testDate))
  }
  
  // MARK: - Month Navigation Tests
  func testMoveToNextMonth_ShouldAdvanceMonth() {
    let startMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    sut.currentMonth = startMonth
    sut.moveToNextMonth()
    let expectedMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 1))!
    XCTAssertTrue(Calendar.current.isDate(sut.currentMonth, equalTo: expectedMonth, toGranularity: .month))
  }
  
  func testMoveToPreviousMonth_ShouldGoBackMonth() {
    let startMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    sut.currentMonth = startMonth
    sut.moveToPreviousMonth()
    let expectedMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 10, day: 1))!
    XCTAssertTrue(Calendar.current.isDate(sut.currentMonth, equalTo: expectedMonth, toGranularity: .month))
  }
  
  // MARK: - Workout Filtering Tests
  @MainActor
  func testWorkoutsForSelectedDay_ShouldFilterCorrectly() async {
    let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    sut.selectDate(testDate)
    await sut.loadWorkouts()
    
    XCTAssertEqual(sut.workoutsForSelectedDay.count, 2, "Should have 2 workouts on Nov 25")
    XCTAssertTrue(sut.workoutsForSelectedDay.contains { $0.workoutActivityType == "Walking/Running" })
    XCTAssertTrue(sut.workoutsForSelectedDay.contains { $0.workoutActivityType == "Yoga" })
  }
  
  @MainActor
  func testWorkoutsForSelectedDay_EmptyDay_ShouldReturnEmpty() async {
    let emptyDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    sut.selectDate(emptyDate)
    await sut.loadWorkouts()
    XCTAssertEqual(sut.workoutsForSelectedDay.count, 0, "Should have no workouts on Nov 1")
  }
  
  // MARK: - Workout Detection Tests
  @MainActor
  func testHasWorkouts_WithWorkouts_ShouldReturnTrue() async {
    let dateWithWorkouts = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    await sut.loadWorkouts()
    XCTAssertTrue(sut.hasWorkouts(on: dateWithWorkouts))
  }
  
  @MainActor
  func testHasWorkouts_WithoutWorkouts_ShouldReturnFalse() async {
    let dateWithoutWorkouts = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    await sut.loadWorkouts()
    XCTAssertFalse(sut.hasWorkouts(on: dateWithoutWorkouts))
  }
  
  // MARK: - Calendar Grid Generation Tests
  func testDaysInMonth_November2025_ShouldHaveCorrectCount() {
    sut.currentMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    let days = sut.daysInMonth
    let actualDays = days.compactMap { $0 }
    XCTAssertEqual(actualDays.count, 30, "November should have 30 days")
  }
  
  func testMonthYearString_ShouldFormatCorrectly() {
    sut.currentMonth = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 1))!
    let formatted = sut.monthYearString
    XCTAssertEqual(formatted, "November 2025")
  }
  
  // MARK: - Today Detection Tests
  func testIsToday_WithTodayDate_ShouldReturnTrue() {
    let today = Date()
    let result = sut.isToday(today)
    XCTAssertTrue(result)
  }
  
  func testIsToday_WithOtherDate_ShouldReturnFalse() {
    let otherDate = Calendar.current.date(from: DateComponents(year: 2020, month: 1, day: 1))!
    let result = sut.isToday(otherDate)
    XCTAssertFalse(result)
  }
  
  // MARK: - Selection Detection Tests
  func testIsSelected_WithSelectedDate_ShouldReturnTrue() {
    let testDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    sut.selectDate(testDate)
    let result = sut.isSelected(testDate)
    XCTAssertTrue(result)
  }
  
  func testIsSelected_WithOtherDate_ShouldReturnFalse() {
    let selectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 25))!
    let otherDate = Calendar.current.date(from: DateComponents(year: 2025, month: 11, day: 26))!
    sut.selectDate(selectedDate)
    let result = sut.isSelected(otherDate)
    XCTAssertFalse(result)
  }
}
