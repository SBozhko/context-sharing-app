//
//  FuzzyLogicDefinitions.h
//  NEContextSDK
//
//  Copyright (c) 2016 NumberEight. All rights reserved.
//

#ifndef FuzzyLogicDefinitions_h
#define FuzzyLogicDefinitions_h

#include <stdio.h>

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


// Fuzzy Models Configuration -- Common

typedef struct {
  double start;
  double end;
} fmc_range;

// Fuzzy Models Configuration -- DayCategory

typedef struct {
  fmc_range range;
  double weekday [4];
  double weekend [4];
} day_category_fmc_input_terms;


typedef struct {
  day_category_fmc_input_terms day_of_week;
} day_category_fmc_input_params;

typedef struct {
  double default_value;
  int centroid;
  fmc_range range;
  double weekday [3];
  double weekend [3];
} day_category_fmc_output_terms;

typedef struct {
  day_category_fmc_output_terms day_category;
} day_category_fmc_output_params;

typedef struct {
  char** get_day_category_rb;
  int get_day_category_rb_size;
} day_category_fmc_rule_block;


typedef struct {
  day_category_fmc_input_params input_params;
  day_category_fmc_output_params output_params;
  day_category_fmc_rule_block rule_block;
} day_category_fmc;

// Fuzzy Models Configuration -- WeekdayContextModelingFLC

typedef struct {
  fmc_range range;
  double unknown [3];
  double stationary [3];
  double walking [3];
  double running [3];
  double driving [3];
} weekday_context_modeling_fmc_input_terms_activity;

typedef struct {
  fmc_range range;
  double morning [3];
  double before_lunch [3];
  double afternoon [3];
  double evening [3];
  double night [4];
  double breakfast [3];
  double lunch [3];
  double dinner [3];
  double early_hours [4];
} weekday_context_modeling_fmc_input_terms_time_of_day;

typedef struct {
  fmc_range range;
  double unknown [3];
  double indoor [3];
  double outdoor [3];
} weekday_context_modeling_fmc_input_terms_indoor_outdoor;

typedef struct {
  fmc_range range;
  double home [3];
  double office [3];
  double library [3];
  double gym [3];
  double beach [3];
  double shops_and_services [3];
  double food_related [3];
  double other [3];
} weekday_context_modeling_fmc_input_terms_place;

typedef struct {
  weekday_context_modeling_fmc_input_terms_activity activity;
  weekday_context_modeling_fmc_input_terms_time_of_day time_of_day;
  weekday_context_modeling_fmc_input_terms_indoor_outdoor indoor_outdoor;
  weekday_context_modeling_fmc_input_terms_place place;
} weekday_context_modeling_fmc_input_params;

typedef struct {
  double default_value;
  int centroid;
  fmc_range range;
  double housework [3];
  double relaxing [3];
  double working_or_studying [3];
  double commuting [3];
  double exercising [3];
  double sleep [3];
  double wake_up [3];
  double social [3];
} weekday_context_modeling_fmc_output_terms;

typedef struct {
  weekday_context_modeling_fmc_output_terms context;
} weekday_context_modeling_fmc_output_params;

typedef struct {
  char** context_rules;
  int context_rules_size;
} weekday_context_modeling_fmc_rule_block;

typedef struct {
  weekday_context_modeling_fmc_input_params input_params;
  weekday_context_modeling_fmc_output_params output_params;
  weekday_context_modeling_fmc_rule_block rule_block;
} weekday_context_modeling_fmc;

// Fuzzy Models Configuration -- IndoorOutdoor

typedef struct {
  fmc_range range;
  double unlocked [3];
  double locked [3];
} indoor_outdoor_fmc_input_terms_device_lock_status;

typedef struct {
  fmc_range range;
  double unreachable [3];
  double cellular_only [3];
  double wifi_only [3];
  double wifi_and_cellular [3];
} fmc_input_terms_device_reachability;

typedef struct {
  fmc_range range;
  double unknown [3];
  double moving [3];
  double not_moving [3];
} indoor_outdoor_fmc_input_terms_device_movement;

typedef struct {
  fmc_range range;
  double high [4];
  double low [4];
  double medium [3];
} indoor_outdoor_fmc_input_terms_magnetic_variance;

typedef struct {
  fmc_range range;
  double daytime [3];
  double night_time [3];
} indoor_outdoor_fmc_input_terms_time_of_day;

typedef struct {
  fmc_range range;
  double dark [3];
  double medium [3];
  double bright [4];
} fmc_input_terms_brightness;

typedef struct {
  fmc_input_terms_brightness brightness;
  indoor_outdoor_fmc_input_terms_time_of_day time_of_day;
  indoor_outdoor_fmc_input_terms_magnetic_variance magnetic_variance;
  indoor_outdoor_fmc_input_terms_device_movement device_movement;
  fmc_input_terms_device_reachability device_reachability;
  indoor_outdoor_fmc_input_terms_device_lock_status device_lock_status;
} indoor_outdoor_fmc_input_params;

