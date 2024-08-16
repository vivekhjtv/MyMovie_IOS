
import UIKit

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var movieCollectionView: UICollectionView!
    @IBOutlet var activityController: UIActivityIndicatorView!
    
    //MARK: - Variables
    var movieList: [ShortListModel] = []
    var page : Int = 1
    let refreshControl = UIRefreshControl()
    
    //MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        movieCollectionView.addSubview(refreshControl) // not required when using UITableViewController
        activityController.hidesWhenStopped = true
        refresh(self)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func refresh(_ sender: AnyObject) {
        movieList = coreDataServices.shared.getList()
        if movieList.isEmpty{
            activityController.startAnimating()
            UserDefaults.standard.set(Constants.currentPage, forKey: Constants.lastSavedPage)
            if InternetConnectionManager.isConnectedToNetwork(){
                let group = DispatchGroup()
                group.enter()
                APIServices.shared.getMovieList(page: Constants.currentPage,completion: {data in
                    if let data = data as? MovieListModel{
                        coreDataServices.shared.save(data: data.results)
                    }
                    group.leave()
                })
                
                group.notify(queue: .main, execute: {
                    self.movieList = coreDataServices.shared.getList()
                    self.movieCollectionView.reloadData()
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
                self.movieCollectionView.reloadData()
                self.activityController.stopAnimating()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    func fetchMore(){
        if Constants.isFetching{return}
        Constants.isFetching = true
        Constants.currentPage = UserDefaults.standard.integer(forKey: Constants.lastSavedPage)
        Constants.currentPage += 1
        UserDefaults.standard.set(Constants.currentPage, forKey: Constants.lastSavedPage)
        APIServices.shared.getMovieList(page:Constants.currentPage,completion: {data in
            if let data = data as? MovieListModel{
                coreDataServices.shared.save(data: data.results)
                self.movieList = coreDataServices.shared.getList()
                DispatchQueue.main.async {
                    self.movieCollectionView.reloadData()
                }
            }
        })
    }
}

//MARK: - Collectionview delegate and data source
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell() }
        cell.movieTitle.text = movieList[indexPath.row].title
        cell.posterImageView.image = UIImage(data: movieList[indexPath.row].image ?? Data()) ?? UIImage()
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (collectionView.frame.width/2 - 10), height: collectionView.frame.height/2.5 - 20)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let id = movieList[indexPath.row].id
        if let data = coreDataServices.shared.getDetail(id: id){
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
            vc.model = data
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

//MARK: - Scrollview delegate
extension ViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(self.movieCollectionView.contentOffset.y + 100 >= (self.movieCollectionView.contentSize.height - self.movieCollectionView.bounds.size.height)) {
            if Constants.currentPage <= Constants.totalPages || Constants.totalPages == 0{
                fetchMore()
            }
        }
    }
}
