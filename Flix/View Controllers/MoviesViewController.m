//
//  MoviesViewController.m
//  Flix
//
//  Created by mattpdl on 6/24/21.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
    
    // Setup network request
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=82066c445c715af844c04703a9f38b33"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           // Unsuccessful request
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           
           // Successful request
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               //NSLog(@"%@", dataDictionary);

               // Get the array of movies and store the movies in a property to use elsewhere
               self.movies = dataDictionary[@"results"];
               for (NSDictionary *movie in self.movies)
                   NSLog(@"%@", movie[@"title"]);
               
               // Reload table view data
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
