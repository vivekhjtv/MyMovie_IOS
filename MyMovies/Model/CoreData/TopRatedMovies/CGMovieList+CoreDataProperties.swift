
import Foundation
import CoreData


extension CGMovieList {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CGMovieList> {
        return NSFetchRequest<CGMovieList>(entityName: "CGMovieList")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var originalTitle: String?
    @NSManaged public var language: String?
    @NSManaged public var overView: String?
    @NSManaged public var popularity: Double
    @NSManaged public var voteAverage: Float
    @NSManaged public var voteCount: Int32
    @NSManaged public var releaseDate: String?
    @NSManaged public var poster: Data?
    @NSManaged public var backdrop: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var adult: Bool

}

extension CGMovieList : Identifiable {

}
