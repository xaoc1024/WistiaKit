//
//  WistiaAPIMediaTests.swift
//  WistiaKit
//
//  Created by Daniel Spinosa on 5/19/16.
//  Copyright © 2016 Wistia, Inc. All rights reserved.
//

import XCTest
@testable import WistiaKit

class WistiaAPIMediaTests: XCTestCase {
    
    let wAPI = WistiaAPI(apiToken:"1511ac67c0213610d9370ef12349c6ac828a18f6405154207b44f3a7e3a29e93")

    //MARK: - WistiaMedia

    //MARK: List

    func testListMediasByProject() {
        let expectation = expectationWithDescription("listed medias by project")

        wAPI.listMediasGroupedByProject { (projects) in
            if projects.count > 0 {
                if let medias = projects.first?.medias, media = medias.first {
                    if media.status == .Ready &&
                        media.hashedID == "2egno8swf1" &&
                        media.name == "Hey there, welcome to Wistia!" {
                            expectation.fulfill()
                    }
                }
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByValidProject() {
        let expectation = expectationWithDescription("listed media filtered by project")

        let p = WistiaProject(projectID: 2356285, name: nil, description: nil, mediaCount: nil, created: nil, updated: nil, hashedID: "ignored", anonymousCanUpload: false, anonymousCanDownload: false, isPublic: false, publicID: nil, medias: nil)
        wAPI.listMedias(filterByProject: p) { (medias) in
            if !medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByInValidProject() {
        let expectation = expectationWithDescription("listed media filtered by project")

        let p = WistiaProject(projectID: 0, name: nil, description: nil, mediaCount: nil, created: nil, updated: nil, hashedID: "ignored", anonymousCanUpload: false, anonymousCanDownload: false, isPublic: false, publicID: nil, medias: nil)
        wAPI.listMedias(filterByProject: p) { (medias) in
            if medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByName() {
        let expectation = expectationWithDescription("listed media filtered by name")

        wAPI.listMedias(filterByName: "do_not_change_this_name") { (medias) in
            if !medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByNameEmpty() {
        let expectation = expectationWithDescription("listed media filtered by name")

        wAPI.listMedias(filterByName: "ThisIsNOTTHENAME") { (medias) in
            if medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByValidType() {
        let expectation = expectationWithDescription("listed media filtered by valid type")

        wAPI.listMedias(filterByType: "Video") { (medias) in
            if !medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByValidButEmptyType() {
        let expectation = expectationWithDescription("listed media filtered by valid type")

        wAPI.listMedias(filterByType: "MicrosoftOfficeDocument") { (medias) in
            if medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByInvalidType() {
        let expectation = expectationWithDescription("listed media filtered by valid type")

        wAPI.listMedias(filterByType: "Cromulent") { (medias) in
            if medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByValidHashedID() {
        let expectation = expectationWithDescription("listed media filtered by valid hashedID")

        wAPI.listMedias(filterByHashedID: "2egno8swf1") { (medias) in
            if let m = medias.first where m.hashedID == "2egno8swf1" {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    func testListMediasFilterByInvalidHashedID() {
        let expectation = expectationWithDescription("listed media filtered by invalid hashedID")

        wAPI.listMedias(filterByHashedID: "BAD33ID33") { (medias) in
            if medias.isEmpty {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)

    }

    //MARK: Show

    func testShowMedia() {
        let expectation = expectationWithDescription("showed media from hashedID")

        wAPI.showMedia("2egno8swf1") { (media) in
            if let m = media where m.hashedID == "2egno8swf1" {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    //MARK: Update

    func testUpdateMedia() {
        let expectation = expectationWithDescription("updated media via hashedID")

        let randDesc = "MediaDescriptionUpdate@\(NSDate())"
        wAPI.updateMedia("2egno8swf1", name: nil, newStillMediaId: nil, description: randDesc) { (success, updatedMedia) in
            if let m = updatedMedia, d = m.description where success && d.containsString(randDesc) {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)

    }

    //MARK: Copy

    static var copiedMediaHashedID: String? = nil
    
    func testACopyMedia() {
        let expectation = expectationWithDescription("copied the media")

        wAPI.copyMedia("2egno8swf1", projectID: nil, owner: nil) { (success, copiedMedia) in
            if let m = copiedMedia where success && m.hashedID != "2egno8swf1" {
                expectation.fulfill()

                WistiaAPIMediaTests.copiedMediaHashedID = m.hashedID
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    //MARK: Delete

    func testBDeleteMedia() {
        guard let hashedID = WistiaAPIMediaTests.copiedMediaHashedID else { XCTFail("prerequisite fail: no media"); return }

        let expectation = expectationWithDescription("deleted the media")

        wAPI.deleteMedia(hashedID) { (success, deletedMedia) in
            if let m = deletedMedia where success && m.hashedID == hashedID {
                WistiaAPIMediaTests.copiedMediaHashedID = nil
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)

    }

    //MARK: Stats

    func testStatsForMedia() {
        let expectation = expectationWithDescription("got stats for media via hashedID")

        wAPI.statsForMedia("2egno8swf1") { (media) in
            if let m = media where m.stats != nil {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }

    //MARK: - WistiaAsset

    func testShowMediaIncludesAssets() {
        let expectation = expectationWithDescription("media had good looking assets")

        wAPI.showMedia("2egno8swf1") { (media) in
            if let m = media where m.hashedID == "2egno8swf1" && m.assets.count > 0 {
                expectation.fulfill()
            }
        }

        waitForExpectationsWithTimeout(3, handler: nil)
    }
    
}
