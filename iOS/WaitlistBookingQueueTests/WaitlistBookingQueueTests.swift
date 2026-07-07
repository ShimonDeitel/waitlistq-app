import XCTest
@testable import WaitlistBookingQueue

@MainActor
final class WaitlistBookingQueueTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntrySucceedsUnderLimit() {
        let before = store.entries.count
        let added = store.add(Entry(title: "Test", detail: "d", date: Date()))
        XCTAssertTrue(added)
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testAddEntryFailsAtLimit() {
        while store.canAddMore {
            store.add(Entry(title: "Filler", detail: "x", date: Date()))
        }
        let added = store.add(Entry(title: "Overflow", detail: "x", date: Date()))
        XCTAssertFalse(added)
        XCTAssertEqual(store.entries.count, Store.freeLimit)
    }

    func testDeleteEntry() {
        let entry = Entry(title: "ToDelete", detail: "x", date: Date())
        store.add(entry)
        let before = store.entries.count
        store.delete(entry)
        XCTAssertEqual(store.entries.count, before - 1)
    }

    func testUpdateEntry() {
        var entry = Entry(title: "Original", detail: "x", date: Date())
        store.add(entry)
        entry.title = "Updated"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.title, "Updated")
    }

    func testToggleFavorite() {
        let entry = Entry(title: "Fav", detail: "x", date: Date())
        store.add(entry)
        store.toggleFavorite(entry)
        XCTAssertTrue(store.entries.first(where: { $0.id == entry.id })?.isFavorite ?? false)
    }

    func testCanAddMoreReflectsLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(Entry(title: "A", detail: "", date: Date()))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
