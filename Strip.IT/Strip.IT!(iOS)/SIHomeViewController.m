//
//
//      _|          _|_|_|
//      _|        _|
//      _|        _|
//      _|        _|
//      _|_|_|_|    _|_|_|
//
//
//  Copyright (c) 2014-2015, Licheng Guo. ( http://titm.me )
//  http://github.com/titman
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "SIHomeViewController.h"
#import "SIRequest.h"
#import "SIHTMLParser.h"
#import "SIHomeCell.h"
#import "SIVideoModel.h"
#import "SIVideoPlayerViewController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD+SIHUD.h"

#define SI_FIRST_PAGE YES
#define SI_MORE_PAGE  NO


@interface SIHomeViewController() <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@property(nonatomic, assign) NSInteger page;
@property(nonatomic, strong) NSMutableArray * datasource;
@property(nonatomic, strong) NSString * embedURL;
@property(nonatomic, strong) NSString * embedTitle;

@property(nonatomic, strong) IBOutlet UITableView * tableView;

@property(nonatomic, strong) MBProgressHUD * hud;

@property(nonatomic, strong) SIRequest * request;
@end

@implementation SIHomeViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //
    self.navigationItem.hidesBackButton = YES;

    self.tableView.rowHeight = 200;

    [self loadData:SI_FIRST_PAGE];
}

-(void) loadData:(BOOL)firstPageOrMorePage
{
    [self hideHUD];
    
    self.hud = [MBProgressHUD showLoadingHud:@""];
    
    self.request = [SIRequest requestWithType:SIRequestTypeHomepage parameter:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        if (firstPageOrMorePage) {
            
            self.datasource = [SIHTMLParser parsingWithObject:responseObject];
            
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
        
        [self hideHUD];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [self hideHUD];

        [MBProgressHUD showMessageHud:error.description];
    }];
}

-(void) hideHUD
{
    if (self.hud) {
        [self.hud hideAnimated:YES];
        self.hud = nil;
    }
}

#pragma mark - TableView

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return UIView.new;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return UIView.new;
}


-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.5;
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SIHomeCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SIHomeCell" owner:nil options:nil] firstObject];
    }
    
    
    SIVideoModel * videoModel = self.datasource[indexPath.row];
    
    cell.videoModel = videoModel;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SIVideoModel * videoModel = self.datasource[indexPath.row];

    //
    MBProgressHUD * hud = [MBProgressHUD showLoadingHud:@""];
    
    self.request = [SIRequest requestWithType:SIRequestTypeDetailPage parameter:videoModel.detailPageURLString success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hideAnimated:YES];
        
        self.embedURL = [SIHTMLParser parsingEmbedURLWithObject:responseObject];
        self.embedTitle = videoModel.title;
        
        [self performSegueWithIdentifier:@"SIVideoPlayer" sender:self];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
       
        [hud hideAnimated:YES];
        [MBProgressHUD showMessageHud:error.description];
        
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender
{
    SIVideoPlayerViewController * player =  segue.destinationViewController;
    
    player.embedURL = self.embedURL;
    player.titleString = self.embedTitle;
}

-(IBAction) githubAction:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/titman"]];
}

-(IBAction) helpAction:(id)sender
{

}

-(IBAction) refreshAction:(id)sender
{
    [self loadData:YES];
}

@end
