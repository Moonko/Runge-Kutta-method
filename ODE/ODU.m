//
//  ODU.m
//  ODE
//
//  Created by Андрей Рычков on 20.05.14.
//  Copyright (c) 2014 Andrey Rychkov. All rights reserved.
//

#import "ODU.h"

@implementation ODU

- (id)initWithEps:(double)eps A:(double)a B:(double)b c2:(double)c2 steps:(int)n
{
    if (self = [super init])
    {
        _eps = eps;
        _a = a;
        _b = b;
        _c2 = c2;
        _h = M_PI / n;
        _n = n;
        _x0 = 0;
    }
    
    return self;
}

- (void)solveWithRungeWithOptimal:(BOOL)isOptimal
{
    double e1 = 100; // Error for y1
    double e2 = 100; // Error for y2
    
    [self solveSystem];
    
    double y1h1 = _y1;
    double y1h2;
    
    double y2h1 = _y2;
    double y2h2;
    
    if (!isOptimal)
    {
        while (fabs(e1) > _eps || fabs(e2) > _eps)
        {
            _n *= 2;
            _h = M_PI / _n;
            
            [self solveSystem];
            
            y1h2 = y1h1;
            y1h1 = _y1;
            
            e1 = (y1h1 -y1h2) / 3;
            
            y2h2 = y2h1;
            y2h1 = _y2;
            
            e2 = (y2h1 - y2h2) / 3;
            
            printf("Step: %.12f     y1: %.12f     y2: %.12f\n", _h,_y1,_y2);
            
        }
        printf("Result:\n");
        [self print];
        printf("Error for y1: %.12f\n", e1);
        printf("Error for y2: %.12f\n", e2);
        printf("Steps: %d\n", _n);
    } else
    {
        _n *= 2;
        _h = M_PI / _n;
        
        [self solveSystem];
        
        y1h2 = _y1;
        y2h2 = _y2;
        
        double norm = fabs(sqrt(pow(y1h1 - y1h2, 2) + pow(y2h1 - y2h2, 2)));
        double optH = _h * pow(3.0 * _eps / norm, 1.0 / 2.0);
        
        _h = optH;
        _n = (int)ceil(M_PI / optH);
        _h = M_PI / _n;
        
        [self solveSystem];
        
        y1h2 = _y1;
        y2h2 = _y2;
        
        _n *= 2;
        _h = M_PI / _n;
        
        [self solveSystem];
        
        y2h1 = _y2;
        y1h1 = _y1;
        
        norm = fabs(sqrt(pow(y1h1 - y1h2, 2) + pow(y2h1 - y2h2, 2)));
        
        printf("Result:\n");
        printf("y1 with optH: %.12f\n", _y1);
        printf("y2 with optH: %.12f\n", _y2);
        
        printf("Steps: %d\n", _n);
        
        printf("Error with optH: %.12f\n", norm / 3.0);
        
        e1 = 100;
        e2 = 100;
        
        _n = 2;
        _h = M_PI / _n;
        
        [self solveSystemWithOpponentScheme];
        
        y1h1 = _y1opp;
        y2h1 = _y2opp;
        
        _n *= 2;
        _h = M_PI / _n;
        
        [self solveSystemWithOpponentScheme];
        
        y1h2 = _y1opp;
        y2h2 = _y2opp;
        
        norm = fabs(sqrt(pow(y1h1 - y1h2, 2) + pow(y2h1 - y2h2, 2)));
        optH = _h * pow(15.0 * _eps / norm, 1.0 / 4.0);
        
        _h = optH;
        _n = (int)ceil(M_PI / optH);
        _h = M_PI / _n;
        
        [self solveSystemWithOpponentScheme];
        
        y1h2 = _y1opp;
        y2h2 = _y2opp;
        
        _n *= 2;
        _h = M_PI / _n;
        
        [self solveSystemWithOpponentScheme];
        
        y2h1 = _y2opp;
        y1h1 = _y1opp;
        
        norm = fabs(sqrt(pow(y1h1 - y1h2, 2) + pow(y2h1 - y2h2, 2)));
        
        printf("y1 opp with optH: %.12f\n", _y1);
        printf("y2 opp with optH: %.12f\n", _y2);
        
        printf("Steps: %d\n", _n);
        
        printf("Error with optH opponent: %.12f\n", norm / 15.0);
    }
}

