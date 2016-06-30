//
//  FuzzyLogicDefinitions.h
//  NEContextSDK
//
//  Copyright (c) 2016 NumberEight. All rights reserved.
//

#ifndef FuzzyLogicDefinitions_h
#define FuzzyLogicDefinitions_h

/* Definitions */
#define FUZZY_CONTROLLER_MAX_RULE_OUTPUTS     15
#define THREE_LEVEL_FLC_1                     0.25
#define THREE_LEVEL_FLC_2                     0.5
#define THREE_LEVEL_FLC_3                     0.75
#define FOUR_LEVEL_FLC_1                      0.2
#define FOUR_LEVEL_FLC_2                      0.4
#define FOUR_LEVEL_FLC_3                      0.6
#define FOUR_LEVEL_FLC_4                      0.8
#define FIVE_LEVEL_FLC_1                      0.167
#define FIVE_LEVEL_FLC_2                      0.330
#define FIVE_LEVEL_FLC_3                      0.5
#define FIVE_LEVEL_FLC_4                      0.667
#define FIVE_LEVEL_FLC_5                      0.833

#define SEVEN_LEVEL_FLC_1                     0.143
#define SEVEN_LEVEL_FLC_2                     0.286
#define SEVEN_LEVEL_FLC_3                     0.429
#define SEVEN_LEVEL_FLC_4                     0.572
#define SEVEN_LEVEL_FLC_5                     0.715
#define SEVEN_LEVEL_FLC_6                     0.858
#define SEVEN_LEVEL_FLC_7                     1.000
#define SEVEN_LEVEL_FLC_8                     1.142

/* Enumerations & Structure Definitions */
typedef enum fuzzy_controller_input_data_e {
  WEATHER_TO_MOOD_INPUT_DATA = 0,
  CONTEXT_MODELING_INPUT_DATA,
  INDOOR_OUTDOOR_INPUT_DATA,
  INPUT_DATA_MAX
} fuzzy_controller_input_data_e_type;

typedef struct fuzzy_controller_output_data_s {
  int results_count;
  double results[FUZZY_CONTROLLER_MAX_RULE_OUTPUTS];
} fuzzy_controller_output_data_s_type;

typedef enum fuzzy_controller_sunshine_amount_e {
  SUNSHINE_AMOUNT_LOW = 0,
  SUNSHINE_AMOUNT_MEDIUM,
  SUNSHINE_AMOUNT_HIGH,
  SUNSHINE_AMOUNT_MAX
} fuzzy_controller_sunshine_amount_e_type;

typedef enum fuzzy_controller_season_e {
  WINTER_SEASON = 0,
  SPRING_SEASON,
  SUMMER_SEASON,
  FALL_SEASON,
  MAX_SEASON
} fuzzy_controller_season_e_type;

typedef enum fuzzy_controller_activity_type_e {
  ACTIVITY_UNKNOWN = 0,
  ACTIVITY_STATIONARY,
  ACTIVITY_WALKING,
  ACTIVITY_RUNNING,
  ACTIVITY_DRIVING,
  ACTIVITY_MAX
} fuzzy_controller_activity_type_e_type;

typedef enum fuzzy_controller_day_category_e {
  DAY_CATEGORY_WEEKDAY = 0,
  DAY_CATEGORY_WEEKEND,
  DAY_CATEGORY_BOTH,
  DAY_CATEGORY_MAX
} fuzzy_controller_day_category_e_type;

typedef enum fuzzy_controller_time_of_day_e {
  TIME_OF_DAY_SLEEPTIME = 0,
  TIME_OF_DAY_MORNING,
  TIME_OF_DAY_AFTERNOON,
  TIME_OF_DAY_EVENING,
  TIME_OF_DAY_NIGHT,
  TIME_OF_DAY_MAX
} fuzzy_controller_time_of_day_e_type;

typedef enum fuzzy_controller_indoor_outdoor_type_e {
  INDOOR_OUTDOOR_TYPE_UNKNOWN = 0,
  INDOOR_OUTDOOR_TYPE_INDOOR,
  INDOOR_OUTDOOR_TYPE_OUTDOOR,
  INDOOR_OUTDOOR_TYPE_MAX
} fuzzy_controller_indoor_outdoor_type_e_type;

typedef enum fuzzy_controller_brightness_e {
  BRIGHTNESS_DARK = 0,
  BRIGHTNESS_MEDIUM,
  BRIGHTNESS_BRIGHT,
  BRIGHTNESS_MAX
} fuzzy_controller_brightness_e_type;

typedef enum fuzzy_controller_daytime_category_e {
  DAYTIME_CATEGORY_DAYTIME = 0,
  DAYTIME_CATEGORY_NIGHTTIME,
  DAYTIME_CATEGORY_MAX
} fuzzy_controller_daytime_category_e_type;

