//
//  APIClientQueueTests.swift
//  LucidTests
//
//  Created by Stephane Magne on 3/4/19.
//  Copyright © 2018 Scribd. All rights reserved.
//

import XCTest

@testable import Lucid
@testable import LucidTestKit

final class APIClientQueueTests: XCTestCase {

    // MARK: - Spies

    private var defaultQueueCache: DiskCacheSpy<APIClientQueueRequest>!
    private var uniquingQueueOrderingCache: DiskCacheSpy<OrderedSet<String>>!
    private var uniquingQueueValueCache: DiskCacheSpy<APIClientQueueRequest>!
    private var queueProcessor: APIClientQueueProcessorSpy!

    // MARK: - Doubles

    private var uniquingFunction: ((APIClientQueueRequest) -> String)!

    // MARK: - Subject

    private var defaultQueue: APIClientQueue!
    private var uniquingQueue: APIClientQueue!

    override func setUp() {
        super.setUp()

        LucidConfiguration.logger = LoggerMock()

        defaultQueueCache = DiskCacheSpy()
        uniquingQueueOrderingCache = DiskCacheSpy()
        uniquingQueueValueCache = DiskCacheSpy()
        queueProcessor = APIClientQueueProcessorSpy()

        defaultQueue = APIClientQueue(cache: .default(DiskQueue(diskCache: defaultQueueCache.caching)),
                                      processor: queueProcessor)

        uniquingFunction = { $0.wrapped.config.path.description + "_key" }
        let uniquingCache = APIClientQueue.Cache.UniquingCache(orderingSetCache: uniquingQueueOrderingCache.caching, valueCache: uniquingQueueValueCache.caching)

        uniquingQueue = APIClientQueue(cache: .uniquing(uniquingCache,
                                                        uniquingFunction),
                                       processor: queueProcessor)
    }

    override func tearDown() {
        defer { super.tearDown() }

        defaultQueueCache = nil
        queueProcessor = nil
        defaultQueue = nil
        uniquingQueue = nil
    }
}

// MARK: - initialising default queue

extension APIClientQueueTests {

    func test_default_queue_sets_itself_as_delegate_of_processor() {

        let localQueueProcessor = APIClientQueueProcessorSpy()
        let localQueue = APIClientQueue(cache: .default(DiskQueue(diskCache: defaultQueueCache.caching)),
                                        processor: localQueueProcessor)

        XCTAssertEqual(localQueueProcessor.setDelegateInvocations.count, 1)
        XCTAssertTrue(localQueueProcessor.setDelegateInvocations[0] === localQueue)
    }
}

// MARK: - initialising uniquing queue

extension APIClientQueueTests {

    func test_uniquing_queue_sets_itself_as_delegate_of_processor() {

        let localQueueProcessor = APIClientQueueProcessorSpy()
        let uniquingCache = APIClientQueue.Cache.UniquingCache(orderingSetCache: uniquingQueueOrderingCache.caching, valueCache: uniquingQueueValueCache.caching)
        let localQueue = APIClientQueue(cache: .uniquing(uniquingCache,
                                                         uniquingFunction),
                                        processor: localQueueProcessor)

        XCTAssertEqual(localQueueProcessor.setDelegateInvocations.count, 1)
        XCTAssertTrue(localQueueProcessor.setDelegateInvocations[0] === localQueue)
    }
}
// MARK: - append to default queue

extension APIClientQueueTests {

    func test_append_should_add_an_element_to_the_default_queue_when_it_is_empty() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 0)

        await defaultQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 1)
        XCTAssertEqual(defaultQueueCache.setInvocations[0].1, request)
    }

    func test_append_should_add_an_element_to_the_default_queue_when_it_has_other_elements() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 0)

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 2)
        XCTAssertEqual(defaultQueueCache.setInvocations[0].1, request0)
        XCTAssertEqual(defaultQueueCache.setInvocations[1].1, request1)
    }

    func test_append_to_empty_default_queue_should_trigger_a_call_to_the_processor() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 0)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)

        await defaultQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 1)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }

    func test_calling_append_to_default_queue_twice_should_trigger_two_calls_to_the_processor() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 2)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }
}

// MARK: - prepend to default queue

extension APIClientQueueTests {

    func test_prepend_should_add_an_element_to_the_default_queue_when_it_is_empty() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 0)

        await defaultQueue.prepend(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 1)
        XCTAssertEqual(defaultQueueCache.setInvocations[0].1, request)
    }

    func test_prepend_should_add_an_element_to_the_default_queue_when_it_has_other_elements() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 0)

        await defaultQueue.prepend(request0)
        await defaultQueue.prepend(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

        XCTAssertEqual(defaultQueueCache.setInvocations.count, 2)
        XCTAssertEqual(defaultQueueCache.setInvocations[0].1, request0)
        XCTAssertEqual(defaultQueueCache.setInvocations[1].1, request1)
    }

    func test_prepend_to_default_queue_should_not_trigger_a_call_to_the_processor() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await defaultQueue.prepend(request0)
        await defaultQueue.prepend(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 0)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }
}