- (void)solveSystem
{
    double b1;
    double b2;
    
    b2 = 1.0 / (2 * _c2);
    b1 = 1 - b2;
    
    _y1 = _a * M_PI;
    _y2 = _b * M_PI;
    
    for (int i = 0; i < _n; ++i)
    {
        NSArray *Y = [NSArray arrayWithObjects:
                      [NSNumber numberWithDouble:_y1],
                      [NSNumber numberWithDouble:_y2],
                      nil];
        double y1k1 = _h * [self f1:Y];
        double y2k1 = _h * [self f2:Y];
        
        NSArray *amb = [NSArray arrayWithObjects:
                      [NSNumber numberWithDouble:[Y[0] doubleValue] + _c2 * y1k1],
                      [NSNumber numberWithDouble:[Y[1] doubleValue] + _c2 * y2k1],
                      nil];
        double y2k2 = _h * [self f2:amb];
        double y1k2 = _h * [self f1:amb];
        
        _y1 = [Y[0] doubleValue] + b1 * y1k1 + b2 * y1k2;
        _y2 = [Y[1] doubleValue] + b1 * y2k1 + b2 * y2k2;
    }
}

- (void)solveSystemWithOpponentScheme
{
    _y1opp = _a * M_PI;
    _y2opp = _b * M_PI;
    
    for (int i = 0; i < _n; ++i)
    {
        NSArray *Y = [NSArray arrayWithObjects:
                      [NSNumber numberWithDouble:_y1opp],
                      [NSNumber numberWithDouble:_y2opp],
                      nil];
        double y1k1 = _h * [self f1:Y];
        double y2k1 = _h * [self f2:Y];
        
        NSArray *amb = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.5 * y1k1],
                        [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.5 * y2k1],
                        nil];
        double y2k2 = _h * [self f2:amb];
        double y1k2 = _h * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.207106781 * y1k1 + 0.292893219 * y1k2],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.207106781 * y2k1 + 0.292893219 * y2k2],
               nil];
        
        double y2k3 = _h * [self f2:amb];
        double y1k3 = _h * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.707106781 * y1k2 + 1.707106781 * y1k3],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.707106781 * y2k2 + 1.707106781 * y2k3],
               nil];
        double y2k4 = _h * [self f2:amb];
        double y1k4 = _h * [self f1:amb];
        
        _y1opp = [Y[0] doubleValue] + (1.0 / 6.0) * (y1k1 + y1k4)
        + (1.0 / 3.0) * (0.292893219 * y1k2 + 1.707106781 * y1k3);
        _y2opp = [Y[1] doubleValue] + (1.0 / 6.0) * (y2k1 + y2k4)
        + (1.0 / 3.0) * (0.292893219 * y2k2 + 1.707106781 * y2k3);
    }
}

