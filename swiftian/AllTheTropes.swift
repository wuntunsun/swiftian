//
//  AllTheTropes.swift
//  swiftian
//
//  Created by Robert Norris on 11.06.23.
//

import Foundation
import os.log



extension OSLog {
    
    static let networking = OSLog(subsystem: "com.wuntunsun.swiftian", category: "Networking")
}

struct LinkHere {
    
    let id: Int // this is all that is needed given we have the Trope/Category
    let title: String
}

struct Category {
    
    let title: String // seems redundant as it is only the title, will contain tropes[Trope] but will change as we explore...
}

struct Trope {
    
    let id: Int
    let title: String
    let linkshere: [LinkHere]?
    let categories: [Category]?
}

struct Link {
    
}

struct PlayingWith {
    
    let id: Int
    let links: [Link]
    //let title: String
    //let linkshere: [LinkHere]?
    //let categories: [Category]?
}

fileprivate extension Trope {

    init(page: AllTheTropes.Trope) {

        self.id = page.pageid
        self.title = page.title
        self.linkshere = page.linkshere?.map { LinkHere(page: $0) }
        self.categories = page.categories?.map { Category(page: $0) }
    }
}

fileprivate extension Category {

    init(page: AllTheTropes.Category) {

        self.title = page.title
    }
}

fileprivate extension LinkHere {

    init(page: AllTheTropes.LinkHere) {

        self.id = page.pageid
        self.title = page.title
    }
}

struct AllTheTropes {
    
    static let endpoint = URL(string: "w/api.php", relativeTo: URL(string: "https://allthetropes.org")!)!

    // is really just another page so convert to Trope, PlayingWith or Laconic
    fileprivate struct LinkHere: Decodable {
        
        let pageid: Int
        let ns: Int
        let title: String
    }

    fileprivate struct Category: Decodable {
        
        // where is the pageid?
        let ns: Int
        let title: String
    }
    
    fileprivate struct Trope: Decodable {
        
        let pageid: Int
        let ns: Int
        let title: String
        let linkshere: [LinkHere]?
        let categories: [Category]?
    }

    private enum Page: Decodable {
        
        case trope(swiftian.Trope)
        case category(swiftian.Category)
        case linkhere(swiftian.LinkHere)
        
        init(from decoder: Decoder) throws {
            
            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let page = try singleValueContainer.decode(Trope.self)
                self = .trope(swiftian.Trope(page: page))
                return
            }
            catch {}

            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let category = try singleValueContainer.decode(Category.self)
                self = .category(swiftian.Category(page: category))
                return
            }
            catch {}

            do {
                let singleValueContainer = try decoder.singleValueContainer()
                let linkhere = try singleValueContainer.decode(LinkHere.self)
                self = .linkhere(swiftian.LinkHere(page: linkhere))
                return
            }
            catch {}

            // TODO: Handle other types of Page...
            
