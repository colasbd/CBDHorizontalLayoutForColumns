//
//  CBDHorizontalLayoutForColumns.h
//  TEST_HORIZONTAL_COLLECTION_VIEW
//
//  Created by Colas on 04/02/2015.
//  Copyright (c) 2015 Colas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CBDHorizontalLayoutForColumnsDelegate ;

@interface CBDHorizontalLayoutForColumns : UICollectionViewLayout

/*
 Parameters
 */
@property (nonatomic, assign, readwrite) UIEdgeInsets insets ;
@property (nonatomic, assign, readwrite) CGFloat heightCells ;
@property (nonatomic, assign, readwrite) CGFloat interLinesSpace ;
@property (nonatomic, assign, readwrite) CGFloat interItemsSpace ;


/*
 Delegate
 */
@property (nonatomic, weak, readwrite) id <CBDHorizontalLayoutForColumnsDelegate> delegate ;


@end



@protocol CBDHorizontalLayoutForColumnsDelegate <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(CBDHorizontalLayoutForColumns *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath ;

@end