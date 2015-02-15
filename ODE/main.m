//
//  main.m
//  ODE
//
//  Created by Андрей Рычков on 20.05.14.
//  Copyright (c) 2014 Andrey Rychkov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ODU.h"

int main(int argc, const char * argv[])
{

    @autoreleasepool
    {
        double eps = 1e-4;
        double A = 2.0 / 15.0;
        double B = 3.0 / 14.0;
        double c2 = 2.0 / 9.0;
        
        int steps = 2;
        
        ODU *odu = [[ODU alloc] initWithEps:eps A:A B:B c2:c2 steps:steps];
        
        printf("\nRK-method\n\n");
        [odu solveWithRungeWithOptimal:NO];
        
        printf("\nOptimal\n\n");
        odu = [[ODU alloc] initWithEps:eps A:A B:B c2:c2 steps:steps];
        
        [odu solveWithRungeWithOptimal:YES];
        
        printf("\nAutomatic\n\n");
        odu = [[ODU alloc] initWithEps:eps A:A B:B c2:c2 steps:steps];
        
        [odu solveWithAutomaticStep];
        
        printf("\nAutomatic opponent\n\n");
        odu = [[ODU alloc] initWithEps:eps A:A B:B c2:c2 steps:steps];
        
        [odu solveWithAutomaticStepWithOpponent];
    }
    return 0;
}

