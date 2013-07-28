//
//  ViewController.h
//  WebBrowser
//
//  Created by Hiromasa Suzuki on 13/07/28.
//  Copyright (c) 2013年 Hiromasa Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FavoritesViewController.h"

@interface ViewController : UIViewController<UIWebViewDelegate, UITextFieldDelegate,FavoritesViewControllerDelegate>

@end