typedef struct {
  double default_value;
  int centroid;
  fmc_range range;
  double unknown [3];
  double indoor [3];
  double outdoor [3];
} indoor_outdoor_fmc_output_terms;

typedef struct {
  indoor_outdoor_fmc_output_terms brightness_indoor_outdoor;
  indoor_outdoor_fmc_output_terms magnetic_indoor_outdoor;
} indoor_outdoor_fmc_output_params;

typedef struct {
  char** brightness_indoor_outdoor_rb;
  int brightness_indoor_outdoor_rb_size;
  char** magnetic_indoor_outdoor_rb;
  int magnetic_indoor_outdoor_rb_size; 
} indoor_outdoor_fmc_rule_block;

typedef struct {
  indoor_outdoor_fmc_input_params input_params;
  indoor_outdoor_fmc_output_params output_params;
  indoor_outdoor_fmc_rule_block rule_block;
} indoor_outdoor_fmc;

// Fuzzy Models Configuration -- LocationContext
typedef struct {
  fmc_range range;
  double short_duration [4];
  double medium [3];
  double long_duration [4];
} location_context_fmc_input_terms_visit_duration;

typedef struct {
  fmc_range range;
  double morning [4];
  double afternoon [3];
  double evening [3];
  double night [4];
  double distant_past [3];
} location_context_fmc_input_terms_arrival_time;

typedef struct {
  fmc_range range;
  double morning [4];
  double afternoon [3];
  double evening [3];
  double night [4];
  double distant_future [3];
} location_context_fmc_input_terms_departure_time;

typedef struct {
  fmc_range range;
  double weekday [4];
  double weekend [4];
} fmc_input_terms_day_of_week;

typedef struct {
  location_context_fmc_input_terms_visit_duration visit_duration;
  location_context_fmc_input_terms_arrival_time arrival_time;
  location_context_fmc_input_terms_departure_time departure_time;
  fmc_input_terms_day_of_week day_of_week;
  fmc_input_terms_device_reachability device_reachability;
} location_context_fmc_input_params;

typedef struct {
  double default_value;
  int centroid;
  fmc_range range;
  double home [3];
  double office [3];
  double library [3];
  double gym [3];
  double other [3];
} location_context_fmc_output_terms;

typedef struct {
  location_context_fmc_output_terms location;
} location_context_fmc_output_params;

typedef struct {
  char** location_rb;
  int location_rb_size;
} location_context_modeling_fmc_rule_block;

typedef struct {
  location_context_fmc_input_params input_params;
  location_context_fmc_output_params output_params;
  location_context_modeling_fmc_rule_block rule_block;
} location_context_fmc;

// Fuzzy Models Configuration -- WeatherToMood

typedef struct {
  fmc_range range;
  double v_cold [4];
  double normal [3];
  double hot [3];
  double cold [3];
  double v_hot [4];
} weather_to_mood_fmc_input_terms_temperature;

typedef struct {
  fmc_range range;
  double low [4];
  double medium [3];
  double high [4];
} weather_to_mood_fmc_input_terms;

typedef struct {
  weather_to_mood_fmc_input_terms_temperature temperature;
  weather_to_mood_fmc_input_terms humidity;
  weather_to_mood_fmc_input_terms sunshine;
  weather_to_mood_fmc_input_terms pressure;
} weather_to_mood_fmc_input_params;

typedef struct {
  double default_value;
  int centroid;
  fmc_range range;
  double negative [3];
  double neutral [3];
  double positive [3];
} weather_to_mood_fmc_output_terms;

typedef struct {
  weather_to_mood_fmc_output_terms arousal;
  weather_to_mood_fmc_output_terms valence;
} weather_to_mood_fmc_output_params;

typedef struct {
  char** arousal_rb;
  int arousal_rb_size;
  char** valence_rb;
  int valence_rb_size;
} weather_to_mood_fmc_rule_block;

typedef struct {
  weather_to_mood_fmc_input_params input_params;
  weather_to_mood_fmc_output_params output_params;
  weather_to_mood_fmc_rule_block rule_block;
} weather_to_mood_fmc;

// Fuzzy Models Configuration -- All models

typedef struct {
  day_category_fmc day_category;
  day_category_fmc day_category_special;
  weekday_context_modeling_fmc weekday_context_modeling;
  weekday_context_modeling_fmc weekend_context_modeling;
  indoor_outdoor_fmc indoor_outdoor;
  location_context_fmc location_context;
  weather_to_mood_fmc weather_to_mood;
} fuzzy_model_configuration; // fmc


#endif /* FuzzyLogicDefinitions_h */
