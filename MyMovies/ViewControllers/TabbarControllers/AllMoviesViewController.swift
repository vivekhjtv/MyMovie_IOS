
import UIKit

class AllMoviesViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var activityController: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Variables
    var page : Int = 1
    var movieList: [ShortListForAllMovieModel] = []
    let refreshControl = UIRefreshControl()
    
    //MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        collectionView.addSubview(refreshControl)
        activityController.hidesWhenStopped = true
        refresh(self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func refresh(_ sender: AnyObject) {
        movieList = coreDataServices.shared.getListForAllMovies()
        if movieList.isEmpty{
            activityController.startAnimating()
            UserDefaults.standard.set(Constants.currentPageForAllMovies, forKey: Constants.lastSavedPageForAllMovies)
            if InternetConnectionManager.isConnectedToNetwork(){
                let group = DispatchGroup()
                group.enter()
                APIServices.shared.getAllMovies(page: Constants.currentPageForAllMovies,completion: {data in
                    if let data = data as? AllMoviesModel{
                        coreDataServices.shared.saveForAllMovies(data: data.results)
                    }
                    group.leave()
                })
                
                group.notify(queue: .main, execute: {
                    self.movieList = coreDataServices.shared.getListForAllMovies()
                    self.collectionView.reloadData()
                    self.activityController.stopAnimating()
                    self.refreshControl.endRefreshing()
                })
                
            }else{
                let alert = UIAlertController(title: "Alert", message: "Internet Not available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.activityController.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchMore(){
        if Constants.isFetchingForAllMovies{return}
        Constants.isFetchingForAllMovies = true
        Constants.currentPageForAllMovies = UserDefaults.standard.integer(forKey: Constants.lastSavedPageForAllMovies)
        Constants.currentPageForAllMovies += 1
        UserDefaults.standard.set(Constants.currentPageForAllMovies, forKey: Constants.lastSavedPageForAllMovies)
        APIServices.shared.getAllMovies(page:Constants.currentPageForAllMovies,completion: {data in
            if let data = data as? AllMoviesModel{
                coreDataServices.shared.saveForAllMovies(data: data.results)
                self.movieList = coreDataServices.shared.getListForAllMovies()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        })
    }
}

//MARK: - Collectionview delegate and data source
extension AllMoviesViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "AllMovieCell", for: indexPath) as? AllMovieCell else {
            return UICollectionViewCell() }
        cell1.movieTitle.text = movieList[indexPath.row].title
        cell1.posterImgView.image = UIImage(data: movieList[indexPath.row].image ?? Data()) ?? UIImage()
        return cell1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (collectionView.frame.width/2 - 10), height: collectionView.frame.height/2.5 - 20)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = movieList[indexPath.row].id
        if let data = coreDataServices.shared.getDetailForAllMovies(id: id){
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailForAllMovieViewController") as? DetailForAllMovieViewController else {return}
            vc.model = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

//MARK: - Scrollview delegate
extension AllMoviesViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.collectionView.contentOffset.y + 100 >= (self.collectionView.contentSize.height - self.collectionView.bounds.size.height)) {
            if Constants.currentPageForAllMovies <= Constants.totalPagesForAllMovies || Constants.totalPagesForAllMovies == 0{
                fetchMore()
            }
        }
    }
}
