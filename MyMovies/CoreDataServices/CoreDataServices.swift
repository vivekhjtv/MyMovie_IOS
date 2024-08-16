
import Foundation
import CoreData

class coreDataServices{
    static let shared = coreDataServices()
    private init(){}
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "MyMovies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Core Date error : \(nserror)")
            }
        }
    }
    
    //MARK: - All Movies methods
    ///Save data from model to coredata
    func saveForAllMovies(data : [AllMoviesResult]){
        for i in data {
            let movie = NSEntityDescription.insertNewObject(forEntityName: Constants.entityForAllMovies, into: self.context) as? CGAllMovieList
            movie?.id = Int64(i.id)
            movie?.title = i.title
            movie?.adult = i.adult
            movie?.backdrop = i.backdropPath
            movie?.language = i.originalLanguage
            movie?.originalTitle = i.originalTitle
            movie?.popularity = i.popularity
            movie?.releaseDate = i.releaseDate
            movie?.overView = i.overview
            movie?.voteAverage = Float(i.voteAverage)
            movie?.voteCount = Int32(i.voteCount)
            movie?.posterPath = "\(i.posterPath)"
            if let url = URL(string: "https://image.tmdb.org/t/p/original\(i.posterPath)"){
                do{
                    let imgData = try Data(contentsOf: url)
                    movie?.poster = imgData
                }catch{
                    print(error)
                }
            }
            self.saveContext()
        }
    }
    
    ///Getting number of pages in data
    func getPageForAllMovies(page : Int) -> [ShortListForAllMovieModel]{
        var data : [ShortListForAllMovieModel] = []
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entityForAllMovies) as? NSFetchRequest else {return []}
        let sort = NSSortDescriptor(key: "movieId", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = Constants.fetchLimitForAllMovies
        fetchRequest.fetchOffset = page*Constants.fetchLimitForAllMovies
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGAllMovieList] ?? nil else {return data}
            for obj in movieCoreDataArray {
                data.append(ShortListForAllMovieModel(id: obj.id, title: obj.title, image: obj.poster))
            }
        }
        return data
    }
    
    ///Insert data in new model
    func getListForAllMovies() -> [ShortListForAllMovieModel]{
        var data : [ShortListForAllMovieModel] = []
        var seenIDs: Set<Int> = []
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entityForAllMovies) as? NSFetchRequest else {return []}
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGAllMovieList] ?? nil else {return data}
            for obj in movieCoreDataArray {
                //               data.append(ShortListForAllMovieModel(id: obj.id, title: obj.title, image: obj.poster))
                let movieID = obj.id
                if !seenIDs.contains(Int(movieID)) {
                    seenIDs.insert(Int(movieID))
                    let movie = ShortListForAllMovieModel(id: obj.id, title: obj.title, image: obj.poster)
                    data.append(movie)
                }
            }
        }
        return data
    }
    
    ///Details of movie selected from collection view
    func getDetailForAllMovies(id : Int64) -> ShortDetailForAllMovieModel?{
        var data : ShortDetailForAllMovieModel
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entityForAllMovies) as? NSFetchRequest else {return nil}
        //let sort = NSSortDescriptor(key: "id", ascending: false)
        let predicate : NSPredicate = NSPredicate(format: "id == %@", "\(id)")
        fetchRequest.predicate = predicate
        //fetchRequest.sortDescriptors = [sort]
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGAllMovieList] ?? nil else {return nil}
            let first = movieCoreDataArray.first
            data = ShortDetailForAllMovieModel(id: first?.id ?? id, title: first?.title, originalTitle: first?.originalTitle, language: first?.language, overView: first?.overView, popularity: first?.popularity ?? 0, voteAverage: first?.voteAverage ?? 0, voteCount: first?.voteCount ?? 0, releaseDate: first?.releaseDate, poster: first?.poster, backdrop: first?.backdrop, posterPath: first?.posterPath, adult: first?.adult ?? false)
        }
        return data
    }
    
    //MARK: - Top Rated Movie methods
    func save(data : [Result]){
        for i in data {
            let movie = NSEntityDescription.insertNewObject(forEntityName: Constants.entity, into: self.context) as? CGMovieList
            movie?.id = Int64(i.id)
            movie?.title = i.title
            movie?.adult = i.adult
            movie?.backdrop = i.backdropPath
            movie?.language = i.originalLanguage
            movie?.originalTitle = i.originalTitle
            movie?.popularity = i.popularity
            movie?.releaseDate = i.releaseDate
            movie?.overView = i.overview
            movie?.voteAverage = Float(i.voteAverage)
            movie?.voteCount = Int32(i.voteCount)
            if let url = URL(string: "https://image.tmdb.org/t/p/original\(i.posterPath)"){
                do{
                    let imgData = try Data(contentsOf: url)
                    movie?.poster = imgData
                }catch{
                    print(error)
                }
            }
            self.saveContext()
        }
    }
    
    func getPage(page : Int) -> [ShortListModel]{
        var data : [ShortListModel] = []
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entity) as? NSFetchRequest else {return []}
        let sort = NSSortDescriptor(key: "movieId", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchLimit = Constants.fetchLimit
        fetchRequest.fetchOffset = page*Constants.fetchLimit
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGMovieList] ?? nil else {return data}
            for obj in movieCoreDataArray {
                data.append(ShortListModel(id: obj.id, title: obj.title, image: obj.poster))
            }
        }
        return data
    }
    
    func getList() -> [ShortListModel]{
        var data : [ShortListModel] = []
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entity) as? NSFetchRequest else {return []}
        let sort = NSSortDescriptor(key: "id", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGMovieList] ?? nil else {return data}
            for obj in movieCoreDataArray {
                data.append(ShortListModel(id: obj.id, title: obj.title, image: obj.poster))
            }
        }
        return data
    }
    
    func getDetail(id : Int64) -> ShortDetailModel?{
        var data : ShortDetailModel
        guard let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: Constants.entity) as? NSFetchRequest else {return nil}
        //let sort = NSSortDescriptor(key: "id", ascending: false)
        let predicate : NSPredicate = NSPredicate(format: "id == %@", "\(id)")
        fetchRequest.predicate = predicate
        //fetchRequest.sortDescriptors = [sort]
        do{
            guard let movieCoreDataArray = try? context.fetch(fetchRequest) as? [CGMovieList] ?? nil else {return nil}
            let first = movieCoreDataArray.first
            data = ShortDetailModel(id: first?.id ?? id, title: first?.title, originalTitle: first?.originalTitle, language: first?.language, overView: first?.overView, popularity: first?.popularity ?? 0, voteAverage: first?.voteAverage ?? 0, voteCount: first?.voteCount ?? 0, releaseDate: first?.releaseDate, poster: first?.poster, backdrop: first?.backdrop, posterPath: first?.posterPath, adult: first?.adult ?? false)
        }
        return data
    }
}
