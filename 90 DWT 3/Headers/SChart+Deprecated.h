//
//  SChart+Deprecated.h
//  ShinobiCharts
//
//  Copyright 2015 Scott Logic Ltd. All rights reserved.
//
//

#import "SChart.h"

/* The methods and attributes below are deprecated.
 */
@interface ShinobiChart ()

/* Specifies whether the chart auto-calculates its axis ranges when it reloads its data.
 By default, this property is set to `YES`.
 */
@property (nonatomic, assign) BOOL autoCalculateAxisRanges SCHART_MSG_DEPRECATED("set autoCalculateRange per axis instead");

/* The general styling configuration for the whole chart.
 */
@property (nonatomic, retain) SChartTheme *theme SCHART_MSG_DEPRECATED("use `applyTheme:`");

/* A reference to the chart object
 */
- (ShinobiChart *)getChart SCHART_DEPRECATED;

/* The frame that contains the whole chart object */
- (CGRect)chartFrame SCHART_MSG_DEPRECATED("Use 'frame'.");

/* A reference to the canvas object of the chart
 
 The chart canvas is responsible for drawing all of the axes and series on a chart.
 */
- (SChartCanvas *)getCanvas SCHART_MSG_DEPRECATED("use `canvas` property");

/* The area rendered by the openGL functions
 */
- (CGRect)getGLFrame SCHART_MSG_DEPRECATED("Use 'plotAreaFrame' instead.");

/* Apply the current chart theme to the chart.
 */
- (void)applyTheme SCHART_MSG_DEPRECATED("use `applyTheme:`");

- (void)redrawChartAndGL:(BOOL)redrawGL SCHART_MSG_DEPRECATED("See 'redrawChartIncludePlotArea'");

/* Returns a string describing the version of the Charts framework being used.
 
 This includes a version number, the type of framework (Premium, Standard, or Trial) and the date upon which the version was released.
 */
-(NSString *)getInfo SCHART_MSG_DEPRECATED("Use `[ShinobiCharts getInfo]` instead");

/* Get the current annotations on the chart
 
 @available Premium
 @return An array containing all the annotations on the chart.
 */
-(NSArray SC_GENERIC(SChartAnnotation *) *)getAnnotations SCHART_MSG_DEPRECATED("Use 'annotations' property instead");

/* The frame of the plot area in the coordinate system of the chart view.
 
 This is the area in which your data is visualised in series.
 This area does not usually contain the chart title, legend, axes or axis titles, or any tickmarks or ticklabels unless they are explicitly positioned inside the plot area.
 */
- (CGRect)getPlotAreaFrame SCHART_MSG_DEPRECATED("Use 'plotAreaFrame' property.");

/* Refreshes whether panning is enabled on the chart canvas.  It is called whenever the enableGesturePanning property is changed on any of the axes associated with the chart.
 @see SChartAxis
 @see SChartCanvas
 */
- (void)axisPanningChanged SCHART_MSG_DEPRECATED("This is now updated automatically.");

/* Set the method for zooming the chart
 
 - SChartGesturePanTypeNone: This property disables pan gestures on the chart.
 - SChartGesturePanTypePanPinch: Configures the chart to use pinch zoom gestures.
 - SChartGesturePanTypeBoxDraw: Configures the chart to use touch gestures to generate a box on the chart. The chart will animate the zoom level to display the area marked by the box.
 
 Defaults to `SChartGesturePanTypePanPinch` */
@property (nonatomic) SChartGesturePanType gesturePanType SCHART_MSG_DEPRECATED("use .gestureManager.panType instead");

/* When set to `YES` all of the axis will zoom the same amount
 
 The chart will maintain its aspect ratio regardless of the type or orientation of gesture. */
@property (nonatomic) BOOL gesturePinchAspectLock SCHART_MSG_DEPRECATED("use .gestureManager.pinchAspectLock instead");

/* When set to `YES` the double-tap gesture is enabled, and its behaviour obeys the `gestureDoubleTapResetsZoom` property.
 
 Otherwise, if set to `NO` the chart's double tap gesture recognizer will be disabled.
 
 By default, this property is set to `YES`. */
@property (nonatomic) BOOL gestureDoubleTapEnabled SCHART_MSG_DEPRECATED("use .gestureManager.doubleTapEnabled instead");

/* When set to `YES` the _double-tap_ gesture will reset the zoom level to _default_
 
 Otherwise, if set to `NO` the chart will zoom in  a set amount.
 
 By default, this property is set to `NO`. */
@property (nonatomic) BOOL gestureDoubleTapResetsZoom SCHART_MSG_DEPRECATED("use .gestureManager.doubleTapResetsZoom instead");

/* When set to `YES` the zoom resulting from a box gesture will animate to the new zoom level
 
 By default, this property is set to `YES`. */
@property (nonatomic) BOOL animateBoxGesture SCHART_MSG_DEPRECATED("use .gestureManager.animateBoxGesture instead");

/* When set to `YES` the zoom resulting from a pinch gesture will animate to the new zoom level
 
 By default, this property is set to `YES`. */
@property (nonatomic) BOOL animateZoomGesture SCHART_MSG_DEPRECATED("use .gestureManager.animateZoomGesture instead");

/* When set to `YES` the radial-chart single tap gesture is enabled
 
 Otherwise, if set to `NO` the radial chart's tap gesture recognizer will be disabled.
 
 By default, this property is set to `YES`. */
@property (nonatomic) BOOL radialTapEnabled SCHART_MSG_DEPRECATED("use .gestureManager.radialTapEnabled instead");

/* When set to `YES` the radial-chart rotation gesture is enabled
 
 Otherwise, if set to `NO` the radial chart's rotation gesture recognizer will be disabled.
 
 By default, this property is set to `YES`.
 
 In order for radial series to respond to rotation gestures, they must also have their `gesturePanningEnabled` property set to `YES`. See `SChartDonutSeries` for documentation on this property.
 
 @see SChartDonutSeries
 */
@property (nonatomic) BOOL radialRotationEnabled SCHART_MSG_DEPRECATED("use .gestureManager.radialRotationEnabled instead");

/*
 The trial license key for this chart (Used for trial versions only)
 
 In trial versions of a chart, a valid trial key must be set before the chart will render.  When you download a trial version of ShinobiCharts, you will also receive an email containing the trial key.
 */
@property (nonatomic) NSString *licenseKey SCHART_MSG_DEPRECATED("Use ShinobiCharts.trialKey instead");

@end
