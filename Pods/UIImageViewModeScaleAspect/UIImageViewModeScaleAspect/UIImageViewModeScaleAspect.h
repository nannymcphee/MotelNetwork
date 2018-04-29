//
//  UIImageViewModeScaleAspect.m
//
// http://www.viviencormier.fr/
//
//  Created by Vivien Cormier on 02/05/13.
//  Copyright (c) 2013 Vivien Cormier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageViewModeScaleAspect : UIView

@property(nonatomic, strong) UIImage *image;

#pragma mark - Automatic Animate

/**
 *  Automatic Animate Fill to Fit
 *
 *  @param frame ignored "-Wdocumentation"
 *  @param duration ignored "-Wdocumentation"
 *  @param delay ignored "-Wdocumentation"
 */
- (void)animateToScaleAspectFitToFrame:(CGRect)frame
                          WithDuration:(float)duration
                            afterDelay:(float)delay;

/**
 *  Automatic Animate Fit to Fill
 *
 *  @param frame ignored "-Wdocumentation"
 *  @param duration ignored "-Wdocumentation"
 *  @param delay ignored "-Wdocumentation"
 */
- (void)animateToScaleAspectFillToFrame:(CGRect)frame
                           WithDuration:(float)duration
                             afterDelay:(float)delay;

/**
 *  Automatic Animate Fill to Fit with completion
 *
 *  @param frame ignored "-Wdocumentation"
 *  @param duration ignored "-Wdocumentation"
 *  @param delay ignored "-Wdocumentation"
 *  @param completion ignored "-Wdocumentation"
 */
- (void)animateToScaleAspectFitToFrame:(CGRect)frame
                          WithDuration:(float)duration
                            afterDelay:(float)delay
                            completion:(void (^)(BOOL finished))completion;

/**
 *  Automatic Animate Fit to Fill with completion
 *
 *  @param frame ignored "-Wdocumentation"
 *  @param duration ignored "-Wdocumentation"
 *  @param delay ignored "-Wdocumentation"
 *  @param completion ignored "-Wdocumentation"
 */
- (void)animateToScaleAspectFillToFrame:(CGRect)frame
                           WithDuration:(float)duration
                             afterDelay:(float)delay
                             completion:(void (^)(BOOL finished))completion;

#pragma mark - Manual Animate

#pragma mark - - Init Function

/**
 *  Init Manual Function Fit
 *
 *  @param newFrame ignored "-Wdocumentation"
 */
- (void)initToScaleAspectFitToFrame:(CGRect)newFrame;

/**
 *  Init Manual Function Fill
 *
 *  @param newFrame ignored "-Wdocumentation"
 */
- (void)initToScaleAspectFillToFrame:(CGRect)newFrame;

#pragma mark - - Animatic Function

/**
 *  Animatic Fucntion Fit
 */
- (void)animaticToScaleAspectFit;

/**
 *  Animatic Function Fill
 */
- (void)animaticToScaleAspectFill;

#pragma mark - - Last Function

/**
 *  Last Function Fit
 */
- (void)animateFinishToScaleAspectFit;

/**
 *  Last Function Fill
 */
- (void)animateFinishToScaleAspectFill;

@end
