//
//  CBDHorizontalLayoutForColumns.m
//  TEST_HORIZONTAL_COLLECTION_VIEW
//
//  Created by Colas on 04/02/2015.
//  Copyright (c) 2015 Colas. All rights reserved.
//

#import "CBDHorizontalLayoutForColumns.h"





/*
 Pods
 */

#import <NSNumber+CBDCGFloatValue.h>



/**************************************/
/**************************************/

// INSPIRÉ PAR LA CLASSE : CBDTableViewLayout

/**************************************/
/**************************************/






/**************************************/
#pragma mark - Constants
/**************************************/

static CGFloat const kDefaultTopInset = 10.0f;
static CGFloat const kDefaultBottomInset = 10.0f ;
static CGFloat const kDefaultLeftInset = 10.0f ;
static CGFloat const kDefaultRightInset = 10.0f ;

static CGFloat const kDefaultInterItemsSpace = 10.0f ;
static CGFloat const kDefaultInterLinesSpace = 10.0f ;






/**************************************/
#pragma mark - Private interface
/**************************************/

@interface CBDHorizontalLayoutForColumns ()

/*
 Convenience properties
 */
@property (nonatomic, assign, readwrite) NSUInteger numberOfLines ;


/*
 Components
 */
@property (nonatomic, strong, readwrite) NSMutableDictionary * mutableLayoutInfos ;
@property (nonatomic, assign, readwrite) CGSize collectionViewContentSize ;
@property (nonatomic, strong, readwrite) NSMutableDictionary * finalAbscissas ;

CBD_DELETE_THIS_LINE
///*
// Convenient properties
// */
//@property (nonatomic, weak, readonly) id <CBDHorizontalLayoutForColumnsDelegate> delegate ;

@end





















@implementation CBDHorizontalLayoutForColumns


//
//
/**************************************/
#pragma mark - Initialization
/**************************************/

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    /*
     Init
     */
    _mutableLayoutInfos = [NSMutableDictionary new] ;
    _finalAbscissas = [NSMutableDictionary new] ;
    
    
    
    
    /*
     Inset
     */
    UIEdgeInsets defaultInset = UIEdgeInsetsMake(kDefaultTopInset,
                                                 kDefaultLeftInset,
                                                 kDefaultBottomInset,
                                                 kDefaultRightInset) ;
    _insets = defaultInset ;
    
    
    
    /*
     OverlapWidth
     */
    _interItemsSpace = kDefaultInterItemsSpace ;
    _interLinesSpace = kDefaultInterItemsSpace ;
}







/**************************************/
#pragma mark - Convenience methods
/**************************************/


- (id <CBDHorizontalLayoutForColumnsDelegate>)delegate
{
    return (id <CBDHorizontalLayoutForColumnsDelegate>)self.collectionView.delegate ;
}




- (CGSize)sizeCollectionView
{
    return self.collectionView.frame.size ;
}








//
//
/**************************************/
#pragma mark - Auxiliary method
/**************************************/


- (CGSize)sizeOfElementWithIndexPath:(NSIndexPath *)indexPath
{
    return [self.delegate collectionView:self.collectionView
                                  layout:self
                  sizeForItemAtIndexPath:indexPath] ;
}


- (void)setInterLinesSpace:(CGFloat)interLinesSpace
{
    _interLinesSpace = interLinesSpace ;
    [self computeNumberOfLines] ;
}


- (void)computeNumberOfLines
{
    NSInteger result = 0 ;
    
    while ([self necessaryHeightForNumberOfLines:result] <= [self sizeCollectionView].height)
    {
        result = result + 1 ;
    }
    
    if (result - 1 < 0)
    {
        _numberOfLines = 0 ;
    }
    else
    {
        _numberOfLines = result - 1;
    }
}




- (CGFloat)necessaryHeightForNumberOfLines:(NSUInteger)numberOfLines
{
    CGFloat result = 0 ;
    
    result = result + self.insets.top + self.insets.bottom ;
    
    if (numberOfLines > 0)
    {
        result = result + self.heightCells * numberOfLines + self.interLinesSpace * (numberOfLines - 1) ;
    }
    
    return result ;
}








/**************************************/
#pragma mark - Core method : assistant methods
/**************************************/


- (CGFloat)yCoordinateForLineWithIndex:(NSUInteger)lineIndex
{
    CGFloat result = 0 ;
    
    result = self.insets.top + (self.heightCells + self.interLinesSpace) * lineIndex ;
    
    return result ;
}


- (CGFloat)finalAbscissaForLineWithIndex:(NSUInteger)lineIndex
{
    return [self.finalAbscissas[@(lineIndex)] CGFloatValue_cbd] ;
}


- (void)setFinalAbscissa:(CGFloat)finalAbsissa
        forLineWithIndex:(NSUInteger)lineIndex
{
    self.finalAbscissas[@(lineIndex)] = @(finalAbsissa) ;
}


