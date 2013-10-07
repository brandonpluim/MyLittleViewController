//
//  MLVCTableViewController.m
//  MyLittleViewController
//
//  Created by derrick on 10/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "MLVCTableViewController.h"
#import "MLVCCollectionController.h"
#import "MLVCTableViewCellAdapter.h"

@interface MLVCTableViewController () <MLVCCollectionControllerDelegate>
@end

@implementation MLVCTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)setViewModel:(id<MLVCCollectionViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    _viewModel.collectionController.delegate = self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.viewModel.collectionController.groups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return [group.objects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellAdapter> cellAdapter = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    return [cellAdapter cellForTableViewController:self forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCTableViewCellAdapter> cellAdapter = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    [cellAdapter cellSelectedInTableViewController:self atIndexPath:indexPath];
}

#pragma mark - MLVCCollectionControllerDelegate

- (void)controllerWillChangeContent:(MLVCCollectionController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(MLVCCollectionController *)controller didInsertGroup:(MLVCCollectionControllerGroup *)group atIndex:(NSUInteger)index
{
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)controller:(MLVCCollectionController *)controller didInsertObject:(id)object atIndexPath:(NSIndexPath *)path
{
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)controllerDidChangeContent:(MLVCCollectionController *)controller
{
    [self.tableView endUpdates];
}

@end