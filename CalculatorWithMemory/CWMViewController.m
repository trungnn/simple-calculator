//
//  CWMViewController.m
//  CalculatorWithMemory
//
//  Created by Nguyen Ngoc Trung on 26/4/13.
//  Copyright (c) 2013 Trung. All rights reserved.
//

#import "CWMViewController.h"

@interface CWMViewController () <UITableViewDataSource, UITableViewDelegate>

typedef enum {kAddition, kSubtraction, kMultiplication, kDivision, kNothing} operandType;

@property NSMutableArray *historyArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (nonatomic, strong) NSString *calculationMemoryString;
@property (nonatomic, assign) double holdingValue;
@property (nonatomic, assign) operandType currentOperand;
@property (nonatomic, assign) BOOL shouldRegisterNewValue;

@end

@implementation CWMViewController

# pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.currentOperand = kNothing;
    self.holdingValue = 0;
    self.shouldRegisterNewValue = YES;
    self.historyArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.8];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setDisplayLabel:nil];
    [super viewDidUnload];
}

#pragma mark - Actions

- (NSString *)getStringForOperandType:(operandType)type {
    switch (type) {
        case kAddition:
            return @"+";
        case kSubtraction:
            return @"-";
        case kMultiplication:
            return @"*";
        case kDivision:
            return @"/";
        default:
            return @"";
    }
}

- (void)performCalculation {
    double value = [self.displayLabel.text doubleValue];
    self.calculationMemoryString = [self.calculationMemoryString stringByAppendingFormat:@" %@ %@", [self getStringForOperandType:self.currentOperand], self.displayLabel.text];
    switch (self.currentOperand) {
        case kAddition:
            self.holdingValue = self.holdingValue + value;
            break;
        case kSubtraction:
            self.holdingValue = self.holdingValue - value;
            break;
        case kMultiplication:
            self.holdingValue = self.holdingValue * value;
            
            break;
        case kDivision:
            self.holdingValue = self.holdingValue / value;
            break;
        default:
            break;
    }
    self.displayLabel.text = [NSString stringWithFormat:@"%g", self.holdingValue];
    self.currentOperand = kNothing;
}

- (IBAction)operandPressed:(id)sender {
    self.shouldRegisterNewValue = YES;
    if (self.currentOperand != kNothing) {
        [self performCalculation];
    } else {
        self.holdingValue = [self.displayLabel.text doubleValue];
        self.calculationMemoryString = self.displayLabel.text;
    }
    
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"+"]) {
        self.currentOperand = kAddition;
    } else if ([button.titleLabel.text isEqualToString:@"-"]) {
        self.currentOperand = kSubtraction;
    } else if ([button.titleLabel.text isEqualToString:@"*"]) {
        self.currentOperand = kMultiplication;
    } else if ([button.titleLabel.text isEqualToString:@"/"]) {
        self.currentOperand = kDivision;
    } else {
        self.currentOperand = kNothing;
    }
}

- (IBAction)numberClicked:(id)sender {
    UIButton *numberButton = (UIButton *)sender;
    
    if (self.shouldRegisterNewValue) {
        if (![numberButton.titleLabel.text isEqualToString:@"0"]) {
            self.displayLabel.text = numberButton.titleLabel.text;
            self.shouldRegisterNewValue = NO;
        }
    } else {
        self.displayLabel.text = [self.displayLabel.text stringByAppendingString:numberButton.titleLabel.text];
    }
}

- (IBAction)equalSignPressed:(id)sender {
    if (self.currentOperand != kNothing) {
        self.shouldRegisterNewValue = YES;
        [self performCalculation];
        self.currentOperand = kNothing;
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.displayLabel.text, @"result", self.calculationMemoryString, @"calculation", nil];
        [self.historyArray addObject:dictionary];
        [self.tableView reloadData];
    }
}

- (IBAction)clearDisplayClicked:(id)sender {
    self.displayLabel.text = @"0";
    self.shouldRegisterNewValue = YES;
}

- (IBAction)clearMemoryClicked:(id)sender {
    self.historyArray = [NSMutableArray array];
    [self.tableView reloadData];
}


# pragma mark - UITableView Datasource and Delegate
- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CWMCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    NSDictionary *dict = [self.historyArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"result"];
    cell.detailTextLabel.text = [dict objectForKey:@"calculation"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