// MARK: - append to uniquing queue

extension APIClientQueueTests {

    func test_append_should_add_an_element_to_the_uniquing_queue_when_it_is_empty() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 0)

        await uniquingQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)
//        try? await uniquingCacheDataQueue.enqueueBarrier { completion in completion() }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 1)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 1)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request)
    }

    func test_append_should_add_an_element_to_the_uniquing_queue_when_it_only_contains_elements_with_different_keys() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 0)

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

//        try? await uniquingCacheDataQueue.enqueueBarrier { completion in completion() }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path1_key"])
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].1?.array, ["fake_path1_key", "fake_path2_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path1_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].0, "fake_path2_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].1, request1)
    }

    func test_append_should_overwrite_elements_with_matching_keys_in_the_uniquing_queue_and_abort_the_existing_request() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host0", path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host0", path: .path("fake_path2")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host2", path: .path("fake_path1")))

        XCTAssertEqual(uniquingQueueOrderingCache.setInvocations.count, 0)

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)
        await uniquingQueue.append(request2)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)

//        try? await uniquingCacheDataQueue.enqueueBarrier { completion in completion() }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 3)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path1_key"])
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].1?.array, ["fake_path1_key", "fake_path2_key"])
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[2].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[2].1?.array, ["fake_path2_key", "fake_path1_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 3)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path1_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].0, "fake_path2_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].1, request1)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[2].0, "fake_path1_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[2].1, request2)

        XCTAssertEqual(queueProcessor.abortRequestInvocations, [request0])
    }

    func test_append_to_empty_uniquing_queue_should_trigger_a_call_to_the_processor() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 0)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)

        await uniquingQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

//        try? await uniquingCacheDataQueue.enqueueBarrier { completion in completion() }

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 1)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }

    func test_calling_append_to_uniquing_queue_twice_should_trigger_two_calls_to_the_processor() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

//        try? await uniquingCacheDataQueue.enqueueBarrier { completion in completion() }

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 2)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }
}

// MARK: - prepend to uniquing queue

extension APIClientQueueTests {

    func test_prepend_should_add_an_element_to_the_uniquing_queue_when_it_is_empty() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 0)

        await uniquingQueue.prepend(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 1)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 1)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request)
    }

    func test_prepend_should_add_an_element_to_the_uniquing_queue_when_it_only_contains_elements_with_different_keys() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 0)

        await uniquingQueue.prepend(request0)
        await uniquingQueue.prepend(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path1_key"])
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].1?.array, ["fake_path2_key", "fake_path1_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path1_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].0, "fake_path2_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].1, request1)
    }

    func test_prepend_should_not_overwrite_elements_with_matching_keys_in_the_uniquing_queue() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host0", path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host0", path: .path("fake_path2")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host2", path: .path("fake_path1")))

        XCTAssertEqual(uniquingQueueOrderingCache.setInvocations.count, 0)

        await uniquingQueue.prepend(request0)
        await uniquingQueue.prepend(request1)
        await uniquingQueue.prepend(request2)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[0].1?.array, ["fake_path1_key"])
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].0, "APIClientQueue_uniquing_cache_key")
        XCTAssertEqual(uniquingQueueOrderingCache.asyncSetInvocations[1].1?.array, ["fake_path2_key", "fake_path1_key"])

        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations.count, 2)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].0, "fake_path1_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[0].1, request0)
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].0, "fake_path2_key")
        XCTAssertEqual(uniquingQueueValueCache.asyncSetInvocations[1].1, request1)
    }

    func test_prepend_to_uniquing_queue_should_not_trigger_a_call_to_the_processor() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await uniquingQueue.prepend(request0)
        await uniquingQueue.prepend(request1)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 0)
        XCTAssertEqual(queueProcessor.flushInvocations, 0)
    }
}

// MARK: - flush default queue

extension APIClientQueueTests {

    func test_calling_flush_should_only_send_once_regardless_of_size_of_default_queue() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path3")))

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)
        await defaultQueue.append(request2)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)

        await defaultQueue.flush()

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 3)
        XCTAssertEqual(queueProcessor.flushInvocations, 1)
    }
}

// MARK: - flush uniquing queue

extension APIClientQueueTests {

