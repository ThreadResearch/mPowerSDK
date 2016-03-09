//
//  APHGraphViewController.m
//  mPowerSDK
//
//  Created by Andy Yeung on 3/3/16.
//  Copyright © 2016 Sage Bionetworks. All rights reserved.
//

#import "APHGraphViewController.h"
#import "APHLineGraphView.h"
#import "APHScoring.h"
#import "APHTableViewDashboardGraphItem.h"
#import "APHRegularShapeView.h"

@interface APCGraphViewController (Private)
@property (strong, nonatomic) APCSpinnerViewController *spinnerController;
- (void)reloadCharts;
- (void)segmentControlChanged:(UISegmentedControl *)sender;
- (void)setSubTitleText;
@end

@interface APHGraphViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *legendLabelLeadingSpaceConstraint;
@end

@implementation APHGraphViewController

#pragma mark - Accessors

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    
    self.medicationLegendContainerView.tintColor = tintColor;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.medicationLegendContainerView.hidden = self.shouldHideMedicationLegend;
    self.medicationLegendContainerView.showExpandedView = YES;
    self.medicationLegendContainerView.circleViewDiameter = 12.f;
    self.medicationLegendContainerView.tintColor = self.tintColor;
    self.medicationLegendContainerView.showCorrelationLegend = self.isForCorrelation;
    self.medicationLegendContainerView.tintColor = self.tintColor;
    self.medicationLegendContainerView.secondaryTintColor = self.secondaryTintColor;
    
    APCBaseGraphView *graphView;
    if (self.graphItem.graphType == (APCDashboardGraphType)kAPHDashboardGraphTypeScatter) {
        graphView = self.scatterGraphView;
        self.scatterGraphView.dataSource = (APHScoring *)self.graphItem.graphData;
        
        self.scatterGraphView.showsVerticalReferenceLines = YES;
        self.scatterGraphView.showsHorizontalReferenceLines = NO;

        for (APHRegularShapeView *shapeView in self.keyShapeViewsArray) {
            shapeView.tintColor = self.graphItem.tintColor;
        }
        
        self.discreteGraphView.hidden = YES;
        self.lineGraphView.hidden = YES;
    } else {
        self.scatterGraphView.hidden = YES;
    }
    
    if (self.graphItem.graphType == kAPCDashboardGraphTypeDiscrete) {
        APHDiscreteGraphView *discreteGraph = (APHDiscreteGraphView *)self.discreteGraphView;
        discreteGraph.showsHorizontalReferenceLines = NO;
        discreteGraph.primaryLineColor = [UIColor colorWithRed:236.f / 255.f
                                                         green:237.f / 255.f
                                                          blue:237.f / 255.f
                                                         alpha:1.f];

		discreteGraph.tintColor = self.tintColor;
		discreteGraph.secondaryTintColor = self.secondaryTintColor;
    }
    
    graphView.tintColor = self.graphItem.tintColor;
    graphView.landscapeMode = YES;
    
    graphView.minimumValueImage = self.graphItem.minimumImage;
    graphView.maximumValueImage = self.graphItem.maximumImage;
    
    [self updateViews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.graphItem.graphType == (APCDashboardGraphType)kAPHDashboardGraphTypeScatter) {
        [self.scatterGraphView refreshGraph];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (self.discreteGraphView.numberOfPlots > 1) {
        self.titleLabelWidthConstraint.constant = 0.f;
        self.legendLabelLeadingSpaceConstraint.constant = 0.f;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initilization Functions

- (void)updateViews
{
    self.subTitleLabel.hidden = self.shouldHideAverageLabel;
    self.correlationSegmentControl.hidden = self.shouldHideCorrelationSegmentControl;
    self.segmentedControl.hidden = !self.shouldHideCorrelationSegmentControl;
    
    if (!self.shouldHideCorrelationSegmentControl) {
        [self.correlationSegmentControl setSelectedSegmentIndex:self.selectedCorrelationTimeTab];
    }
    
    if ([self.lineGraphView isKindOfClass:[APHLineGraphView class]]
            && self.isForCorrelation) {
        ((APHLineGraphView *)self.lineGraphView).shouldDrawLastPoint = YES;
        ((APHLineGraphView *)self.lineGraphView).colorForFirstCorrelationLine = [UIColor appTertiaryRedColor];
        ((APHLineGraphView *)self.lineGraphView).colorForSecondCorrelationLine = [UIColor appTertiaryYellowColor];
        
        self.lineGraphView.hidesDataPoints = YES;
    }
}

#pragma mark - APCGraphViewController Overrides

- (void)reloadCharts
{
    if (self.graphItem.graphType == (APCDashboardGraphType)kAPHDashboardGraphTypeScatter) {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.scatterGraphView layoutSubviews];
            [weakSelf.scatterGraphView refreshGraph];
            
            [weakSelf setSubTitleText];
        });
    }
    
    [super reloadCharts];
}

- (void)segmentControlChanged:(UISegmentedControl *)sender
{
    APHScoring *graphScoring = (APHScoring *)self.graphItem.graphData;
    graphScoring.providesAveragedPointData = sender.selectedSegmentIndex > 1;
    
    [super segmentControlChanged:sender];
}

#pragma mark - IBActions

- (IBAction)correlationSegmentChanged:(UISegmentedControl *)sender {
    
}


@end
