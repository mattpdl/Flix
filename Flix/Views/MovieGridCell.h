//
//  MovieGridCell.h
//  Flix
//
//  Created by mattpdl on 6/25/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MovieGridCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *posterView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *posterIndicator;

@end

NS_ASSUME_NONNULL_END
