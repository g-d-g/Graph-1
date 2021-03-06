/*
 * Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. <http://cosmicmind.io>.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *	*	Redistributions of source code must retain the above copyright notice, this
 *		list of conditions and the following disclaimer.
 *
 *	*	Redistributions in binary form must reproduce the above copyright notice,
 *		this list of conditions and the following disclaimer in the documentation
 *		and/or other materials provided with the distribution.
 *
 *	*	Neither the name of CosmicMind nor the names of its
 *		contributors may be used to endorse or promote products derived from
 *		this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import XCTest
@testable import Graph

class RelationshipPropertyTests: XCTestCase, WatchRelationshipDelegate {
    var saveExpectation: XCTestExpectation?
    
    var propertyInsertExpception: XCTestExpectation?
    var propertyUpdateExpception: XCTestExpectation?
    var propertyDeleteExpception: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPropertyInsert() {
        saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
        propertyInsertExpception = expectation(description: "[RelationshipTests Error: Property insert test failed.]")
        
        let graph = Graph()
        let watch = Watch<Relationship>(graph: graph).where(properties: "P1").resume()
        watch.delegate = self
        
        let relationship = Relationship(type: "T")
        relationship["P1"] = "V1"
        
        XCTAssertEqual("V1", relationship["P1"] as? String)
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPropertyUpdate() {
        saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
        
        let graph = Graph()
        
        let relationship = Relationship(type: "T")
        relationship["P1"] = "V1"
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
        propertyUpdateExpception = expectation(description: "[RelationshipTests Error: Property update test failed.]")
        
        let watch = Watch<Relationship>(graph: graph).where(properties: "P1").resume()
        watch.delegate = self
        
        relationship["P1"] = "V2"
        
        XCTAssertEqual("V2", relationship["P1"] as? String)
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testPropertyDelete() {
        saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
        
        let graph = Graph()
        
        let relationship = Relationship(type: "T")
        relationship["P1"] = "V1"
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        
        saveExpectation = expectation(description: "[RelationshipTests Error: Graph save test failed.]")
        propertyDeleteExpception = expectation(description: "[RelationshipTests Error: Property delete test failed.]")
        
        let watch = Watch<Relationship>(graph: graph).where(properties: "P1").resume()
        watch.delegate = self
        
        relationship["P1"] = nil
        
        XCTAssertNil(relationship["P1"])
        
        graph.async { [weak self] (success, error) in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            self?.saveExpectation?.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func watch(graph: Graph, relationship: Relationship, added property: String, with value: Any, source: GraphSource) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        XCTAssertEqual("P1", property)
        XCTAssertEqual("V1", value as? String)
        XCTAssertEqual(value as? String, relationship[property] as? String)
        
        propertyInsertExpception?.fulfill()
    }
    
    func watch(graph: Graph, relationship: Relationship, updated property: String, with value: Any, source: GraphSource) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        XCTAssertEqual("P1", property)
        XCTAssertEqual("V2", value as? String)
        XCTAssertEqual(value as? String, relationship[property] as? String)
        
        propertyUpdateExpception?.fulfill()
    }
    
    func watch(graph: Graph, relationship: Relationship, removed property: String, with value: Any, source: GraphSource) {
        XCTAssertTrue("T" == relationship.type)
        XCTAssertTrue(0 < relationship.id.characters.count)
        
        XCTAssertEqual("P1", property)
        XCTAssertEqual("V1", value as? String)
        XCTAssertNil(relationship[property])
        
        propertyDeleteExpception?.fulfill()
    }
}
