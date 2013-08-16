//
//  ViewController.m
//  CorePlotExample
//
//  Created by bit-ware on 2013/08/16.
//  Copyright (c) 2013年 bit-ware. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    CPTXYGraph * _graph;
    NSMutableArray * _dataForPlot;
}
@property (retain, nonatomic) IBOutlet CPTGraphHostingView *hostingView;

@end

#define GREEN_PLOT_IDENTIFIER @"Green Plot"
#define BLUE_PLOT_IDENTIFIER @"Blue Plot"
@implementation ViewController
@synthesize hostingView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCoreplotViews];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void)setupCoreplotViews
{
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    
    //用主题来初始化graph，graph做plot的容器
    _graph = [[CPTXYGraph alloc] initWithFrame:CGRectZero];
    CPTTheme * theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [_graph applyTheme:theme];
    hostingView.hostedGraph = _graph;
    
    //设置graph相对于hostView边框的offset
    _graph.paddingLeft = 0;
	_graph.paddingTop = 0;
	_graph.paddingRight = 0;
	_graph.paddingBottom = 0;
    
    //设置plot相对于graph边框的offset
    _graph.plotAreaFrame.paddingLeft = 60.0f;
    _graph.plotAreaFrame.paddingTop = 50.0f ;
    _graph.plotAreaFrame.paddingRight = 50.0f ;
    _graph.plotAreaFrame.paddingBottom = 50.0f ;
    
    //设置title text的字体
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor cyanColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
    
	//设置plot的标题
	NSString *title = @"返済期間に応じた月々返済額";
	_graph.title = title;
	_graph.titleTextStyle = titleStyle;
	_graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	_graph.titleDisplacement = CGPointMake(70, -25.0f);
    
    // 设置一屏内可显示的x,y量度范围
    // 设置不能拖动plot
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.delegate = self;
    plotSpace.allowsUserInteraction = NO;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(36)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(5000.0)];
    
    
    // 取得两个坐标轴的handler
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_graph.axisSet;
    
    // 为坐标轴设置主题，网格线，颜色，线条粗细等
    [self applyThemeToAxisSet:axisSet];
    
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 2.0;
    lineStyle.lineColor = [CPTColor whiteColor];
    
    // 1 - Configure styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blackColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
    
    
    CPTXYAxis * x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // 原点的 x 位置
    x.majorIntervalLength = CPTDecimalFromString(@"6"); // x轴主刻度：显示数字标签的量度间隔
    x.minorTicksPerInterval = 1; // x轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    x.minorTickLineStyle = lineStyle; //设置刻度线条格式
    x.majorTickLineStyle = lineStyle;
    x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(36)];
    x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0.0)
                                                    length:CPTDecimalFromInteger(5000)];
    x.title = @"返済期間（年）";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 30.0;
    x.titleLocation = CPTDecimalFromFloat ( 36.0f );
    
    CPTXYAxis * y = axisSet.yAxis;
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0"); // 原点的 y 位置
    y.majorIntervalLength = CPTDecimalFromString(@"1000"); // y轴主刻度：显示数字标签的量度间隔
    y.minorTicksPerInterval = 1; // y轴细分刻度：每一个主刻度范围内显示细分刻度的个数
    y.minorTickLineStyle = lineStyle;
    y.majorTickLineStyle = lineStyle;
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0) length:CPTDecimalFromFloat(5000)];
    y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0.0)
                                                    length:CPTDecimalFromInteger(36)];
    
	y.title = @"月々の返済金額（万円）";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -10;
    y.titleLocation = CPTDecimalFromFloat ( 5100.0f );
    y.titleRotation =  -M_1_PI + 0.3;
    
    y.delegate = self;
    
    // 创建一个scatter plot
    lineStyle.miterLimit = 1.0f;
    lineStyle.lineWidth = 3.0f;
    lineStyle.lineColor = [CPTColor cyanColor];
    
    CPTScatterPlot * boundLinePlot = [[CPTScatterPlot alloc] init];
    boundLinePlot.dataLineStyle = lineStyle;
    boundLinePlot.identifier = BLUE_PLOT_IDENTIFIER;
    boundLinePlot.dataSource = self;
    boundLinePlot.delegate = self;
    
    // 设置拐点的样式
    CPTMutableLineStyle * symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [CPTColor cyanColor];
    symbolLineStyle.lineWidth = 2.0;
    
    CPTPlotSymbol * plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor cyanColor]];
    plotSymbol.lineStyle = symbolLineStyle;
    plotSymbol.size = CGSizeMake(10.0, 10.0);
    boundLinePlot.plotSymbol = plotSymbol;
    boundLinePlot.delegate = self;
    boundLinePlot.dataSource = self;
    [_graph addPlot:boundLinePlot];
    
    // Add some initial data
    //
    _dataForPlot = [[NSMutableArray arrayWithCapacity:100] retain];
    NSUInteger i;
    for ( i = 0; i < 7; i++ ) {
        id x = [NSNumber numberWithFloat:i * 6];
        id y = [NSNumber numberWithFloat:5000 - i * 700];
        [_dataForPlot addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:x, @"x", y, @"y", nil]];
    }
    [self.view addSubview:hostingView];
}

