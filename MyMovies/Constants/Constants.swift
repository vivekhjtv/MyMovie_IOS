
import Foundation
import SystemConfiguration

//MARK: - Constants
class Constants{
    static var totalPagesForAllMovies = 0
    static var currentPageForAllMovies = 1
    static let lastSavedPageForAllMovies = "lastSavedPage"
    static let entityForAllMovies = "CGAllMovieList"
    static let fetchLimitForAllMovies = 20
    static var isFetchingForAllMovies = false
    static var totalPages = 0
    static var currentPage = 1
    static let lastSavedPage = "lastSavedPage"
    static let entity = "CGMovieList"
    static let fetchLimit = 20
    static var isFetching = false
    static let accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjNTIxOTM0ZDRmYWQyMjhhNDJmYjczZDE4OTBjMmEyMiIsInN1YiI6IjY0OTlhNDljYmJkMGIwMDEwNjZmYmU5MyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.o9xU4dLDW0LOr_PJngKSOTOOKCirEAmTD_1rx9HjNqo"
}

//MARK: - Network connectivity
public class InternetConnectionManager {
    private init() {}
    
    public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

