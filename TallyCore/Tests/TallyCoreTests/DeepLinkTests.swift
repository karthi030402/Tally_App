import Testing
import Foundation
@testable import TallyCore

struct DeepLinkTests {
    @Test func theTodayLinkLooksRightAndReadsBack() throws {
        let url = try #require(DeepLink.today.url)
        #expect(url.absoluteString == "tally://today")
        #expect(DeepLink(url: url) == .today)
    }

    @Test func aHabitLinkCarriesItsIdAndReadsBack() throws {
        let id = UUID()
        let url = try #require(DeepLink.habit(id).url)
        #expect(url.absoluteString == "tally://habit/\(id.uuidString)")
        #expect(DeepLink(url: url) == .habit(id))
    }

    @Test func otherSchemesAreIgnored() throws {
        let url = try #require(URL(string: "https://today"))
        #expect(DeepLink(url: url) == nil)
    }

    @Test func unknownPlacesAreIgnored() throws {
        let url = try #require(URL(string: "tally://settings"))
        #expect(DeepLink(url: url) == nil)
    }

    @Test func aHabitLinkWithABadIdIsIgnored() throws {
        let url = try #require(URL(string: "tally://habit/not-a-uuid"))
        #expect(DeepLink(url: url) == nil)
        let missing = try #require(URL(string: "tally://habit"))
        #expect(DeepLink(url: missing) == nil)
    }
}
