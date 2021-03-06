//
//  MLVCTableViewController.m
//  MyLittleViewController
//
//  Created by derrick on 10/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "MLVCTableViewController.h"
#import "MLVCCollectionController.h"
#import "MLVCTableViewCellViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface MLVCTableViewController ()
@property (nonatomic) RACDisposable *groupInserted, *groupDeleted, *objectInserted, *objectDeleted;
@end

@implementation MLVCTableViewController {
    RACSubject *_selectedCellViewModelSubject;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [self.viewModel viewControllerViewDidLoad:self];
    }
    
    if ([self.viewModel respondsToSelector:@selector(tableViewControllerViewDidLoad:)]) {
        [self.viewModel tableViewControllerViewDidLoad:self];
    }

    [_selectedCellViewModelSubject sendNext:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillAppear:)]) {
        [self.viewModel viewController:self viewWillAppear:animated];
    }
    
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        RACSignal *refreshSignal = [self.viewModel refreshViewModelSignalForced:NO];
        [self.refreshControl beginRefreshing];
        [self.tableView scrollRectToVisible:self.refreshControl.frame animated:NO];
        [refreshSignal subscribeCompleted:^{
            [self.refreshControl endRefreshing];
        }];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if ([self.viewModel respondsToSelector:@selector(allowsMultipleSelectionDuringEditing)] && self.viewModel.allowsMultipleSelectionDuringEditing) {
        self.tableView.allowsMultipleSelectionDuringEditing = editing;
    }
    [super setEditing:editing animated:animated];
}

- (void)refreshFromRefreshControl:(UIRefreshControl *)refreshControl
{
    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        [[self.viewModel refreshViewModelSignalForced:YES] subscribeCompleted:^{
            [refreshControl endRefreshing];
        }];
    }
}

- (void)endObservingCollectionChanges
{
    [self.groupInserted dispose];
    self.groupInserted = nil;
    
    [self.groupDeleted dispose];
    self.groupDeleted = nil;
    
    [self.objectInserted dispose];
    self.objectInserted = nil;
    
    [self.objectDeleted dispose];
    self.objectDeleted = nil;
}

- (void)beginObservingCollectionChanges
{
    __weak MLVCTableViewController *weakSelf = self;
    
    self.groupInserted = [self.viewModel.collectionController.groupsInsertedIndexSetSignal subscribeNext:^(id x) {
        [weakSelf.tableView insertSections:x withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    self.groupDeleted = [self.viewModel.collectionController.groupsDeletedIndexSetSignal subscribeNext:^(id x) {
        [weakSelf.tableView deleteSections:x withRowAnimation:UITableViewRowAnimationFade];
    }];
    
    self.objectInserted = [self.viewModel.collectionController.objectsInsertedIndexPathsSignal subscribeNext:^(id x) {
        [weakSelf.tableView insertRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    self.objectDeleted = [self.viewModel.collectionController.objectsDeletedIndexPathsSignal subscribeNext:^(id x) {
        [weakSelf.tableView deleteRowsAtIndexPaths:x withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}

- (void)setViewModel:(id<MLVCTableViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    [self endObservingCollectionChanges];
    
    _viewModel = viewModel;
    if (self.isViewLoaded) {
        if ([_viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
            [_viewModel viewControllerViewDidLoad:self];
        }
        if ([_viewModel respondsToSelector:@selector(tableViewControllerViewDidLoad:)]) {
            [_viewModel tableViewControllerViewDidLoad:self];
        }
        [self.tableView reloadData];
    }
    
    [self beginObservingCollectionChanges];
    
    if ([_viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshFromRefreshControl:) forControlEvents:UIControlEventValueChanged];
    } else {
        self.refreshControl = nil;
    }
}

#pragma mark - selection

- (RACSignal *)selectedCellViewModelSignal
{
    return _selectedCellViewModelSubject ?: (_selectedCellViewModelSubject = [RACSubject subject]);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel.collectionController.groups count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return group.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return [group.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    return [cellViewModel tableViewController:self cellForRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:didSelectRowAtIndexPath:)]) {
        [cellViewModel tableViewController:self didSelectRowAtIndexPath:indexPath];
    }
    [_selectedCellViewModelSubject sendNext:cellViewModel];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedCellViewModelSubject sendNext:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:heightForRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self heightForRowAtIndexPath:indexPath];
    }
    return tableView.rowHeight;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:canEditRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self canEditRowAtIndexPath:indexPath];
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:commitEditingStyle:forRowAtIndexPath:)]) {
        [cellViewModel tableViewController:self commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellViewModel> cellViewModel = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    if ([cellViewModel respondsToSelector:@selector(tableViewController:titleForDeleteConfirmationButtonForRowAtIndexPath:)]) {
        return [cellViewModel tableViewController:self titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
    }
    return NSLocalizedString(@"Delete", @"Default delete button MLVC");
}

@end