typedef enum fuzzy_controller_magnetic_variance_e {
  MAGNETIC_VARIANCE_LOW = 0,
  MAGNETIC_VARIANCE_HIGH,
  MAGNETIC_VARIANCE_MAX
} fuzzy_controller_magnetic_variance_e_type;

typedef enum fuzzy_controller_location_e {
  LOCATION_TYPE_HOME = 0,
  LOCATION_TYPE_OFFICE,
  LOCATION_TYPE_LIBRARY,
  LOCATION_TYPE_GYM,
  LOCATION_TYPE_BEACH,
  LOCATION_TYPE_SHOPS_AND_SERVICES,
  LOCATION_TYPE_FOODRELATED,
  LOCATION_TYPE_OTHER,
  LOCATION_TYPE_MAX
} fuzzy_controller_location_e_type;

typedef enum fuzzy_controller_device_movement_e {
  DEVICE_MOVEMENT_UNKNOWN = 0,
  DEVICE_MOVEMENT_MOVING,
  DEVICE_MOVEMENT_NOT_MOVING,
  DEVICE_MOVEMENT_MAX
} fuzzy_controller_device_movement_e_type;

typedef enum fuzzy_controller_reachability_e {
  REACHABILITY_UNREACHABLE = 0,
  REACHABILITY_CELLULAR_ONLY,
  REACHABILITY_WIFI_ONLY,
  REACHABILITY_WIFI_AND_CELLULAR
} fuzzy_controller_reachability_e_type;

typedef enum fuzzy_controller_device_lock_status_e {
  DEVICE_LOCK_STATUS_UNLOCKED = 0,
  DEVICE_LOCK_STATUS_LOCKED
} fuzzy_controller_device_lock_status_e_type;

typedef struct fuzzy_controller_weather_to_mood_s {
  double temperature;
  double humidity;
  double pressure;
  fuzzy_controller_season_e_type season_type;
  double sunshine_amount;
} fuzzy_controller_weather_to_mood_s_type;

typedef struct fuzzy_controller_context_modeling_s {
  fuzzy_controller_activity_type_e_type activity;
  fuzzy_controller_day_category_e_type day_category;
  double time_of_day_in_hours;
  fuzzy_controller_indoor_outdoor_type_e_type indoor_outdoor;
  fuzzy_controller_location_e_type  location_type;
} fuzzy_controller_context_modeling_s_type;

typedef struct fuzzy_controller_indoor_outdoor_s {
  double brightness;
  fuzzy_controller_daytime_category_e_type daytime_or_nighttime;
  fuzzy_controller_device_lock_status_e_type lock_status;
  double magnetic_variance;
  fuzzy_controller_device_movement_e_type movement;
  fuzzy_controller_reachability_e_type reachability;
} fuzzy_controller_indoor_outdoor_s_type;

typedef struct fuzzy_controller_location_context_s {
  double visit_duration;
  double arrivalTime;
  double departureTime;
  double weekday_or_weekend_in_hours;
  fuzzy_controller_reachability_e_type reachability;
} fuzzy_controller_location_context_s_type;

typedef struct fuzzy_controller_day_category_s {
  double weekday_or_weekend_in_hours;
  bool  special_day_category_model;
} fuzzy_controller_day_category_s_type;

typedef struct fuzzy_controller_day_category_input_data_type_s {
  fuzzy_controller_day_category_s_type  input_data;
  fuzzy_controller_output_data_s_type   output_data;
} fuzzy_controller_day_category_input_data_type_s_type;

typedef struct fuzzy_controller_weather_to_mood_input_data_type_s {
  fuzzy_controller_weather_to_mood_s_type  input_data;
  fuzzy_controller_output_data_s_type     output_data;
} fuzzy_controller_weather_to_mood_input_data_type_s_type;

typedef struct fuzzy_controller_context_modeling_input_data_type_s {
  fuzzy_controller_context_modeling_s_type  input_data;
  fuzzy_controller_output_data_s_type       output_data;
} fuzzy_controller_context_modeling_input_data_type_s_type;

typedef struct fuzzy_controller_indoor_outdoor_input_data_type_s {
  fuzzy_controller_indoor_outdoor_s_type  input_data;
  fuzzy_controller_output_data_s_type     output_data;
} fuzzy_controller_indoor_outdoor_input_data_type_s_type;

typedef struct fuzzy_controller_location_context_input_data_type_s {
  fuzzy_controller_location_context_s_type  input_data;
  fuzzy_controller_output_data_s_type       output_data;
} fuzzy_controller_location_context_input_data_type_s_type;

#endif /* FuzzyLogicDefinitions_h */
