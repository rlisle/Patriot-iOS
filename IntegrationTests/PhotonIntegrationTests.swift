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
    var device: ParticleDevice?
    var photon: Photon?
    
    override func setUp()
    {
        super.setUp()

        cloud = ParticleCloud.sharedInstance()
        login()
        findTestDevice()
    }
    

    //MARK: Tests
    
    func test_ParticleCloud_IsSet()
    {
        XCTAssertNotNil(cloud)
    }
    
    
    func test_ParticleDevice_IsSet()
    {
        XCTAssertNotNil(device)
    }
    
    
    func test_Photon_IsInstantiated()
    {
        XCTAssertNotNil(photon)
    }
    

    func test_PhotonDeviceProperty_EqualsParticleDevice()
    {
        XCTAssertNotNil(photon?.particleDevice)
        XCTAssertEqual(device, photon?.particleDevice!)
    }
    
    
    func test_Photon_ReadsDevices()
    {
        let expect = expectation(description: "devices")
        photon?.refreshDevices().then { devices -> Void in
            print("devices = \(devices)")
            XCTAssert(devices.contains("led"))
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_Photon_ReadsSupported()
    {
        let expect = expectation(description: "supported")
        photon?.refreshSupported().then { supported -> Void in
            print("supported = \(supported)")
            XCTAssert(supported.contains("photon"))
            expect.fulfill()
        }
        waitForExpectations(timeout: 2)
    }
    
    
    func test_Photon_ReadsOptionalActivities()
    {
        let expect = expectation(description: "activities")

        //Set test activity to 33 (if not already)
        cloud.publishEvent(withName: "patriot", data: "test:33", isPrivate: true, ttl: 60)
        { (error:Error?) in
            if let e = error
            {
                print("Error publishing event \(e.localizedDescription)")
            }
            print("published test:33")
            self.photon?.refreshActivities().then { activities -> Void in
                print("activities read: \(activities)")
                XCTAssertEqual(activities["test"], "33")
                expect.fulfill()
            }
        }

        waitForExpectations(timeout: 5)
    }


    func test_Photon_ReadsPublish()
    {
        let expect = expectation(description: "publish")

        self.photon?.refreshActivities().then { publish -> Void in
            print("Publish read: \(publish)")
            expect.fulfill()
        }

        waitForExpectations(timeout: 2)
    }
    
    
    func test_Photon_Refresh()
    {
        let expect = expectation(description: "refresh")

        self.photon?.refresh().then { publish -> Void in
            print("Publish read: \(publish)")
            expect.fulfill()
        }

        waitForExpectations(timeout: 5)
    }
}



//MARK: Test Helpers

extension PhotonIntegrationTests
{
    func login()
    {
        let promise = expectation(description: "login")
        cloud.login(withUser: Secret.TestEmail, password: Secret.TestPassword) { (error) in
            XCTAssertNil(error)
            promise.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func findTestDevice()
    {
        let devicePromise = expectation(description: "device")
        cloud.getDevice(Secret.TestDeviceId) { (device: ParticleDevice?, error: Error?) in
            guard error == nil else
            {
                print("getDevice error = \(error!)")
                
                return
            }
            if let device = device
            {
                self.device = device
                self.photon = Photon(device: device)
            }
            devicePromise.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
}

