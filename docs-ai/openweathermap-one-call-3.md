# OpenWeather One Call API 3.0

## Overview

OpenWeather One Call API 3.0 is a comprehensive weather data service providing current conditions, forecasts, historical data, and AI-generated weather summaries. It combines multiple weather data types (current, minutely, hourly, daily, and alerts) in a single API call, making it ideal for weather applications requiring detailed, real-time meteorological information.

## Installation

The API is accessed via HTTPS REST endpoints. No library installation required—make HTTP requests directly.

**Base URL**: `https://api.openweathermap.org`

**Authentication**: Requires an API key obtained from your OpenWeather account

## Key Concepts

- **API Key (appid)**: Required parameter for all requests. Obtain from https://openweathermap.org/api
- **Subscription Plan**: One Call API 3.0 requires the "One Call by Call" plan (1,000 free calls/day included)
- **Coordinates**: Latitude (-90 to 90) and Longitude (-180 to 180) in decimal format
- **Unix Timestamps**: Used for historical queries and alert times
- **Exclusions**: Optimize response size by excluding unwanted data sections (current, minutely, hourly, daily, alerts)

## API Reference

### 1. Current & Forecast Weather

**Endpoint**: `GET https://api.openweathermap.org/data/3.0/onecall`

**Required Parameters**:
- `lat` (float): Latitude (-90 to 90)
- `lon` (float): Longitude (-180 to 180)
- `appid` (string): Your API key

**Optional Parameters**:
- `exclude` (string): Comma-separated list of data sections to exclude
  - Values: `current`, `minutely`, `hourly`, `daily`, `alerts`
  - Example: `exclude=minutely,hourly`
- `units` (string): Unit system for temperature and wind speed
  - Values: `standard` (Kelvin), `metric` (Celsius), `imperial` (Fahrenheit)
  - Default: `standard`
- `lang` (string): Language code for weather descriptions (51 languages supported)
  - Examples: `en`, `fr`, `zh_cn`, `ar`, `hi`, `ru`
  - Default: `en`

**Response Data**:
- Current weather conditions
- Minute-level precipitation forecast (1 hour ahead)
- Hourly forecast (48 hours)
- Daily forecast (8 days)
- Government weather alerts

---

### 2. Historical Weather Data (Time Machine)

**Endpoint**: `GET https://api.openweathermap.org/data/3.0/onecall/timemachine`

**Required Parameters**:
- `lat`, `lon` (float): Location coordinates
- `dt` (integer): Unix timestamp
  - Available range: January 1, 1979 - 4 days into the future
- `appid` (string): Your API key

**Optional Parameters**:
- `units`, `lang` (string): Same as current weather endpoint

**Data Coverage**: 47+ years of historical data plus 4-day forecast

---

### 3. Daily Aggregation

**Endpoint**: `GET https://api.openweathermap.org/data/3.0/onecall/day_summary`

**Required Parameters**:
- `lat`, `lon` (float): Location coordinates
- `date` (string): Date in YYYY-MM-DD format
- `appid` (string): Your API key

**Optional Parameters**:
- `tz` (string): Timezone offset (format: ±XX:XX)
  - Example: `+05:30` for India Standard Time
- `units`, `lang` (string): Same as current weather endpoint

**Data Range**: January 2, 1979 - 1.5 years into the future

---

### 4. Weather Overview (AI-Generated)

**Endpoint**: `GET https://api.openweathermap.org/data/3.0/onecall/overview`

**Required Parameters**:
- `lat`, `lon` (float): Location coordinates
- `appid` (string): Your API key

**Optional Parameters**:
- `date` (string): Date in YYYY-MM-DD format (today or tomorrow only)
- `units` (string): Temperature units

**Output**: Human-readable weather summary for today and tomorrow's forecast using AI

---

### 5. AI Weather Assistant

**Endpoint (New Session)**: `POST https://api.openweathermap.org/assistant/session`
**Endpoint (Resume Session)**: `POST https://api.openweathermap.org/assistant/session/{session_id}`

**Headers**:
```
Content-Type: application/json
X-Api-Key: your_api_key
```

**Request Body**:
```json
{
  "prompt": "Weather question or activity-based query"
}
```

**Response**:
```json
{
  "session_id": "string",
  "message": "AI-generated response",
  "location": "extracted location",
  "timestamp": "ISO 8601"
}
```

**Features**:
- Supports 50+ languages
- Maintains conversation context via session_id
- Free to use (underlying API calls count toward quota)
- Global coverage with support for cities, provinces, countries

---

## Response Structure

### Current Weather Object Fields

```
temp                 - Temperature
feels_like          - "Feels like" temperature
pressure            - Atmospheric pressure (hPa)
humidity            - Relative humidity (%)
dew_point           - Dew point temperature
clouds              - Cloud coverage (%)
visibility          - Visibility (meters)
wind_speed          - Wind speed (m/s or specified units)
wind_gust           - Wind gust speed
wind_deg            - Wind direction (degrees 0-360)
uvi                 - UV Index
weather             - Array of weather conditions
  - id              - Weather condition ID
  - main            - Weather category (e.g., "Clear", "Cloudy")
  - description     - Human-readable description
  - icon            - Icon code for UI display
rain.1h             - Precipitation in past hour (mm)
snow.1h             - Snow in past hour (mm)
```

### Hourly/Daily Objects

Include all current weather fields plus:
```
pop                 - Precipitation probability (0-1)
```

### Alerts Object

```
sender_name         - Alert issuing authority
event               - Alert type (e.g., "Tornado", "Flood")
start               - Alert start time (Unix timestamp)
end                 - Alert end time (Unix timestamp)
description         - Full alert details
tags                - Severity classification
```

