# Test Assignment: Workout Calendar

## Description

Create a web application to display a workout calendar with the ability to view details of each workout.

---

## API Endpoints

### 1. Workout List

```
GET /list_workouts?email={email}&lastDate={lastDate}
```

**Parameters:**
- `email` — user email
- `lastDate` — start date for selection (format: YYYY-MM-DD)

**Response:**
```json
[
    {
        "workoutKey": "7823456789012345",
        "workoutActivityType": "Walking/Running",
        "workoutStartDate": "2025-11-25 09:30:00"
    }
]
```

---

### 2. Workout Metadata

```
GET /metadata?workoutId={workoutKey}&email={email}
```

**Parameters:**
- `workoutId` — workout ID (workoutKey)
- `email` — user email

**Response:**
```json
{
    "workoutKey": "7823456789012345",
    "workoutActivityType": "Walking/Running",
    "workoutStartDate": "2025-11-25 09:30:00",
    "distance": "5230.50",
    "duration": "2700.00",
    "maxLayer": 2,
    "maxSubLayer": 4,
    "avg_humidity": "65.00",
    "avg_temp": "12.50",
    "comment": "Morning run in the park",
    "photoBefore": null,
    "photoAfter": null,
    "heartRateGraph": "/static/{email}/{workoutKey}/heartrate_plot.png",
    "activityGraph": "/static/{email}/{workoutKey}/activity_plot.png",
    "map": "/static/{email}/{workoutKey}/map_plot.html"
}
```

---

### 3. Chart Data

```
GET /get_diagram_data?workoutId={workoutKey}&email={email}
```

**Parameters:**
- `workoutId` — workout ID (workoutKey)
- `email` — user email

**Response:**
```json
{
    "data": [
        {
            "time_numeric": 0,
            "heartRate": 72,
            "speed_kmh": 0.0,
            "distanceMeters": 0,
            "steps": 0,
            "elevation": 45.2,
            "latitude": 55.7558,
            "longitude": 37.6173,
            "temperatureCelsius": 12.5,
            "currentLayer": 0,
            "currentSubLayer": 0,
            "currentTimestamp": "2025-11-25 09:30:00"
        }
    ],
    "states": []
}
```

---

## Data Structure

### Workout Types (workoutActivityType)

| Type | Description |
|------|-------------|
| `Walking/Running` | Running/Walking |
| `Yoga` | Yoga |
| `Water` | Water activities (ice swimming, swimming) |
| `Cycling` | Cycling |
| `Strength` | Strength training |

### Chart Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `time_numeric` | number | Time from start (minutes) |
| `heartRate` | number | Heart rate (bpm) |
| `speed_kmh` | number | Speed (km/h) |
| `distanceMeters` | number | Distance (meters) |
| `steps` | number | Steps |
| `elevation` | number | Elevation (meters) |
| `latitude` | number | GPS latitude |
| `longitude` | number | GPS longitude |
| `temperatureCelsius` | number | Temperature (°C) |
| `currentLayer` | number | Current layer |
| `currentSubLayer` | number | Current sublayer |
| `currentTimestamp` | string | Timestamp |

---

## Assignment Requirements

### Mandatory

1. **Calendar**
   - Display month with markers for workout days
   - Navigation between months
   - Visual distinction of workout types (color/icon)

2. **Daily Workout List**
   - Show workout list when clicking on a day
   - Display: type, start time, duration

3. **Workout Details**
   - Show details when clicking on a workout:
     - Workout type
     - Date and time
     - Distance
     - Duration
     - Comment (if available)

### Bonus

4. **Charts**
   - Heart rate chart (heartRate by time_numeric)
   - Speed chart (speed_kmh by time_numeric)

5. **Map**
   - Display route by GPS coordinates

---

## Test Data

The `test_data/` folder contains files:

- `list_workouts.json` — workout list
- `metadata.json` — metadata for all workouts
- `diagram_data.json` — chart data for all workouts

**Test email:** `test@gmail.com`

**Workout dates:** November 21-25, 2025

| Date | Workouts |
|------|----------|
| November 25 | Running (morning), Yoga (evening) |
| November 24 | Water (morning), Running (evening) |
| November 23 | Cycling |
| November 22 | Running (morning), Yoga (evening) |
| November 21 | Water (morning), Strength (afternoon) |

---

## Technologies (your choice)

- React / Vue / Angular
- TypeScript (preferred)
- Any charting library (Chart.js, Recharts, D3, etc.)
- Any map library (Leaflet, Mapbox, Google Maps)

---

## Evaluation Criteria

1. Functionality
2. Code quality
3. UI/UX
4. Responsiveness
5. Bonus tasks
