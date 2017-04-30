//
//  PhotonManagerIntegrationTests.swift
//  Patriot
//
//  This is an integration test for the Photon hardware manager.
//
//  This class is a singleton-by-choice, so will be instantiated for each
//  test instead of using it as a Singleton.
//
//  Note: test credentials testUser and testPassword are in secret.swift
//
//  History: major refactor 4/17/16
//
//  Created by Ron Lisle on 11/13/16.
//  Copyright © 2016 Ron Lisle. All rights reserved.
//

import XCTest
import Particle_SDK
import PromiseKit

class PhotonManagerIntegrationTests: XCTestCase
{
    var manager: PhotonManager!

    var deviceFound:    String?
    var deviceLost:     String?
    
    override func setUp()
    {
        super.setUp()
        deviceFound = nil
        deviceLost = nil
        manager = PhotonManager()
        manager.deviceDelegate = self
        manager.activityDelegate = self
    }
    
    
    //MARK: Init
    
    func test_ThatPhotonManager_Instantiated()
    {
        XCTAssertNotNil(manager)
    }
    
    
    //MARK: Singleton-by-choice
    
    func test_TwoSharedReferences_AreTheSameInstance()
    {
        let shared1 = PhotonManager.sharedInstance as! PhotonManager
        let shared2 = PhotonManager.sharedInstance as! PhotonManager
        XCTAssertEqual(shared1, shared2)
    }
    
    
    func test_TwoDirectlyInitializedInstances_AreNotTheSameInstance()
    {
        let shared1 = PhotonManager()
        let shared2 = PhotonManager()
        XCTAssertNotEqual(shared1, shared2)
    }
    

    //MARK: Login
    
    func test_LoginToTestAccount_DoesNotReturnError()
    {
        login()
        XCTAssert(ParticleCloud.sharedInstance().isAuthenticated)
    }
    
    
    //MARK: Device discovery
    
    func test_PhotonsArray_IsInitiallyEmpty()
    {
        XCTAssertEqual(manager.photons.count, 0)
    }
    
    
    func test_GetAllPhotonDevices_ReturnsTestDevice()
    {
        login()
        let promise = expectation(description: "login")
        self.manager.getAllPhotonDevices().then { _ -> Void in
            let myPhoton = self.manager.getPhoton(named: "myPhoton")
            XCTAssertEqual(myPhoton?.name, "myPhoton")
            promise.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    
    func test_GetAllPhotonDevices_CallsDelegate()
    {
        login()
        let promise = expectation(description: "login")
        self.manager.getAllPhotonDevices().then { _ -> Void in
            XCTAssertEqual(self.deviceFound, "myphoton")
            promise.fulfill()
        }
        waitForExpectations(timeout: 3)
    }
    
    
    //MARK: performDiscovery
    func test_PerformDiscovery_CallsDelegate()
    {
        login()
        let promise = expectation(description: "discovery")
        self.manager.discoverDevices().then { _ -> Void in
            XCTAssertEqual(self.deviceFound, "myphoton")
            promise.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    
    
    //MARK: SupportedNames
    
    func testSupportedInitiallyEmpty()
    {
        XCTAssertEqual(manager.supportedNames.count, 0)
    }
}


extension PhotonManagerIntegrationTests: DeviceNotifying
{
    func deviceFound(name: String)
    {
        print("deviceFound: \(name)")
        deviceFound = name
    }
    
    
    func deviceLost(name: String)
    {
        print("deviceLost: \(name)")
    }
}


extension PhotonManagerIntegrationTests: ActivityNotifying
{
    func supportedListChanged(list: Set<String>)
    {
        print("supportedListChanged: \(list)")
    }
    
    
    func activityChanged(event: String)
    {
        print("activityChanged: \(event)")
    }
}


//MARK: Test Helpers

extension PhotonManagerIntegrationTests
{
    func login()
    {
        let promise = expectation(description: "login")
        manager.login(user: Secret.TestEmail, password: Secret.TestPassword).then { _ in
            promise.fulfill()
        }.catch { _ in
            XCTFail()
        }
        waitForExpectations(timeout: 3)
    }
}
