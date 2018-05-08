//
//  PhotonIntegrationTests.swift
//  Patriot
//
//  This is an integration test for the Photon hardware.
//
//  History: major refactor 4/17/16
//
//  Created by Ron Lisle on 11/13/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import XCTest
import Particle_SDK
import PromiseKit


class PhotonIntegrationTests: XCTestCase
{
    var cloud: ParticleCloud!
    var photon: Photon?
    
    override func setUp()
    {
        super.setUp()

        cloud = ParticleCloud.sharedInstance()
        photon = nil
    }
    

    //MARK: Tests
    
    func test_ThatParticleCloud_IsInstantiated()
    {
        XCTAssertNotNil(cloud)
    }
    

    func test_ThatLogin_Succeeds()
    {
        let promise = expectation(description: "login")
        cloud.login(withUser: Secret.TestEmail, password: Secret.TestPassword) { (error) in
            XCTAssertNil(error)
            promise.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    

    func test_ThatPhoton_IsSet()
    {
        let photonPromise = expectation(description: "photon")
        _ = login().then { _ in
            return self.findTestDevice().then { _ -> Void in
                XCTAssertNotNil(self.photon)
                photonPromise.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_Photon_ReadVariable_DevicesNotNil()
    {
        let expect = expectation(description: "readVariable")
        _ = login().then { _ in
            return self.findTestDevice().then { _ -> Promise<Void> in
               return self.photon!.readVariable("Devices")
               .then { variable -> Void in
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_RefreshDevices_ReturnsLED()
    {
        let expect = expectation(description: "devices")
        _ = login().then { _ in
            return self.findTestDevice().then { _ -> Promise<Void> in
               return self.photon!.refreshDevices().then { _ -> Void in
                    if let devices = self.photon?.devices
                    {
                        XCTAssert(devices.contains("led"))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    
    func test_RefreshSupported_ReturnsPhoton()
    {
        let expect = expectation(description: "supported")
        _ = login().then { _ in
            return self.findTestDevice().then { _ in
                return self.photon?.refreshSupported().then { _ -> Void in
                    if let supported = self.photon?.supported
                    {
                        XCTAssert(supported.contains("photon"))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_RefreshActivities_ReturnsTest33()
    {
        let expect = expectation(description: "activities")
        _ = login().then { _ in
            return self.findTestDevice().then { _ -> Void in
                self.cloud.publishEvent(withName: "patriot", data: "test:33", isPrivate: true, ttl: 60)
                { (error:Error?) in
                    if let e = error
                    {
                        print("Error publishing event \(e.localizedDescription)")
                        XCTFail()
                    }
                }
                _ = self.photon?.refreshActivities().then { _ -> Void in
                    if let activities = self.photon?.activities
                    {
                        XCTAssertEqual(activities["test"], 33)
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 5)
    }


    func test_ReadPublishName_ReturnsNonNil()
    {
        let expect = expectation(description: "publish")
        _ = login().then { _ in
            return self.findTestDevice()
            .then { _ in
                return self.photon?.readPublishName()
                .then { publish -> Void in
                    print("Publish read: \(publish)")
                    XCTAssertNotNil(publish)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_Refresh_setsAtLeast1_supported()
    {
        let expect = expectation(description: "refresh")
        _ = login().then { _ in
            return self.findTestDevice().then { _ in
                return self.photon?.refresh().then { _ -> Void in
                    XCTAssert((self.photon?.supported?.count)! > 0)
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    
    func test_Refresh_SetsDevices_ToLED()
    {
        let expect = expectation(description: "refresh")
        _ = login().then { _ in
            return self.findTestDevice().then { _ in
                return self.photon?.refresh().then { _ -> Void in
                    XCTAssert((self.photon?.devices?.count)! > 0)
                    XCTAssertEqual(self.photon?.devices?.first, "led")
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 5)
    }
}



//MARK: Test Helpers

extension PhotonIntegrationTests
{
    @discardableResult func login() -> Promise<Void>
    {
        return Promise<Void> { fulfill, reject in
            cloud.login(withUser: Secret.TestEmail, password: Secret.TestPassword) { (error) in
                if error != nil
                {
                    print("Login error: \(error!)")
                    reject(error!)
                }
                else
                {
                    fulfill(())
                }
            }
        }
    }
    
    
    func findTestDevice() -> Promise<Photon?>
    {
        return Promise<Photon?> { fulfill, reject in
            cloud.getDevice(Secret.TestDeviceId) { (device: ParticleDevice?, error: Error?) in
                if error != nil
                {
                    print("findTestDevice error = \(error!)")
                    reject(error!)
                }
                else
                {
                    self.photon = Photon(device: device!)
                    fulfill(self.photon)
                }
            }
        }
    }
}

