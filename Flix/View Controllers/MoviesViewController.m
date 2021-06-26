//
//  MoviesViewController.m
//  Flix
//
//  Created by mattpdl on 6/24/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
    
    // Display loading state while fetching movies
    [self firstFetch];
    
    // Add refresh control to table view
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)firstFetch {
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; // hide separators between table cells
    [self.activityIndicator startAnimating]; // display loading state
    [self fetchMovies];
}

- (void)endLoadingState {
    [self.refreshControl endRefreshing];
    [self.activityIndicator stopAnimating];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine]; // readd separators if necessary
}

- (void)fetchMovies {
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=82066c445c715af844c04703a9f38b33"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Unsuccessful request
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            [self endLoadingState];
            
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
            
            [self presentViewController:alert animated:YES completion:^{}]; // display alert
        }
           
        // Successful request
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //NSLog(@"%@", dataDictionary);

            // Get the array of movies and store the movies in a property to use elsewhere
            self.movies = dataDictionary[@"results"];
            for (NSDictionary *movie in self.movies)
               NSLog(@"%@", movie[@"title"]);

            // End loading state and reload table view data
            [self endLoadingState];
            [self.tableView reloadData];
        }
       }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dequeue movie cell component
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // Update title and synposis labels with movie info
    NSDictionary *movie = self.movies[indexPath.row];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@", movie[@"title"]];
    cell.synopsisLabel.text = [NSString stringWithFormat:@"%@", movie[@"overview"]];
    
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
        cell.posterView.image = nil; // No movie poster found
    }
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.movies[indexPath.row];
    
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

@end