- (void)solveWithAutomaticStep
{
    NSMutableArray *Y = [NSMutableArray arrayWithObjects:
                  [NSNumber numberWithDouble:_a * M_PI],
                  [NSNumber numberWithDouble:_b * M_PI],
                  nil];
    int n = 1;
    double b2 = 1.0 / ( 2 * _c2);
    double b1 = 1 - b2;
    
    double ya1, ya2; // Additional
    
    double h = [self calculateFirstH:2.0];
    
    double localError = 0.0;
    
    double e2s = _eps * 4.0;
    double eDiv2s = _eps / 8.0;
    
    while (_x0 < M_PI)
    {
        double y1k1 = h * [self f1:Y];
        double y2k1 = h * [self f2:Y];
        
        NSArray *amb = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:[Y[0] doubleValue] + _c2 * y1k1],
                        [NSNumber numberWithDouble:[Y[1] doubleValue] + _c2 * y2k1],
                        nil];
        double y2k2 = h * [self f2:amb];
        double y1k2 = h * [self f1:amb];
        
        _y1 = [Y[0] doubleValue] + b1 * y1k1 + b2 * y1k2;
        _y2 = [Y[1] doubleValue] + b1 * y2k1 + b2 * y2k2;
        
        y1k1 = h / 2.0 * [self f1:Y];
        y2k1 = h / 2.0 * [self f2:Y];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + _c2 * y1k1],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + _c2 * y2k1],
               nil];
        y2k2 = h / 2.0 * [self f2:amb];
        y1k2 = h / 2.0 * [self f1:amb];
        
        ya1 = [Y[0] doubleValue] + b1 * y1k1 + b2 * y1k2;
        ya2 = [Y[1] doubleValue] + b1 * y2k1 + b2 * y2k2;
        
        localError = fabs(sqrt(pow(_y1 - ya1, 2) + pow(_y2 - ya2, 2))) / 3.0;
        if (localError > e2s)
        {
            h = h / 2.0;
        } else if (localError > _eps && localError <= e2s)
        {
            h = h / 2.0;
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
            }
            _x0 += h;
            Y[0] = [NSNumber numberWithDouble:ya1];
            Y[1] = [NSNumber numberWithDouble:ya2];
        } else if (localError < _eps && localError >= eDiv2s)
        {
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
            }
            Y[0] = [NSNumber numberWithDouble:_y1];
            Y[1] = [NSNumber numberWithDouble:_y2];
            _x0 += h;
        } else if (localError < eDiv2s)
        {
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
                _x0 += h;
            }else
            {
                
                h *= 2.0;
            }
            
            Y[0] = [NSNumber numberWithDouble:_y1];
            Y[1] = [NSNumber numberWithDouble:_y2];
        }
        ++n;
    }
    printf("Result:\n");
    [self print];
    printf("Steps: %d\n", n);
    printf("Local error: %.12f\n", localError);
}