// 在 Y 轴上添加平行线

-( void )applyThemeToAxisSet:(CPTXYAxisSet *)axisSet {
    
    // 设置网格线线型
    CPTMutableLineStyle *majorGridLineStyle = [ CPTMutableLineStyle lineStyle ];
    majorGridLineStyle.lineWidth = 0.5f ;
    majorGridLineStyle.lineColor = [CPTColor grayColor];
    
    CPTMutableLineStyle *dashGridLineStyle = [ CPTMutableLineStyle lineStyle ];
    dashGridLineStyle.lineWidth = 0.5f ;
    dashGridLineStyle.lineColor = [CPTColor grayColor];
    dashGridLineStyle.dashPattern = [NSArray arrayWithObjects: [NSNumber numberWithFloat:5.0f], [NSNumber numberWithFloat:5.0f], nil];
    
    CPTXYAxis *axis=axisSet.yAxis ;
    axis.tickDirection = CPTSignNegative;
    // 设置平行线，默认是以大刻度线为平行线位置
    axis.minorGridLineStyle = dashGridLineStyle;
    axis.majorGridLineStyle = majorGridLineStyle ;
    
    axis = axisSet.xAxis ;
    axis.tickDirection = CPTSignNegative ;
    // 设置平行线，默认是以大刻度线为平行线位置
    axis.minorGridLineStyle = dashGridLineStyle;
    axis.majorGridLineStyle = majorGridLineStyle;
}

-(void)changePlotRange
{
    // Change plot space
    CPTXYPlotSpace * plotSpace = (CPTXYPlotSpace *)_graph.defaultPlotSpace;
    plotSpace.xRange = [self CPTPlotRangeFromFloat:0.0 length:(3.0 + 2.0 * rand() / RAND_MAX)];
    plotSpace.yRange = [self CPTPlotRangeFromFloat:0.0 length:(3.0 + 2.0 * rand() / RAND_MAX)];
}

-(CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length
{
    return [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(location) length:CPTDecimalFromFloat(length)];
}
#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [_dataForPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString * key = (fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y");
    NSNumber * num = [[_dataForPlot objectAtIndex:index] valueForKey:key];
    
    // Green plot gets shifted above the blue
    if ([(NSString *)plot.identifier isEqualToString:GREEN_PLOT_IDENTIFIER]) {
        if (fieldEnum == CPTScatterPlotFieldY) {
            num = [NSNumber numberWithDouble:[num doubleValue] + 1.0];
        }
    }
    
    return num;
}
#pragma mark - CPTScatterPlotDelegate methods
-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index{
    
    // 移除plot view 上的所有subview
    for (UIView *view in self.hostingView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            
            __block UIView * bview = view;
            [UIView animateWithDuration:0.3 animations:^{
                bview.alpha = 0.0;
            } completion:^(BOOL finished) {
                [bview removeFromSuperview];
            }];
        }
    }
    
    // 获取拐点在 plotspace中的坐标
	NSNumber *anchorX = [[_dataForPlot objectAtIndex:index] valueForKey:@"x"];
	NSNumber *anchorY = [[_dataForPlot objectAtIndex:index] valueForKey:@"y"];
    
    // 获取拐点在 plot view中的绘图坐标，以plot 的左下点为原点
    CPTGraph *graph = plot.graph;
    double doublePrecisionPlotPoint[2];//[x,y]
    doublePrecisionPlotPoint[0] = anchorX.doubleValue;
    doublePrecisionPlotPoint[1] = anchorY.doubleValue;
    CGPoint touchedPoint = [graph.defaultPlotSpace plotAreaViewPointForDoublePrecisionPlotPoint:doublePrecisionPlotPoint];
    
    // 加上 padding offset
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake( touchedPoint.x + 60 - 203 / 2, touchedPoint.y + 60, 203, 106)];
    image.image = [UIImage imageNamed:@"popbg"];
    
    // 由于plot的坐标系和 view的坐标系原点不同
    // 做旋转
    image.transform = CGAffineTransformMakeScale(1, -1);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 203, 30)];
    [label setBackgroundColor:[UIColor clearColor]];
    [image addSubview:label];
    [label release];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 203, 30)];
    label2.text = @"50年";
    [label2 setBackgroundColor:[UIColor clearColor]];
    [image addSubview:label2];
    [label2 release];
    image.alpha = 0.0;
    [self.hostingView addSubview:image];
    [UIView animateWithDuration:0.3 animations:^{
        image.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}


- (BOOL)plotSpace:(CPTXYPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point{
    for (UIView *view in self.hostingView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            
            __block UIView * bview = view;
            [UIView animateWithDuration:0.3 animations:^{
                bview.alpha = 0.0;
            } completion:^(BOOL finished) {
                [bview removeFromSuperview];
            }];
        }
    }
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [hostingView release];
    [super dealloc];
}
@end
