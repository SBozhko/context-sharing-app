//
//  CPlusPlusLinkage.h
//  NEContextSDK
//
//  Copyright (c) 2016 NumberEight. All rights reserved.
//

#ifndef CPlusPlusLinkage_h
#define CPlusPlusLinkage_h

#include "FuzzyLogicDefinitions.h"

#ifdef __cplusplus
extern "C" {
#endif
  void process_day_category_flc_data(fuzzy_controller_day_category_input_data_type_s_type *data, fuzzy_model_configuration *fmc);
  void process_weather_to_mood_flc_data(fuzzy_controller_weather_to_mood_input_data_type_s_type *data, fuzzy_model_configuration *fmc);
  void process_context_modeling_flc_data(fuzzy_controller_context_modeling_input_data_type_s_type *data, fuzzy_model_configuration *fmc);
  void process_indoor_outdoor_flc_data(fuzzy_controller_indoor_outdoor_input_data_type_s_type *data, fuzzy_model_configuration *fmc);
  void process_location_context_flc_data(fuzzy_controller_location_context_input_data_type_s_type *data, fuzzy_model_configuration *fmc);
#ifdef __cplusplus
}
#endif

#endif /* defined(__NEContextSDK__CPlusPlusLinkage__) */
