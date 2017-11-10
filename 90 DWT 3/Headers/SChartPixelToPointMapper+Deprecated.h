//
//  SChartPixelToPointMapper+Deprecated.h
//  ShinobiCharts
//
//  Copyright Scott Logic Ltd 2015. All rights reserved.
//
//

#import "SChartPixelToPointMapper.h"

@interface SChartPixelToPointMapper ()

/*
 Map a pixel point with a (possibly nil) initial series.
 
 This method will return a `SChartPixelToPointMapping`, which describes the
 closest series, datapoint and suggested pixel point for a given pixel point
 on the chart.
 
 If `initialSeries` is nil, all series on the chart are searched through,
 otherwise only the datapoints on the given series are searched.
 
 `chart` is the ShinobiChart on which to search.
 */
- (SChartPixelToPointMapping *)mappingForPoint:(CGPoint)pixelPoint
                                      onSeries:(SChartMappedSeries *)series
                                       onChart:(ShinobiChart *)chart SCHART_MSG_DEPRECATED("Use mappingForPoint:seriesToSearch:onChart:");

@end
