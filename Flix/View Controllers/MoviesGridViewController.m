//
//  MoviesGridViewController.m
//  Flix
//
//  Created by mattpdl on 6/25/21.
//

#import "MoviesGridViewController.h"
#import "MovieGridCell.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSArray *movies;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MoviesGridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=82066c445c715af844c04703a9f38b33"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Unsuccessful request
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            /*[self endLoadingState];
            
            // Create network connection alert controller
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Network Connection"
                                                                                       message:@"Your device does not appear to have an internet connection. Movies info cannot be retrieved at this time."
                                                                                preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *retryAction = [UIAlertAction actionWithTitle:@"Try Again"
                                                               style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * _Nonnull action) {
                if (self.movies.count > 0)
                    [self fetchMovies]; // refresh after connection lost
                else
                    [self firstFetch]; // retry after opening with no connection
            }];
            [alert addAction:retryAction];
            
            [self presentViewController:alert animated:YES completion:^{}]; // display alert*/
        }
           
        // Successful request
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@", dataDictionary);

            // Get the array of movies and store the movies in a property to use elsewhere
            self.movies = dataDictionary[@"results"];
            [self.collectionView reloadData];
        }
       }];
    [task resume];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // Dequeue grid cell component for each movie
    MovieGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieGridCell" forIndexPath:indexPath];
    NSDictionary *movie = self.movies[indexPath.row];\
    
    if ([movie[@"poster_path"] isKindOfClass:[NSString class]]) {
        // Get movie poster URL
        NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
        NSString *posterURLString = movie[@"poster_path"];
        NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
        NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
        
        // Update movie poster image view
        cell.posterView.image = nil;
        [cell.posterView setImageWithURL:posterURL];
    }
    else {
        cell.posterView.image = nil; // no movie poster found
    }
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

@end
