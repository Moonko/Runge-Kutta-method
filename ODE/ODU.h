//
//  ODU.h
//  ODE
//
//  Created by Андрей Рычков on 20.05.14.
//  Copyright (c) 2014 Andrey Rychkov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ODU : NSObject

@property (nonatomic) double eps;
@property (nonatomic) double a;
@property (nonatomic) double b;
@property (nonatomic) double c2;
@property (nonatomic) double h;
@property (nonatomic) int n;

@property (nonatomic) double y1;
@property (nonatomic) double y2;
@property (nonatomic) double y1opp;
@property (nonatomic) double y2opp;
@property (nonatomic) double x0;

- (id)initWithEps:(double)eps A:(double)a B:(double)b c2:(double)c2 steps:(int)n;

- (void)solveWithRungeWithOptimal:(BOOL)isOptimal;
- (void)solveWithAutomaticStep;
- (void)solveWithAutomaticStepWithOpponent;

- (void)solveSystem;
- (void)solveSystemWithOpponentScheme;

@end