            let context = DecodingError.Context(codingPath: [], debugDescription: "", underlyingError: nil)
            throw DecodingError.typeMismatch(Page.self, context)
        }
    }

    private typealias Pages = [String: Page]

    private struct Query: Decodable {
        
        let pages: Pages
    }

    private struct Continue: Decodable {
        
        let gcmcontinue: String
        let `continue`: String
    }

    private struct Response: Decodable {
        
        //let batchcomplete: String
        //let `continue`: Continue
        let query: Query
    }

    fileprivate struct Link: Decodable {
        
        let exists: String
        let ns: Int
        let asterix: String
        
        private enum CodingKeys: String, CodingKey {
            case exists
            case ns
            case asterix = "*"
        }
    }

    private enum PlayingWith: String {
        
        case Straight
        case Exaggerated
        case Downplayed
        case Justified
        case Inverted
        case Subverted
        case DoubleSubverted = "Double Subverted"
        case ZigZagged = "Zig Zagged"
        case Parodied
        case Deconstructed
        case Reconstructed
        case Averted
        case Enforced
        case Lampshaded
        case Invoked
        case Defied
        case Discussed
        case Conversed
    }
    
    private struct Parse: Decodable {
        
        let title: String
        let pageid: Int
        let revid: Int
        let text: String // some HTML
        //let categories: [Category] // sortKey and *
        let links: [Link] // we want to attribute some of these  to PlayingWith aka Category:Playing_With
        //let images: [?],
        //let externallinks: [?]
        //let sections: [?]
        //let parsewarnings: [?]
        let displaytitle: String
        //let iwlinks: [?]
        //let properties: [?]
    }
    
    private struct Response2: Decodable {
        
        let parse: Parse
    }

    private func playingWith(session: URLSession, id: Int, completion: @escaping (swiftian.PlayingWith?)->()) {
        
        // https://allthetropes.org/w/api.php?action=parse&format=json&page=24-Hour%20Armor%2FPlaying%20With
        // https://allthetropes.org/w/api.php?action=parse&format=json&pageid=156462
        
        var components = URLComponents(url: AllTheTropes.endpoint, resolvingAgainstBaseURL: true)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "action", value: "parse"))
        queryItems.append(URLQueryItem(name: "format", value: "json"))
        queryItems.append(URLQueryItem(name: "pageid", value: String(id)))
        components.queryItems = queryItems
        
        os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(describing: components))
        
        let url = components.url(relativeTo: AllTheTropes.endpoint)!
        let task = session.dataTask(with: url) {

            if let data = $0 {

                os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(decoding: data, as: UTF8.self))

                let decoder = JSONDecoder()

                let response = try? decoder.decode(Response2.self, from: data)
                let playingWith: swiftian.PlayingWith? = {

                    guard let response = response else {

                        return nil
                    }

                    // TODO: the links can be any type of Page... Laconic, Playing With and Trope
                    // given we are going through [PlayingWith] when we parse, we would like to
                    // enhance the 'links' with a Subverted etc. we only have the 'asterix' so would
                    // have to query on a Trope....
                    // the idea is to fully describe a Trope in one request which reqires Laconic and Playing With
                    // where PlayingWith is a link to another Trope...
                    // if we do not add a break, then we would expand until we fill an entire island of [Trope]
                    // that can be a lot of data, which the user may not care about
                    // we can keep the id a Set<PlayingWith> where PlayingWith.Subverted(Int) would allow for
                    // multiple members unless the hash ignores the id.
                    let links = response.parse.links.map { _ in swiftian.Link() } // TODO: transform Link
                    return swiftian.PlayingWith(id: response.parse.pageid, links: links)
                }()

                os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(describing: tropes))

                completion(playingWith)
                return
            }

            if let response = $1 {

            }

            if let error = $2 {

            }

            completion(nil)
        }
        
        task.resume()
    }
    
    private func trope(session: URLSession, id: Int, completion: @escaping (swiftian.Trope)->()) {
        
        // when we parse a page, it may be Loconic, Playing_With or Trope
        // what do we need from a Trope
        
        // https://allthetropes.org/w/api.php?action=parse&format=json&page=24-Hour%20Armor%2FPlaying%20With
        // https://allthetropes.org/w/api.php?action=parse&format=json&pageid=156462
        
        var components = URLComponents(url: AllTheTropes.endpoint, resolvingAgainstBaseURL: true)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "action", value: "parse"))
        queryItems.append(URLQueryItem(name: "format", value: "json"))
        queryItems.append(URLQueryItem(name: "pageid", value: String(id)))
        components.queryItems = queryItems
        
        os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(describing: components))
        
        let url = components.url(relativeTo: AllTheTropes.endpoint)!
        let task = session.dataTask(with: url) {

            if let data = $0 {

                os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(decoding: data, as: UTF8.self))

                completion(swiftian.Trope(id: 0, title: "", linkshere: nil, categories: nil))
                return
            }

            if let response = $1 {

            }

            if let error = $2 {

            }

            completion([])
        }
        
        task.resume()
    }
    
    // TODO: will need to make requests, also continue if need be, and cache results...
    // TODO: do we need to parse a Trope for additional information?
    func tropes(completion: @escaping ([swiftian.Trope])->()) {
    
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // "https://allthetropes.org/w/api.php?action=query&format=json&generator=categorymembers&gcmtitle=Category%3ATrope"
        
        var components = URLComponents(url: AllTheTropes.endpoint, resolvingAgainstBaseURL: true)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "action", value: "query"))
        queryItems.append(URLQueryItem(name: "format", value: "json"))
        queryItems.append(URLQueryItem(name: "generator", value: "categorymembers"))
        queryItems.append(URLQueryItem(name: "gcmtitle", value: "Category:Trope"))
        queryItems.append(URLQueryItem(name: "prop", value: "linkshere|categories")) // 'links' seem to come from 'text' when parsing...
        components.queryItems = queryItems
        
        os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(describing: components))
        
        let url = components.url(relativeTo: AllTheTropes.endpoint)!
        let task = session.dataTask(with: url) {

            if let data = $0 {

                os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(decoding: data, as: UTF8.self))

                let decoder = JSONDecoder()

                let response = try? decoder.decode(Response.self, from: data)
                let tropes: [swiftian.Trope] = {

                    guard let response = response else {

                        return []
                    }

                    return response.query.pages.values.compactMap { page in

                        if case .trope(let trope) = page {

                            return trope
                        }

                        return nil
                    }
                }()

                os_log("%{public}@ %{public}@", log: .networking, type: .debug, #function, String(describing: tropes))

                completion(tropes)
                return
            }

            if let response = $1 {

            }

            if let error = $2 {

            }

            completion([])
        }
        
        task.resume()
    }
}


