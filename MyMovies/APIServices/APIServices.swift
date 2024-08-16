
import Foundation

//MARK: - API calling for fetching data
class APIServices{
    static let shared = APIServices()
    private init(){}
    
    ///API for fetching all movie list data
    func getAllMovies(page: Int = 1, completion : @escaping (AllMoviesModel) -> Void){
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/discover/movie?&api_key=d9e7626a26ff6d42d5e1282528ed6726&page=\(page)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request as URLRequest,completionHandler: {data,response,error in
            Constants.isFetchingForAllMovies = false
            if error == nil {
                do{
                    let movieList : AllMoviesModel = try JSONDecoder().decode(AllMoviesModel.self,from: data!)
                    Constants.totalPagesForAllMovies = movieList.totalPages
                    Constants.currentPageForAllMovies = movieList.page
                    print(movieList)
                    completion(movieList)
                } catch let error1 as Error {
                    Constants.currentPageForAllMovies += 1
                    UserDefaults.standard.set(Constants.currentPageForAllMovies, forKey: Constants.lastSavedPageForAllMovies)
                    print(error1)
                }
            }else{
                print(error!)
            }
        }).resume()
    }
    
    ///API for fetching top rated movie list
    func getMovieList(page: Int = 1, completion : @escaping (MovieListModel) -> Void){
        print("API Page \(page)")
        let headers = [
            "accept": "application/json",
            "Authorization": "Bearer \(Constants.accessToken)"
        ]
        //https://api.themoviedb.org/3/movie/top_rated?page=2
        //"https://api.themoviedb.org/3/movie/movie_id?language=en-US
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/top_rated?page=\(page)&language=en-US")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request as URLRequest,completionHandler: {data,response,error in
            Constants.isFetching = false
            if error == nil {
                do{
                    let movieList : MovieListModel = try JSONDecoder().decode(MovieListModel.self,from: data!)
                    Constants.totalPages = movieList.totalPages
                    Constants.currentPage = movieList.page
                    //UserDefaults.standard.set(movieList.page, forKey: Constants.lastSavedPage)
                    print(movieList)
                    completion(movieList)
                } catch let error1 as Error {
                    Constants.currentPage += 1
                    UserDefaults.standard.set(Constants.currentPage, forKey: Constants.lastSavedPage)
                    print(error1)
                }
            }else{
                print(error!)
            }
        }).resume()
    }
}