---

## Units Configuration

| Parameter | Standard | Metric | Imperial |
|-----------|----------|--------|----------|
| Temperature | Kelvin (K) | Celsius (°C) | Fahrenheit (°F) |
| Wind Speed | m/s | m/s | mph |
| Precipitation | mm/h | mm/h | mm/h |

---

## Authentication

**Method**: Query parameter-based API key

**Implementation**:
```
https://api.openweathermap.org/data/3.0/onecall?lat=33.441792&lon=-94.037059&appid=YOUR_API_KEY
```

**API Key Best Practices**:
1. Never expose your API key in frontend code
2. Use server-side proxy for API calls
3. Rotate keys periodically
4. Monitor quota usage in OpenWeather dashboard

---

## Error Handling

### Error Response Format

```json
{
  "cod": 400,
  "message": "Error description",
  "parameters": ["param_name"]
}
```

### HTTP Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Process response data |
| 400 | Bad Request | Verify all required parameters and their formats |
| 401 | Unauthorized | Check API key validity and verify you have access to One Call API 3.0 |
| 404 | Not Found | Weather data unavailable for specified coordinates/date |
| 429 | Rate Limited | Upgrade your plan or wait before retrying |
| 5xx | Server Error | Retry request; contact support if issue persists |

### Common Error Scenarios

**Missing Required Parameters**:
```json
{
  "cod": "400",
  "message": "lat and lon parameters are required"
}
```

**Invalid API Key**:
```json
{
  "cod": "401",
  "message": "Invalid API key. Please see http://openweathermap.org/faq#error401 for more info."
}
```

**Rate Limit Exceeded**:
```json
{
  "cod": "429",
  "message": "You have exceeded the rate limit"
}
```

---

## Configuration

### Optimize API Response

Reduce response size and improve performance using the `exclude` parameter:

```
# Exclude unnecessary data sections
GET /data/3.0/onecall?lat=51.5074&lon=-0.1278&appid=KEY&exclude=minutely,alerts

# Get only hourly data
GET /data/3.0/onecall?lat=51.5074&lon=-0.1278&appid=KEY&exclude=current,daily,hourly
```

### Set Preferred Units

```javascript
// Metric units (Celsius, m/s)
https://api.openweathermap.org/data/3.0/onecall?lat=40.7128&lon=-74.0060&units=metric&appid=KEY

// Imperial units (Fahrenheit, mph)
https://api.openweathermap.org/data/3.0/onecall?lat=40.7128&lon=-74.0060&units=imperial&appid=KEY
```

### Set Language

```
# Spanish weather descriptions
GET /data/3.0/onecall?lat=40.4168&lon=-3.7038&lang=es&appid=KEY

# Chinese weather descriptions
GET /data/3.0/onecall?lat=39.9042&lon=116.4074&lang=zh_cn&appid=KEY
```

---

## Examples

### Example 1: Current Weather & Forecast (JavaScript)

```javascript
const API_KEY = 'your_api_key';
const lat = 51.5074;
const lon = -0.1278;

fetch(`https://api.openweathermap.org/data/3.0/onecall?lat=${lat}&lon=${lon}&units=metric&appid=${API_KEY}`)
  .then(response => response.json())
  .then(data => {
    console.log('Current:', data.current);
    console.log('Hourly:', data.hourly);
    console.log('Daily:', data.daily);
    console.log('Alerts:', data.alerts);
  })
  .catch(error => console.error('API Error:', error));
```

### Example 2: Historical Weather Data

```bash
# Get weather for January 1, 2020
curl "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=40.7128&lon=-74.0060&dt=1577836800&appid=YOUR_API_KEY&units=metric"
```

### Example 3: Daily Summary

```bash
# Get weather summary for specific date
curl "https://api.openweathermap.org/data/3.0/onecall/day_summary?lat=35.6762&lon=139.6503&date=2024-01-15&tz=+09:00&appid=YOUR_API_KEY"
```

### Example 4: AI Weather Assistant

```javascript
const sessionResponse = await fetch('https://api.openweathermap.org/assistant/session', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-Api-Key': 'your_api_key'
  },
  body: JSON.stringify({
    prompt: "What's the weather like in London? Should I bring an umbrella?"
  })
});

const session = await sessionResponse.json();
console.log('Session ID:', session.session_id);
console.log('Response:', session.message);
```

---

## Rate Limits & Quotas

**Free Tier**:
- 1,000 calls/day
- Available for evaluation and non-commercial use

**Paid Tiers**:
- Starter: 10,000 calls/month
- Professional: 60,000 calls/month
- Enterprise: Custom limits

**Quota Management**:
- Monitor usage in OpenWeather dashboard
- Implement request caching to reduce API calls
- Use `exclude` parameter to reduce response size
- Consider batch processing for historical requests

---

## Limitations & Considerations

1. **Historical UV Data**: Available only 5 days retroactively
2. **Polar Regions**: Sunrise/sunset data may be unavailable during midnight sun or polar night periods
3. **Data Update Frequency**: Weather data updated every 10 minutes
4. **Forecast Accuracy**: Daily forecasts available 8 days ahead; hourly forecasts 48 hours ahead
5. **Time Machine Availability**: Historical data from January 1, 1979; future forecasts available 4 days ahead
6. **Subscription Required**: One Call API 3.0 is not available on free legacy plans

---

## Links

- **Official Documentation**: https://openweathermap.org/api/one-call-3
- **OpenWeather Main Site**: https://openweathermap.org/
- **API Dashboard**: https://openweathermap.org/api
- **Account Management**: https://home.openweathermap.org/
- **Support & FAQ**: https://openweathermap.org/faq
