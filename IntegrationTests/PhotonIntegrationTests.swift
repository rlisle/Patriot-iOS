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
    

    func test_ThatTestDevice_IsOnline()
    {
        let devicePromise = expectation(description: "device")
        login().then { _ -> Void in
            self.cloud.getDevice(Secret.TestDeviceId) { (device: ParticleDevice?, error: Error?) in
                print("getDevice return")
                XCTAssertNil(error)
                XCTAssertNotNil(device)
                devicePromise.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_ThatPhoton_IsSet()
    {
        let photonPromise = expectation(description: "photon")
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                XCTAssertNotNil(self.photon)
                photonPromise.fulfill()
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_Photon_ReadsDevices()
    {
        let expect = expectation(description: "devices")
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                self.photon?.refreshDevices().then { _ -> Void in
                    if let devices = self.photon?.devices
                    {
                        print("devices = \(devices)")
                        XCTAssert(devices.contains("led"))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_Photon_ReadsSupported()
    {
        let expect = expectation(description: "supported")
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                self.photon?.refreshSupported().then { _ -> Void in
                    if let supported = self.photon?.supported
                    {
                        print("supported = \(supported)")
                        XCTAssert(supported.contains("photon"))
                        expect.fulfill()
                    }
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_Photon_ReadsOptionalActivities()
    {
        let expect = expectation(description: "activities")

        //Set test activity to 33 (if not already)
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                self.cloud.publishEvent(withName: "patriot", data: "test:33", isPrivate: true, ttl: 60)
                { (error:Error?) in
                    if let e = error
                    {
                        print("Error publishing event \(e.localizedDescription)")
                    }
                    print("published test:33")
                    self.photon?.refreshActivities().then { _ -> Void in
                        if let activities = self.photon?.activities
                        {
                            print("activities read: \(activities)")
                            XCTAssertEqual(activities["test"], "33")
                            expect.fulfill()
                        }
                    }
                }
            }
        }

        waitForExpectations(timeout: 5)
    }


    func test_Photon_ReadsPublish()
    {
        let expect = expectation(description: "publish")
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                self.photon?.refreshActivities().then { publish -> Void in
                    print("Publish read: \(publish)")
                    expect.fulfill()
                }
            }
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_Photon_Refresh_updates_supported()
    {
        let expect = expectation(description: "refresh")
        login().then { _ -> Void in
            self.findTestDevice().then { _ -> Void in
                self.photon?.refresh().then { _ -> Void in
                    XCTAssert((self.photon?.supported?.count)! > 0)
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
    func login() -> Promise<Void>
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
                    print("Login succeed for user \(Secret.TestEmail)")
                    fulfill()
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
                    print("findTestDevice: \(device!.name)")
                    self.photon = Photon(device: device!)
                    fulfill(self.photon)
                }
            }
        }
    }
}