- (void)solveWithAutomaticStepWithOpponent
{
    NSMutableArray *Y = [NSMutableArray arrayWithObjects:
                         [NSNumber numberWithDouble:_a * M_PI],
                         [NSNumber numberWithDouble:_b * M_PI],
                         nil];
    int n = 1;
    double h = [self calculateFirstH:4.0];
    
    double localError = 0.0;
    
    double e2s = _eps * 16.0;
    double eDiv2s = _eps / 32.0;
    
    double ya1, ya2;
    
    BOOL calc = NO;
    
    while (_x0 < M_PI || calc)
    {
        if (calc == YES)
        {
            calc = NO;
        }
        double y1k1 = h * [self f1:Y];
        double y2k1 = h * [self f2:Y];
        
        NSArray *amb = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.5 * y1k1],
                        [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.5 * y2k1],
                        nil];
        double y2k2 = h * [self f2:amb];
        double y1k2 = h * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.207106781 * y1k1 + 0.292893219 * y1k2],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.207106781 * y2k1 + 0.292893219 * y2k2],
               nil];
        
        double y2k3 = h * [self f2:amb];
        double y1k3 = h * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.707106781 * y1k2 + 1.707106781 * y1k3],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.707106781 * y2k2 + 1.707106781 * y2k3],
               nil];
        double y2k4 = h * [self f2:amb];
        double y1k4 = h * [self f1:amb];
        
        _y1opp = [Y[0] doubleValue] + (1.0 / 6.0) * (y1k1 + y1k4)
        + (1.0 / 3.0) * (0.292893219 * y1k2 + 1.707106781 * y1k3);
        _y2opp = [Y[1] doubleValue] + (1.0 / 6.0) * (y2k1 + y2k4)
        + (1.0 / 3.0) * (0.292893219 * y2k2 + 1.707106781 * y2k3);
        
        y1k1 = h / 2.0 * [self f1:Y];
        y2k1 = h / 2.0 * [self f2:Y];
        
        amb = [NSArray arrayWithObjects:
                        [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.5 * y1k1],
                        [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.5 * y2k1],
                        nil];
        y2k2 = h / 2.0 * [self f2:amb];
        y1k2 = h / 2.0 * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.207106781 * y1k1 + 0.292893219 * y1k2],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.207106781 * y2k1 + 0.292893219 * y2k2],
               nil];
        
        y2k3 = h / 2.0 * [self f2:amb];
        y1k3 = h / 2.0 * [self f1:amb];
        
        amb = [NSArray arrayWithObjects:
               [NSNumber numberWithDouble:[Y[0] doubleValue] + 0.707106781 * y1k2 + 1.707106781 * y1k3],
               [NSNumber numberWithDouble:[Y[1] doubleValue] + 0.707106781 * y2k2 + 1.707106781 * y2k3],
               nil];
        y2k4 = h / 2.0 * [self f2:amb];
        y1k4 = h / 2.0 * [self f1:amb];
        
        ya1 = [Y[0] doubleValue] + (1.0 / 6.0) * (y1k1 + y1k4)
        + (1.0 / 3.0) * (0.292893219 * y1k2 + 1.707106781 * y1k3);
        ya2 = [Y[1] doubleValue] + (1.0 / 6.0) * (y2k1 + y2k4)
        + (1.0 / 3.0) * (0.292893219 * y2k2 + 1.707106781 * y2k3);
        
        localError = fabs(sqrt(pow(_y1opp - ya1, 2) + pow(_y2opp - ya2, 2))) / 15.0;
        if (localError > e2s)
        {
            h = h / 2.0;
        } else if (localError > _eps && localError <= e2s)
        {
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
            }
            h = h / 2.0;
            _x0 += h;
            Y[0] = [NSNumber numberWithDouble:ya1];
            Y[1] = [NSNumber numberWithDouble:ya2];
        } else if (localError < _eps && localError >= eDiv2s)
        {
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
            }
            Y[0] = [NSNumber numberWithDouble:_y1opp];
            Y[1] = [NSNumber numberWithDouble:_y2opp];
            _x0 += h;
        } else if (localError < eDiv2s)
        {
            if (_x0 + h > M_PI)
            {
                h = M_PI - _x0;
                _x0 += h;
            }else
            {
                
                h *= 2.0;
            }
            Y[0] = [NSNumber numberWithDouble:_y1opp];
            Y[1] = [NSNumber numberWithDouble:_y2opp];
        }
        ++n;
    }
    printf("Result opp:\n");
    [self printOpp];
    printf("Steps: %d\n", n);
    printf("Local error: %.12f\n", localError);
}

- (double)calculateFirstH:(double)s
{
    NSArray *Y = [NSArray arrayWithObjects:
                  [NSNumber numberWithDouble:_a * M_PI],
                  [NSNumber numberWithDouble:_b * M_PI],
                  nil];
    NSArray *F = [NSArray arrayWithObjects:
                  [NSNumber numberWithDouble:[self f1:Y]],
                  [NSNumber numberWithDouble:[self f2:Y]],
                  nil];
    double norm = fabs([F[0] doubleValue] - [F[1] doubleValue]);
    
    double delta = pow(1.0 / M_PI, s + 1) + pow(norm, s + 1);
    return pow(_eps / delta, 1.0 / (s + 1));
}

- (double)f1:(NSArray *)y
{
    return _a * [y[1] doubleValue];
}

- (double)f2:(NSArray *)y
{
    return -_b * [y[0] doubleValue];
}

- (void)print
{
    printf("y1: %.12f\n", _y1);
    printf("y2: %.12f\n", _y2);
}

- (void)printOpp
{
    printf("y1 opp: %.12f\n", _y1opp);
    printf("y2 opp: %.12f\n", _y2opp);
}

@end
