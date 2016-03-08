//
//  APHDashboardGraphTableViewCell.m
//  mPowerSDK
//
//  Created by Jake Krog on 2016-02-29.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "APHDashboardGraphTableViewCell.h"
#import "APHDiscreteGraphView.h"
#import "APHMedTimingLegendView.h"

const CGFloat kSparkLineGraphContainerHeight = 172.f;
const CGFloat kCorrelationSelectorHeight = 48.f;

NSInteger static compareViewsByOrigin(id sp1, id sp2, void *context)
{
    float v1 = ((UIView *)sp1).frame.origin.x;
    float v2 = ((UIView *)sp2).frame.origin.x;
    
    if (v1 < v2) {
        return NSOrderedAscending;
    } else if (v1 > v2) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

@interface APHDashboardGraphTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *medicationLegendContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *correlationSelectorHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tintViewWidthConstraint;

@property (weak, nonatomic) IBOutlet APHMedTimingLegendView *medicationLegendContainerView;

@property (nonatomic) CGFloat defaultTintViewWidth;

@end

@implementation APHDashboardGraphTableViewCell

+ (CGFloat)medicationLegendContainerHeight
{
    return [APHMedTimingLegendView defaultHeight];
}

+ (CGFloat)sparkLineGraphContainerHeight
{
    return kSparkLineGraphContainerHeight;
}

+ (CGFloat)correlationSelectorHeight
{
    return kCorrelationSelectorHeight;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self giveImageViewDownCarrotImage:self.button1DownCarrot];
    [self giveImageViewDownCarrotImage:self.button2DownCarrot];
    
    [self updateSegmentColors];
}

#pragma mark - Helper Methods

- (void)giveImageViewDownCarrotImage:(UIImageView *)button
{
    [button setImage:[UIImage imageNamed:@"down_carrot"]];
    [button setTintColor:[UIColor lightGrayColor]];
}

// From: http://stackoverflow.com/questions/1196679/customizing-the-colors-of-a-uisegmentedcontrol
- (void) updateSegmentColors
{
    NSUInteger numSegments = [self.correlationSegmentControl.subviews count];
    
    // Reset segment's color
    for( int i = 0; i < numSegments; i++ ) {
        [[self.correlationSegmentControl.subviews objectAtIndex:i] setTintColor:nil];
        [[self.correlationSegmentControl.subviews objectAtIndex:i] setTintColor:[UIColor appSecondaryColor2]];
        
        UIView *segmentView = [self.correlationSegmentControl.subviews objectAtIndex:i];
        for (UIImageView *imageView in segmentView.subviews) {
            [imageView setTintColor:[UIColor appTertiaryGrayColor]];
        }
    }
    
    // Sort Segments from left to right
    NSArray *sortedViews = [self.correlationSegmentControl.subviews sortedArrayUsingFunction:compareViewsByOrigin context:NULL];
    
    // Set selected segment color
    NSInteger selectedIdx = self.correlationSegmentControl.selectedSegmentIndex;
    UIColor *darkBlueColor = [UIColor colorWithRed:0.24 green:0.37 blue:0.51 alpha:1];
    [[sortedViews objectAtIndex:selectedIdx] setTintColor:darkBlueColor];
    
    // Remove all original segments from the control
    for (id view in self.correlationSegmentControl.subviews) {
        [view removeFromSuperview];
    }
    
    // Append sorted and colored segments to the control
    for (id view in sortedViews) {
        [self.correlationSegmentControl addSubview:view];
    }
}

#pragma mark - Accessors

- (void)setButton1Title:(NSString *)button1Title
{
    _button1Title = button1Title;
    self.button1Label.text = button1Title;
}

- (void)setButton2Title:(NSString *)button2Title
{
    _button2Title = button2Title;
    self.button2Label.text = button2Title;
}

- (void)setCorrelationButton1TitleColor:(UIColor *)correlationButton1TitleColor
{
    _correlationButton1TitleColor = correlationButton1TitleColor;
    self.button1Label.textColor = correlationButton1TitleColor;
}

- (void)setCorrelationButton2TitleColor:(UIColor *)correlationButton2TitleColor
{
    _correlationButton2TitleColor = correlationButton2TitleColor;
    self.button2Label.textColor = correlationButton2TitleColor;
}

- (void)setHideTintBar:(BOOL)hideTintBar
{
    _hideTintBar = hideTintBar;
    self.tintView.hidden = hideTintBar;
    
    if (hideTintBar) {
        self.defaultTintViewWidth = self.tintViewWidthConstraint.constant;
        self.tintViewWidthConstraint.constant = 0.f;
    } else {
        self.tintViewWidthConstraint.constant = self.defaultTintViewWidth;
    }
    
    [self setNeedsLayout];
}

- (void)setShowCorrelationSelectorView:(BOOL)showCorrelationSelectorView
{
    _showCorrelationSelectorView = showCorrelationSelectorView;
    self.correlationSelectorView.hidden = !showCorrelationSelectorView;
    self.legendButton.userInteractionEnabled = !showCorrelationSelectorView;
}

- (void)setShowCorrelationSegmentControl:(BOOL)showCorrelationSegmentControl
{
    _showCorrelationSegmentControl = showCorrelationSegmentControl;
    self.correlationSelectorHeight.constant = showCorrelationSegmentControl ? [[self class] correlationSelectorHeight] : 0.f;
    self.correlationSegmentControlView.hidden = !showCorrelationSegmentControl;
    [self setNeedsLayout];
}

- (void)setShowMedicationLegend:(BOOL)showMedicationLegend
{
    _showMedicationLegend = showMedicationLegend;
    self.medicationLegendContainerHeightConstraint.constant = showMedicationLegend ? [[self class] medicationLegendContainerHeight] : 0.f;
    self.medicationLegendContainerView.hidden = !showMedicationLegend;
    [self setNeedsLayout];
}

- (void)setShowMedicationLegendCorrelation:(BOOL)showMedicationLegendCorrelation
{
    _showMedicationLegendCorrelation = showMedicationLegendCorrelation;
    self.medicationLegendContainerView.showCorrelationLegend = showMedicationLegendCorrelation;
    [self setNeedsLayout];
}

- (void)setSecondaryTintColor:(UIColor *)secondaryTintColor
{
    _secondaryTintColor = secondaryTintColor;
    
    self.medicationLegendContainerView.secondaryTintColor = secondaryTintColor;
    ((APHDiscreteGraphView *)self.discreteGraphView).secondaryTintColor = secondaryTintColor;
}

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    
    self.medicationLegendContainerView.tintColor = tintColor;
}

#pragma mark - IBActions

- (IBAction)correlationButton1Pressed:(UIButton *)sender
{
    [self.correlationDelegate dashboardTableViewCellDidTapCorrelationIndex:0 cell:self];
}

- (IBAction)correlationButton2Pressed:(UIButton *)sender
{
    [self.correlationDelegate dashboardTableViewCellDidTapCorrelationIndex:1 cell:self];
}

- (IBAction)correlationSegmentChanged:(UISegmentedControl *)sender
{
    [self updateSegmentColors];
    [self.correlationDelegate dashboardTableViewCellDidChangeCorrelationSegment:self.correlationSegmentControl.selectedSegmentIndex];
}


@end