    func test_calling_flush_should_only_send_once_regardless_of_size_of_uniquing_queue() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path3")))

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)
        await uniquingQueue.append(request2)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        await uniquingQueue.flush()

        XCTAssertEqual(queueProcessor.didEnqueueNewRequestInvocations, 3)
        XCTAssertEqual(queueProcessor.flushInvocations, 1)
    }
}

// MARK: - next request from default queue

extension APIClientQueueTests {

    func test_calling_next_request_on_default_queue_returns_request_and_empties_it() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        await defaultQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

        let retrievedRequest = await defaultQueue.nextRequest()

        XCTAssertEqual(retrievedRequest, request)
        XCTAssertEqual(defaultQueueCache.values.count, 0)
    }

    func test_calling_next_request_on_default_queue_returns_requests_in_order() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path3")))

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)
        await defaultQueue.append(request2)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)

        let retrievedRequest0 = await defaultQueue.nextRequest()
        XCTAssertEqual(request0, retrievedRequest0)

        let retrievedRequest1 = await defaultQueue.nextRequest()
        XCTAssertEqual(request1, retrievedRequest1)

        let retrievedRequest2 = await defaultQueue.nextRequest()
        XCTAssertEqual(request2, retrievedRequest2)

        let retrievedRequest3 = await defaultQueue.nextRequest()
        XCTAssertNil(retrievedRequest3)
    }
}

// MARK: - next request from uniquing queue

extension APIClientQueueTests {

    func test_calling_next_request_on_uniquing_queue_returns_request_and_empties_it() async {

        let request = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path")))

        await uniquingQueue.append(request)
//        queueProcessor.prepareRequestInvocations[0].completion(request.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        let retrievedRequest = await uniquingQueue.nextRequest()

        XCTAssertEqual(retrievedRequest, request)
        XCTAssertEqual(defaultQueueCache.values.count, 0)
    }

    func test_calling_next_request_on_uniquing_queue_returns_unique_requests_in_order() async {

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host0", path: .path("fake_path1")))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host1", path: .path("fake_path1")))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host2", path: .path("fake_path2")))
        let request3 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, host: "host3", path: .path("fake_path2")))

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)
        await uniquingQueue.append(request2)
        await uniquingQueue.append(request3)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)
//        queueProcessor.prepareRequestInvocations[3].completion(request3.wrapped.config)

//        uniquingCacheDataQueue.sync { }

        let retrievedRequest0 = await uniquingQueue.nextRequest()
        XCTAssertEqual(request1, retrievedRequest0)

        let retrievedRequest1 = await uniquingQueue.nextRequest()
        XCTAssertEqual(request3, retrievedRequest1)

        let retrievedRequest2 = await uniquingQueue.nextRequest()
        XCTAssertNil(retrievedRequest2)
    }
}

// MARK: - merging to default queue

extension APIClientQueueTests {

    func test_merging_an_identifier_should_inject_that_identifier_in_every_matching_request_in_the_queue() async {

        let localIdentifier = EntitySpyIdentifier(value: .local("1"))
        let localIdentifierData = "[{\"local\":\"1\"}]".data(using: .utf8)

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1") / localIdentifier),
                                             identifiers: localIdentifierData)
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)

        let remoteIdentifier = EntitySpyIdentifier(value: .remote(1, "1"))
        await defaultQueue.merge(with: remoteIdentifier)

        XCTAssertEqual(request0.wrapped.config.path.description, "fake_path1/:identifier_entity_spy:1")

        let retrievedRequest0 = await defaultQueue.nextRequest()
        XCTAssertEqual(retrievedRequest0?.wrapped.config.path.description, "fake_path1/1")

        let retrievedRequest1 = await defaultQueue.nextRequest()
        XCTAssertEqual(retrievedRequest1, request1)
    }
}

// MARK: - merging to uniquing queue

extension APIClientQueueTests {

    func test_merging_an_identifier_should_inject_that_identifier_in_every_matching_request_in_the_uniquing_queue() async {

        let localIdentifier = EntitySpyIdentifier(value: .local("1"))
        let localIdentifierData = "[{\"local\":\"1\"}]".data(using: .utf8)

        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path1") / localIdentifier),
                                             identifiers: localIdentifierData)
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(method: .get, path: .path("fake_path2")))

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)

        let remoteIdentifier = EntitySpyIdentifier(value: .remote(1, "1"))
        await uniquingQueue.merge(with: remoteIdentifier)

        XCTAssertEqual(request0.wrapped.config.path.description, "fake_path1/:identifier_entity_spy:1")

        let retrievedRequest0 = await uniquingQueue.nextRequest()
        XCTAssertEqual(retrievedRequest0?.wrapped.config.path.description, "fake_path1/1")

        let retrievedRequest1 = await uniquingQueue.nextRequest()
        XCTAssertEqual(retrievedRequest1, request1)
    }
}

