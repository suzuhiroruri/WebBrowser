//
//  ViewController.m
//  WebBrowser
//
//  Created by Hiromasa Suzuki on 13/07/28.
//  Copyright (c) 2013年 Hiromasa Suzuki. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController{
    
    //Web View
    IBOutlet UIWebView *webView;
    //URLの入力フィールド
    IBOutlet UITextField *urlField;
    
    //表示中のページの名前とURL
    NSString *pageTitle;
    NSString *url;
    
    //SQLiteデータベースの名前とパス
    NSString *databaseName;
    NSString *databasePath;
    
    //正常にロード完了したかどうかを記録
    bool loadSuccessful;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //webViewとtextFieldからのdelegate通知をこのクラスで受け取る
    webView.delegate = self;
    urlField.delegate = self;
    
    //データベースのファイルパスを取得
    databaseName = @"favorites.sqlite";
    NSArray *documentPaths =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir
                    stringByAppendingPathComponent:databaseName];
    
    //サンドボックス内の「Documents」にDBがあるかを確認、無ければコピー
    [self createAndCheckDatabase];
    //初期URLを設定
    url = @"http://www.google.co.jp";
    //初期URLのページを要求・表示
    [self makeRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//データベースがサンドボックス内の「Documents」フォルダにあるか確認
//無ければ、プロジェクトフォルダからコピー
-(void) createAndCheckDatabase {
    
    BOOL success;
    
    //databasePathに目的のファイルがあるか無いかを審査
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    //もしあれば、処理中断
    if(success) return;
    
    //ない場合は、プロジェクトフォルダからサンドボックスへコピー
    NSString *databasePathFromApp =
    [[[NSBundle mainBundle] resourcePath]
     stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp
                         toPath:databasePath error:nil];
    
}


//ページを要求・表示
-(void)makeRequest {
    //Web Viewでウェブページを呼び出す
    NSURLRequest *urlReq =
    [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"%@", [NSURL URLWithString:url]);
    [webView loadRequest:urlReq];
    
    //処理が完了するまでloadSuccessfulをfalseに
    loadSuccessful = false;
    
    //Activity Indicator発動
    [UIApplication
     sharedApplication].networkActivityIndicatorVisible = YES;
}


//webロードが正常に完了
- (void)webViewDidFinishLoad:(UIWebView *)view {
    
    //ロードしたページの名前とURLを取得
    url = [[webView.request URL] absoluteString];
    pageTitle = [webView stringByEvaluatingJavaScriptFromString:
                 @"document.title"];
    //現在のURLをアドレスバーに反映
    urlField.text = url;
    
    //ステータスバーのActivity Indicatorを停止
    [UIApplication
     sharedApplication].networkActivityIndicatorVisible = NO;
    
    //処理が完了したのでloadSuccessfulをtureに
    loadSuccessful = true;
}


// Web Viewロード中にエラーが生じた場合
- (void)webView:(UIWebView*)webView
didFailLoadWithError:(NSError*)error {
    //ステータスバーのActivity Indicatorを停止
    [UIApplication
     sharedApplication].networkActivityIndicatorVisible = NO;
    
    if(([[error domain]isEqual:NSURLErrorDomain]) &&
       ([error code]!=NSURLErrorCancelled)) {
        //メッセージを表示
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"エラー";
        alert.message = [NSString stringWithFormat:
                         @"「%@」をロードするのに失敗しました。", url];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}


// UITextFieldのキーボード上の「Return」ボタンが押された時に呼ばれる処理
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    //キーボードの入力値を取得
    NSString *keyboardInput = sender.text;
    //「http://」で始まるかを確認、もし始まらない場合は追加
    if (![keyboardInput hasPrefix:@"http://"]) {
        NSString *prefix = @"http://";
        url = [prefix stringByAppendingString:keyboardInput];
        sender.text = url;
    } else {
        url = keyboardInput;
    }
    
    // キーボードを閉じる
    [sender resignFirstResponder];
    
    //指定されたページをロード
    [self makeRequest];
    
    return TRUE;
}
//お気に入り追加ボタンが押され時の処理
-(IBAction)saveFavorite:(id)sender {
    //新しいページをロード中はお気に入り登録を禁止
    if (loadSuccessful == false) {
        //エラーメッセージを表示
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"エラー";
        alert.message = @"正常にロードされていません";
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        
        return;
    }
    //Databaseを開く
    FMDatabase* db = [FMDatabase databaseWithPath:databasePath];
    [db open];
    //クエリ文を指定
    NSString *query = [NSString stringWithFormat:
                       @"INSERT INTO my_favorites (title, url) VALUES ('%@','%@');",
                       pageTitle, url];
    //クエリ開始
    [db beginTransaction];
    //クエリ実行
    [db executeUpdate:query];
    //Databaseへの変更確定
    [db commit];
    //Databaseを閉じる
    [db close];
    
    //メッセージを表示
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お気に入り登録完了";
    alert.message = [NSString stringWithFormat:
                     @"「%@」を登録しました", pageTitle];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}


-(IBAction)goToFavorites:(id)sender {
    //お気に入り画面へのSegueを始動
    [self performSegueWithIdentifier:
     @"toFavoritesView" sender:self];
}

//お気に入り画面へのSegueの発動
- (void)prepareForSegue:
(UIStoryboardSegue *)segue sender:(id)sender{
    
    //FavoritesViewController（FVC）のインスタンスを作成し、
    //delegate通知をこのクラスで受けれるようにする
    if ([[segue identifier] isEqualToString:@"toFavoritesView"]) {
        FavoritesViewController *fvc = (FavoritesViewController*)
        [segue destinationViewController];
        fvc.delegate = (id)self;
    }
}

//Favoritesのリストで「戻る」が押された
- (void)favoritesViewControllerDidCancel:
(FavoritesViewController *)controller {
    //Favorites View Controllerを閉じる
	[self dismissViewControllerAnimated:YES completion:nil];
}
//Favoritesのリストで何かが選択された時に呼ばれる
- (void)favoritesViewControllerDidSelect:
(FavoritesViewController *)controller
                                 withUrl:(NSString *)favoriteUrl {
    //セレクトされたURLをロード
    url = favoriteUrl;
    [self makeRequest];
    //Favorites View Controllerを閉じる
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
