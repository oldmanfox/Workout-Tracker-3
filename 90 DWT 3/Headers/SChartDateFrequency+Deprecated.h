//
//  SChartDateFrequency+Deprecated.h
//  ShinobiCharts
//
//  Copyright Scott Logic Ltd 2015. All rights reserved.
//
//

#import "SChartDateFrequency.h"
#import "ShinobiHeaderMacros.h"

@interface SChartDateFrequency ()

/* Initializes and returns a newly allocated date frequency object, with a frequency of the specified number of weeks.
 @param newWeek The frequency of the new object, in weeks.
 @return An initialized date frequency object, or `nil` if the object couldn't be created.
 */
- (id)initWithWeek:(NSInteger)newWeek
SCHART_MSG_DEPRECATED("Use initWithWeekOfMonth or initWithWeekOfYear, depending on which you mean")
NS_DESIGNATED_INITIALIZER;

/* Returns a new date frequency object, with a frequency of the specified number of weeks.
 @param newWeek The frequency to use, in weeks. */
+ (id)dateFrequencyWithWeek:(NSInteger)newWeek SCHART_MSG_DEPRECATED("Use dateFrequencyWithWeekOfMonth or dateFrequencyWithWeekOfYear, depending on which you mean");

/* Set the date frequency to have a value of the specified number of weeks.
 
 Before the new value is set, we clear any existing values in the object.
 @param v The new frequency to set, in weeks. */
- (void)setWeek:(NSInteger)v SCHART_MSG_DEPRECATED("Use weekOfMonth or weekOfYear, depending on which you mean");

/* Returns the frequency of the object, measured in seconds. */
- (double)toSeconds SCHART_MSG_DEPRECATED("This is used as a rough heuristic for sorting and not intended for use in user-code");

@end