- (CGFloat)maxFinalAbscissa
{
    CGFloat result = 0;
    
    for (NSNumber * finalAbscissa in [self.finalAbscissas allValues])
    {
        CGFloat finalAbscissaValue = [finalAbscissa CGFloatValue_cbd] ;
        
        if (finalAbscissaValue > result)
        {
            result = finalAbscissaValue ;
        }
    }
    
    return result ;
}


- (NSNumber *)indexOfLineWithMinimumFinalAbscissa
{
    NSNumber * result = nil ;
    CGFloat minFinalAbscissa = CGFLOAT_MAX ;
    
    for (NSNumber * index in [self.finalAbscissas allKeys])
    {
        CGFloat finalAbscissaForThisLine = [self.finalAbscissas[index] CGFloatValue_cbd] ;
        
        if (finalAbscissaForThisLine < minFinalAbscissa)
        {
            minFinalAbscissa = finalAbscissaForThisLine ;
            result = index ;
        }
    }

    
    return result ;
}






/**************************************/
#pragma mark - Core method
/**************************************/


- (void)prepareLayout
{
    /*
     Init mutable dico
     */
    self.mutableLayoutInfos = [NSMutableDictionary new] ;
    self.finalAbscissas = [NSMutableDictionary new] ;
    
    
    
    /*
     Parameters
     */
    [self computeNumberOfLines] ;
    NSUInteger numberOfLines = [self numberOfLines] ;
    
    
    
    /*
     Intial value for current X and the maxY
     */
    for (NSUInteger indexLine = 0 ; indexLine < numberOfLines ; indexLine++)
    {
        [self setFinalAbscissa:self.insets.left - self.interItemsSpace
              forLineWithIndex:indexLine] ;
    }
    
    
    /*
     **********
     CORE
     *********
     */
    for (NSUInteger indexSection = 0 ; indexSection < [self.collectionView numberOfSections] ; indexSection ++)
    {
        for (NSUInteger index = 0 ; index < [self.collectionView numberOfItemsInSection:indexSection] ; index++)
        {
            /*
             Current index path
             */
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index
                                                          inSection:indexSection] ;
            
            /*
             Computing the origin and the frame
             */
            NSUInteger  indexLineToUse = [[self indexOfLineWithMinimumFinalAbscissa] integerValue] ;
            
            CGFloat xCoordinate = [self finalAbscissaForLineWithIndex:indexLineToUse] + self.interItemsSpace ;
            CGFloat yCoordinate = [self yCoordinateForLineWithIndex:indexLineToUse] ;
            
            CGSize size = [self sizeOfElementWithIndexPath:indexPath] ;
            
            CGRect frame ;
            frame.origin = CGPointMake(xCoordinate, yCoordinate) ;
            frame.size = size ;

            
            /*
             Updating the final absissa
             */
            CGFloat finalAbscissa = xCoordinate + size.width ;
            [self setFinalAbscissa:finalAbscissa
                  forLineWithIndex:indexLineToUse] ;
            
            
            
            /*
             Creating the layout attribute
             */
            UICollectionViewLayoutAttributes * layoutAttribute  = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            
            layoutAttribute.frame = frame;
            
            
            /*
             Saving it in the dico
             */
            self.mutableLayoutInfos[indexPath] = layoutAttribute ;
        }
    }
    
    /*
     We set the attributes
     */
    
    
    /*
     Finally, we compute the contentSize
     */
    [self computeCollectionViewContentSize] ;
}











/**************************************/
#pragma mark - Size of the "contentView" of the collection view
/**************************************/


- (void)computeCollectionViewContentSize
{
    /*
     Computing
     */
    CGFloat maxAbsissa = [self maxFinalAbscissa] ;
    CGSize size = CGSizeMake(maxAbsissa + self.insets.right, [self sizeCollectionView].height) ;
    
    /*
     Setting
     */
    self.collectionViewContentSize = size ;
}







/**************************************/
#pragma mark - Layout attributes
/**************************************/




- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path
{
    return self.mutableLayoutInfos[path] ;
}





- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray * attrs = [NSMutableArray new] ;
    
    
    for (NSUInteger indexSection = 0 ; indexSection < [self.collectionView numberOfSections] ; indexSection++)
    {
        
        /*
         Normal cells
         */
        for (NSUInteger index = 0 ; index < [self.collectionView numberOfItemsInSection:indexSection] ; index ++)
        {
            /*
             Current index path
             */
            NSIndexPath * indexPath = [NSIndexPath indexPathForItem:index
                                                          inSection:indexSection] ;
            
            UICollectionViewLayoutAttributes *attr = self.mutableLayoutInfos[indexPath] ;
            
            if (CGRectIntersectsRect(rect, attr.frame))
            {
                [attrs addObject:attr] ;
            }
        }
    }
    
    
    return [NSArray arrayWithArray:attrs];
}

@end
