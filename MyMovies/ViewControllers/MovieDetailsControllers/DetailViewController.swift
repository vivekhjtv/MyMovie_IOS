
import UIKit

class DetailViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblOverView: UILabel!
    @IBOutlet var lblOriginalTitle: UILabel!
    @IBOutlet var lblLnguage: UILabel!
    @IBOutlet var lblReleaseDate: UILabel!
    @IBOutlet var lblRating: UILabel!
    @IBOutlet var lblPopularity: UILabel!
    @IBOutlet var lblAdult: UILabel!
    @IBOutlet var lblVoteCount: UILabel!
    
    //MARK: - Variables
    var model : ShortDetailModel!
    
    //MARK: - view controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if model.poster == nil{
            posterImageView.image = UIImage(systemName: "photo.circle.fill")
        }else{
            posterImageView.image = UIImage(data: model.poster!)
        }
        lblTitle.text = model.title
        lblOriginalTitle.text = model.originalTitle
        lblAdult.text = model.adult ? "Yes" : "No"
        lblRating.text = "\(model.voteAverage)"
        lblOverView.text = model.overView
        lblLnguage.text = model.language
        lblPopularity.text = String(model.popularity)
        lblReleaseDate.text = model.releaseDate
        lblVoteCount.text = String(model.voteCount)
    }
}
