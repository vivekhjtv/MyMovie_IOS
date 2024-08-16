
import Foundation
import CoreData


extension CGAllMovieList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CGAllMovieList> {
        return NSFetchRequest<CGAllMovieList>(entityName: "CGAllMovieList")
    }

    @NSManaged public var adult: Bool
    @NSManaged public var backdrop: String?
    @NSManaged public var id: Int64
    @NSManaged public var language: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var overView: String?
    @NSManaged public var popularity: Double
    @NSManaged public var poster: Data?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var title: String?
    @NSManaged public var voteAverage: Float
    @NSManaged public var voteCount: Int32

}

extension CGAllMovieList : Identifiable {

}
