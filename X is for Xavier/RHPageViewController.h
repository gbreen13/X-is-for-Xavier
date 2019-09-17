//
//  RHPageViewController.h
//  X is for Xavier
//
//  Created by George Breen on 1/12/15.
//
// analagous: MyPageViewController.

#import <UIKit/UIKit.h>
#import "RHBookViewControllerData.h"
#import "RHBookViewController.h"
#import "AudioController.h"
#import "MenuViewController.h"



@interface RHPageViewController : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
    UIDeviceOrientation orientation;
}

@property (nonatomic,assign) UIDeviceOrientation orientation;

-(void) flipToPage:(int) x;
-(void) changeOrientation: (UIDeviceOrientation)toInterfaceOrientation;

@end
