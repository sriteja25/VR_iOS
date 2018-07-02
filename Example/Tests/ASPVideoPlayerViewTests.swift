//
//  ASPVideoPlayerViewTests.swift
//  ASPVideoPlayerViewTests
//
//  Created by Andrei-Sergiu Pițiș on 28/03/16.
//  Copyright © 2016 Andrei-Sergiu Pițiș. All rights reserved.
//

import XCTest
@testable import ASPVideoPlayer

class ASPVideoPlayerViewTests: XCTestCase {

    var videoURL: URL!
    var secondVideoURL: URL!
    var invalidVideoURL: URL!

    override func setUp() {
        super.setUp()

        videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4")
        secondVideoURL = Bundle.main.url(forResource: "video2", withExtension: "mp4")
        invalidVideoURL = Bundle.main.url(forResource: "video3", withExtension: "mp4")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitWithFrame_ShouldCreatePlayerWithFrame() {
        let frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        let player = ASPVideoPlayerView(frame: frame)

        XCTAssertEqual(player.frame, frame, "Frames are equal.")
    }

    func testDeinitCalled_ShouldDeallocatePlayer() {
        weak var player = ASPVideoPlayerView()

        XCTAssertNil(player, "Player deallocated.")
    }

    func testSetVolumeAboveMaximum_ShouldSetPlayerVolumeToMaximum() {
        let player = ASPVideoPlayerView()
        player.videoURL = videoURL
        player.volume = 2.0

        XCTAssertEqual(player.volume, 1.0, "Volume set to maximum.")
    }

    func testSetVolumeBelowMaximum_ShouldSetPlayerVolumeToMinimum() {
        let player = ASPVideoPlayerView()
        player.videoURL = videoURL
        player.volume = -1.0

        XCTAssertEqual(player.volume, 0.0, "Volume set to minimum.")
    }

    func testSetVolumeURLNotSet_ShouldSetPlayerVolumeToMinimum() {
        let player = ASPVideoPlayerView()

        player.volume = -1.0

        XCTAssertEqual(player.volume, 0.0, "Volume set to minimum.")
    }

    func testSetGravityAspectFill_ShouldChangeGravityToAspectFill() {
        let player = ASPVideoPlayerView()

        player.gravity = .aspectFill

        XCTAssertEqual(player.gravity, ASPVideoPlayerView.PlayerContentMode.aspectFill, "Content Mode is AspectFill.")
    }

    func testSetGravityResize_ShouldChangeGravityToResize() {
        let player = ASPVideoPlayerView()

        player.gravity = .resize

        XCTAssertEqual(player.gravity, ASPVideoPlayerView.PlayerContentMode.resize, "Content Mode is Resize.")
    }

    func testLoadInvalidURL_ShouldChangeStateToError() {
        let player = ASPVideoPlayerView()
        player.error = { [weak player] (error) in
            XCTAssertNil(player?.videoURL, "Video URL is nil.")
            XCTAssertEqual(error.localizedDescription, "Video URL is invalid.")
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.error)
        }
        player.videoURL = invalidVideoURL
    }

    func testLoadInvalidURL_ShouldReturnZeroForCurrentTime() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()

        player.error = { [weak player] error in
            XCTAssertEqual(player?.currentTime, 0.0, "Current Time is Zero")
            expectation.fulfill()
        }

        player.videoURL = invalidVideoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadInvalidURL_ShouldReturnZeroForVideoLength() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()

        player.error = { [weak player] error in
            XCTAssertEqual(player?.videoLength, 0.0, "Video Length is Zero")
            expectation.fulfill()
        }

        player.videoURL = invalidVideoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadVideoURL_ShouldLoadVideoAtURL() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.newVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.new)
            XCTAssertNotNil(player?.videoURL, "Video URL is not nil.")
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadNewVideoURL_ShouldLoadVideoAtURL() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()

        player.readyToPlayVideo = { [weak player] in
            player?.videoURL = self.secondVideoURL
        }

        player.videoURL = videoURL

        player.newVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.new)
            XCTAssertEqual(player?.videoURL, self.secondVideoURL)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testLoadVideoAndStartPlayingWhenReadySet_ShouldChangeStateToPlaying() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()

        player.startPlayingWhenReady = true

        player.startedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testSeekToPercentageBelowMinimum_ShouldSetCurrentTimeToZero() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.readyToPlayVideo = { [weak player] in
            player?.seek(-1.0)
            player?.pauseVideo()
        }

        player.pausedVideo = { [weak player] in
            XCTAssertEqual(player?.currentTime, 0.0, "Current Time is Zero")
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testPlayVideo_ShouldStartVideoPlayback() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.startPlayingWhenReady = true

        player.playingVideo = { [weak player] (progress) in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            player?.stopVideo()
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testPlayVideoThatIsAtMaximumPercentage_ShouldStartVideoPlaybackFromStartOfVideo() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.readyToPlayVideo = { [weak player] in
            player?.seek(1.0)
            player?.playVideo()
        }

        player.startedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            XCTAssertEqual(player?.progress, 0.0, "Progress is Zero")

            player?.stopVideo()
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testPlayFinishedVideo_ShouldStartVideoPlaybackFromBeginning() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.startPlayingWhenReady = true

        player.playingVideo = { [weak player] (progress) in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            player?.stopVideo()
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testStopVideo_ShouldStopVideo() {
        let expectation = self.expectation(description: "Timeout expectation")

        let player = ASPVideoPlayerView()
        player.startPlayingWhenReady = true

        player.playingVideo = { [weak player] (progress) in
            player?.stopVideo()
        }

        player.stoppedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.stopped, "Video playback has stopped.")
            expectation.fulfill()
        }

        player.videoURL = videoURL

        waitForExpectations(timeout: 5.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }

    func testShouldLoopSet_ShouldLoopVideoWhenFinished() {
        let expectation = self.expectation(description: "Timeout expectationShouldLoop")
        let player = ASPVideoPlayerView()
        player.shouldLoop = true

        player.finishedVideo = { [weak player] in
            XCTAssertEqual(player?.status, ASPVideoPlayerView.PlayerStatus.playing, "Video is playing.")
            expectation.fulfill()
        }

        player.videoURL = videoURL

        player.readyToPlayVideo = { [weak player] in
            player?.seek(0.9)
            player?.playVideo()
        }

        waitForExpectations(timeout: 20.0) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
}