// MARK: - removing requests from default queue

extension APIClientQueueTests {

    func test_remove_requests_should_remove_every_request_matching_the_filter_in_the_queue() async {

        let localIdentifierData = "[{\"local\":\"1\"}]".data(using: .utf8)

        let config0 = APIRequestConfig(method: .get, path: .path("fake_path1"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: [.onNetworkInterrupt]))
        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(config0), identifiers: localIdentifierData)

        let config1 = APIRequestConfig(method: .get, path: .path("fake_path1"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: []))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(config1), identifiers: localIdentifierData)

        let config2 = APIRequestConfig(method: .get, path: .path("fake_path1"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: [.onNetworkInterrupt]))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(config2), identifiers: localIdentifierData)

        let config3 = APIRequestConfig(method: .get, path: .path("fake_path1"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: []))
        let request3 = APIClientQueueRequest(wrapping: APIRequest<Data>(config3), identifiers: localIdentifierData)

        await defaultQueue.append(request0)
        await defaultQueue.append(request1)
        await defaultQueue.append(request2)
        await defaultQueue.append(request3)

//        queueProcessor.prepareRequestInvocations[0].completion(request0.wrapped.config)
//        queueProcessor.prepareRequestInvocations[1].completion(request1.wrapped.config)
//        queueProcessor.prepareRequestInvocations[2].completion(request2.wrapped.config)
//        queueProcessor.prepareRequestInvocations[3].completion(request3.wrapped.config)

        let removedRequests = await defaultQueue.removeRequests(matching: { $0.wrapped.config.queueingStrategy.retryPolicy.contains(.onNetworkInterrupt) == false })

        // test correct requests were removed
        XCTAssertEqual(removedRequests.count, 2)
        XCTAssertEqual(removedRequests.first?.wrapped.config, config1)
        XCTAssertEqual(removedRequests.last?.wrapped.config, config3)

        // test remaining queue is correct
        let retrievedRequest0 = await defaultQueue.nextRequest()
        XCTAssertEqual(retrievedRequest0?.wrapped.config, config0)

        let retrievedRequest1 = await defaultQueue.nextRequest()
        XCTAssertEqual(retrievedRequest1?.wrapped.config, config2)

        let retrievedRequest2 = await defaultQueue.nextRequest()
        XCTAssertNil(retrievedRequest2)
    }

    func test_remove_requests_should_remove_every_request_matching_the_filter_in_the_uniquing_queue() async {


        let config0 = APIRequestConfig(method: .get, path: .path("fake_path1"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: [.onNetworkInterrupt]))
        let request0 = APIClientQueueRequest(wrapping: APIRequest<Data>(config0), identifiers: "[{\"local\":\"1\"}]".data(using: .utf8))

        let config1 = APIRequestConfig(method: .get, path: .path("fake_path2"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: []))
        let request1 = APIClientQueueRequest(wrapping: APIRequest<Data>(config1), identifiers: "[{\"local\":\"2\"}]".data(using: .utf8))

        let config2 = APIRequestConfig(method: .get, path: .path("fake_path3"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: [.onNetworkInterrupt]))
        let request2 = APIClientQueueRequest(wrapping: APIRequest<Data>(config2), identifiers: "[{\"local\":\"3\"}]".data(using: .utf8))

        let config3 = APIRequestConfig(method: .get, path: .path("fake_path4"), queueingStrategy: APIRequestConfig.QueueingStrategy(synchronization: .barrier, retryPolicy: []))
        let request3 = APIClientQueueRequest(wrapping: APIRequest<Data>(config3), identifiers: "[{\"local\":\"4\"}]".data(using: .utf8))

        await uniquingQueue.append(request0)
        await uniquingQueue.append(request1)
        await uniquingQueue.append(request2)
        await uniquingQueue.append(request3)

        let removedRequests = await uniquingQueue.removeRequests(matching: { $0.wrapped.config.queueingStrategy.retryPolicy.contains(.onNetworkInterrupt) == false })

        // test correct requests were removed
        XCTAssertEqual(removedRequests.count, 2)
        XCTAssertEqual(removedRequests.first?.wrapped.config, config1)
        XCTAssertEqual(removedRequests.last?.wrapped.config, config3)

        // test remaining queue is correct
        let retrievedRequest0 = await uniquingQueue.nextRequest()
        XCTAssertEqual(retrievedRequest0?.wrapped.config, config0)

        let retrievedRequest1 = await uniquingQueue.nextRequest()
        XCTAssertEqual(retrievedRequest1?.wrapped.config, config2)

        let retrievedRequest2 = await uniquingQueue.nextRequest()
        XCTAssertNil(retrievedRequest2)
    }
}
