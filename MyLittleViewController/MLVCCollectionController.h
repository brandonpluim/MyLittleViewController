//
//  MLVCCollectionController.h
//  MyLittleViewController
//
//  Created by derrick on 10/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>


@protocol MLVCCollectionControllerGroup;

/**
 Manages a grouped and sorted collection of objects.
 
 `MLVCCollectionController` manages a collection of objects via a keypath for grouping the objects, and a set of sort descriptors for ordering the collection. It also provides feedback via the
 */
@interface MLVCCollectionController : NSObject

/**
 @name Creating and configuring `MLVCCollectionController` instances
 */
#pragma mark - Creating and Configuring

/**
 Constructs an `MLVCCollectionController` that will group its objects by the `groupKey
 
 @param groupByBlock The block to group objects by All objects with the same `groupByBlock(object)` will be sorted into the same group.
 @param groupTitleBlock This method will be called to provide the title for a group on one of the group's objects.
 @param sortDescriptors An array of sort descriptors that will be applied to the collection.
 @return configured instance of `MLVCCollectionController`
 */
+ (instancetype)collectionControllerGroupingByBlock:(id (^)(id object))groupByBlock groupTitleBlock:(NSString *(^)(id object))groupTitleBlock sortDescriptors:(NSArray *)sortDescriptors;

/**
 The keypath that is used to group the grouped objects
 */
@property (nonatomic, copy, readonly) id (^groupByBlock)(id object);

/**
 Called on an object for a group to generate the name of the group the object belongs to
 */
@property (nonatomic, copy, readonly) NSString *(^groupTitleBlock)(id object);

/**
 The array of sort descriptors used to sort the items in the group
 */
@property (nonatomic, copy, readonly) NSArray *sortDescriptors;

/**
 @name Reacting
 */

@property (nonatomic, readonly) RACSignal *groupsInsertedIndexSetSignal;

@property (nonatomic, readonly) RACSignal *groupsDeletedIndexSetSignal;

@property (nonatomic, readonly) RACSignal *objectsInsertedIndexPathsSignal;

@property (nonatomic, readonly) RACSignal *objectsDeletedIndexPathsSignal;

/**
 @name Querying
 */
#pragma mark - Querying

/**
 Get the object at a give indexPath.
 
 @param indexPath the indexPath of the given object (supports only section and row)
 @return the object at `indexPath`
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;


/**
 The array of `id<MLVCCollectionControllerGroup>` objects which describe each group
 */
@property (nonatomic, readonly) NSArray *groups;


/**
 Returns the id<MLVCCollectionControllerGroup> at the given subscript
 
 @param groupIndex Index for the group of interest
 */
- (id)objectAtIndexedSubscript:(NSUInteger)groupIndex;



/**
 @name Modifying Content
 */


/**
 Inserts the objects at the proper rows of the proper groups.
 
 If the group doesn't exist a new group will be added to accomodate
 the newly inserted objects.
 
 @param objects a list of objects to be managed by the controller
 */
- (void)insertObjects:(NSArray *)objects;


/**
 Removes object at the given indexPath
 
 @param indexPath the index path of the object to remove.
 */
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

/**
 Removes a list of items from the collection
 
 @param array of NSIndexPath corresponding to the objects to remove
 */
- (void)removeObjectsAtIndexPaths:(NSArray *)indexPaths;


/**
 Remove all objects and groups
 */
- (void)removeAllObjectsAndGroups;


/**
 Remove just the group of objects with the given group id object
 */
- (void)removeGroupWithGroupID:(id)groupID;

@end

/**
 Represents a group of objects inside of an MLVCCollectionController
 
 These objects are maintained by the controller and can be accessed via the `groups` property or using subscripts, i.e. myGroupedCollectionController[group0]
 */
@interface MLVCCollectionControllerGroup : NSObject
@property (nonatomic, readonly) id id;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSArray *objects;

/**
 Subscript access
 */
- (id)objectAtIndexedSubscript:(NSUInteger)itemIndex;
@end
