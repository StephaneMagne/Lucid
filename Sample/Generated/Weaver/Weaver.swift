import Combine
import Foundation
import Lucid
import SwiftUI
import UIKit

// swiftlint:disable all
/// This file is generated by Weaver 1.1.5
/// DO NOT EDIT!

final class MainDependencyContainer {

    private let provider: Provider

    fileprivate init(provider: Provider = Provider()) {
        self.provider = provider
    }

    private static var _dynamicResolvers = [Any]()
    private static var _dynamicResolversLock = NSRecursiveLock()

    fileprivate static func _popDynamicResolver<Resolver>(_ resolverType: Resolver.Type) -> Resolver {
        guard let dynamicResolver = _dynamicResolvers.removeFirst() as? Resolver else {
            MainDependencyContainer.fatalError()
        }
        return dynamicResolver
    }

    static func _pushDynamicResolver<Resolver>(_ resolver: Resolver) {
        _dynamicResolvers.append(resolver)
    }

    enum Scope {
        case transient
        case container
        case weak
        case lazy
    }

    enum Platform {
        case OSX
        case macOS
        case iOS
        case watchOS
        case tvOS
    }

    enum DependencyKind {
        case registration
        case reference
        case parameter
    }

    private var controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4Builder: Provider.Builder<MovieDetailController> {
        return provider.getBuilder(
            "controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4",
            MovieDetailController.self
        )
    }

    private var controller_b4f15911de1d23192220247df39643ae6375cab3Builder: Provider.Builder<MovieListController> {
        return provider.getBuilder("controller_b4f15911de1d23192220247df39643ae6375cab3", MovieListController.self)
    }

    private var coreManagersBuilder: Provider.Builder<MovieCoreManagerProviding> {
        return provider.getBuilder("coreManagers", MovieCoreManagerProviding.self)
    }

    private var imageManagerBuilder: Provider.Builder<ImageManager> {
        return provider.getBuilder("imageManager", ImageManager.self)
    }

    private var managersBuilder: Provider.Builder<MovieCoreManagerProviding> {
        return provider.getBuilder("managers", MovieCoreManagerProviding.self)
    }

    private var movieDBClientBuilder: Provider.Builder<MovieDBClient> {
        return provider.getBuilder("movieDBClient", MovieDBClient.self)
    }

    private var movieDetailBuilder: Provider.Builder<MovieDetail> {
        return provider.getBuilder("movieDetail", MovieDetail.self)
    }

    private var movieListBuilder: Provider.Builder<MovieList> {
        return provider.getBuilder("movieList", MovieList.self)
    }

    private var movieManagerBuilder: Provider.Builder<MovieManager> {
        return provider.getBuilder("movieManager", MovieManager.self)
    }

    private var viewModelBuilder: Provider.Builder<MovieDetailViewModel> {
        return provider.getBuilder("viewModel", MovieDetailViewModel.self)
    }

    var controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4: MovieDetailController {
        return controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4Builder(nil)
    }

    var controller_b4f15911de1d23192220247df39643ae6375cab3: MovieListController {
        return controller_b4f15911de1d23192220247df39643ae6375cab3Builder(nil)
    }

    var coreManagers: MovieCoreManagerProviding {
        return coreManagersBuilder(nil)
    }

    var imageManager: ImageManager {
        return imageManagerBuilder(nil)
    }

    var managers: MovieCoreManagerProviding {
        return managersBuilder(nil)
    }

    var movieDBClient: MovieDBClient {
        return movieDBClientBuilder(nil)
    }

    func movieDetail(viewModel: MovieDetailViewModel) -> MovieDetail {
        return movieDetailBuilder { (provider) in provider.setBuilder("viewModel", Provider.valueBuilder(viewModel)) }
    }

    var movieList: MovieList {
        return movieListBuilder(nil)
    }

    var movieManager: MovieManager {
        return movieManagerBuilder(nil)
    }

    var viewModel: MovieDetailViewModel {
        return viewModelBuilder(nil)
    }

    private func appDelegateDependencyResolver() -> AppDelegateDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["movieDBClient"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieDBClient in return MovieDBClient() }
        )
        _builders["managers"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieCoreManagerProviding in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                return CoreManagerContainer.make(_inputContainer as MovieCoreManagerProvidingInputDependencyResolver)
            }
        )
        _builders["movieList"] = { (_: Optional<Provider.ParametersCopier>) -> MovieList in
            defer { MainDependencyContainer._dynamicResolversLock.unlock() }
            MainDependencyContainer._dynamicResolversLock.lock()
            let _inputContainer = MainDependencyContainer(provider: _inputProvider)
            let __self = _inputContainer.movieListDependencyResolver()
            return MovieList(injecting: __self)
        }
        _builders["imageManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> ImageManager in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.imageManagerDependencyResolver()
                return ImageManager(injecting: __self)
            }
        )
        _builders["coreManagers"] = _self.coreManagersBuilder
        _builders["managers"] = _self.managersBuilder
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.movieDBClient
        _ = _self.managers
        _ = _self.imageManager
        MainDependencyContainer._pushDynamicResolver({ _self.movieDBClient })
        MainDependencyContainer._pushDynamicResolver({ _self.managers })
        MainDependencyContainer._pushDynamicResolver({ _self.movieList })
        MainDependencyContainer._pushDynamicResolver({ _self.imageManager })
        return _self
    }

    static func appDelegateDependencyResolver() -> AppDelegateDependencyResolver {
        let _self = MainDependencyContainer().appDelegateDependencyResolver()
        return _self
    }

    fileprivate func imageManagerDependencyResolver() -> ImageManagerDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["movieDBClient"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieDBClient in
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                return ImageManager.makeMovieDBClient(_inputContainer as MovieDBClientInputDependencyResolver)
            }
        )
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.movieDBClient
        MainDependencyContainer._pushDynamicResolver({ _self.movieDBClient })
        return _self
    }

    static func imageManagerDependencyResolver() -> ImageManagerDependencyResolver {
        let _self = MainDependencyContainer().imageManagerDependencyResolver()
        return _self
    }

    private func movieDetailControllerDependencyResolver() -> MovieDetailControllerDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["movieManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieManager in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.movieManagerDependencyResolver()
                return MovieManager(injecting: __self)
            }
        )
        _builders["coreManagers"] = coreManagersBuilder
        _builders["managers"] = managersBuilder
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.movieManager
        MainDependencyContainer._pushDynamicResolver({ _self.movieManager })
        return _self
    }

    static func movieDetailControllerDependencyResolver() -> MovieDetailControllerDependencyResolver {
        let _self = MainDependencyContainer().movieDetailControllerDependencyResolver()
        return _self
    }

    private func movieDetailDependencyResolver() -> MovieDetailDependencyResolverProxy {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider
        var _builders = Dictionary<String, Any>()
        _builders["controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieDetailController in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider.copy())
                let __self = _inputContainer.movieDetailControllerDependencyResolver()
                return MovieDetailController(injecting: __self)
            }
        )
        _builders["coreManagers"] = coreManagersBuilder
        _builders["managers"] = managersBuilder
        _self.provider.addBuilders(_builders)
        _ = _self.controller
        MainDependencyContainer._pushDynamicResolver({ _self.controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4 })
        return MovieDetailDependencyResolverProxy(_self)
    }

    private func movieListControllerDependencyResolver() -> MovieListControllerDependencyResolver {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["movieManager"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieManager in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.movieManagerDependencyResolver()
                return MovieManager(injecting: __self)
            }
        )
        _builders["coreManagers"] = coreManagersBuilder
        _builders["managers"] = managersBuilder
        _builders["imageManager"] = imageManagerBuilder
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.movieManager
        MainDependencyContainer._pushDynamicResolver({ _self.movieManager })
        MainDependencyContainer._pushDynamicResolver({ _self.imageManager })
        return _self
    }

    private func movieListDependencyResolver() -> MovieListDependencyResolverProxy {
        let _self = MainDependencyContainer(provider: provider.copy())
        let _inputProvider = _self.provider.copy()
        var _builders = Dictionary<String, Any>()
        _builders["controller_b4f15911de1d23192220247df39643ae6375cab3"] = Provider.lazyBuilder(
             { (_: Optional<Provider.ParametersCopier>) -> MovieListController in
                defer { MainDependencyContainer._dynamicResolversLock.unlock() }
                MainDependencyContainer._dynamicResolversLock.lock()
                let _inputContainer = MainDependencyContainer(provider: _inputProvider)
                let __self = _inputContainer.movieListControllerDependencyResolver()
                return MovieListController(injecting: __self)
            }
        )
        _builders["movieDetail"] = { (copyParameters: Optional<Provider.ParametersCopier>) -> MovieDetail in
            defer { MainDependencyContainer._dynamicResolversLock.unlock() }
            MainDependencyContainer._dynamicResolversLock.lock()
            let _inputContainer = MainDependencyContainer(provider: _inputProvider)
            let __self = _inputContainer.movieDetailDependencyResolver()
            copyParameters?((__self.value as! MainDependencyContainer).provider)
            return MovieDetail(injecting: __self)
        }
        _builders["coreManagers"] = coreManagersBuilder
        _builders["managers"] = managersBuilder
        _builders["imageManager"] = imageManagerBuilder
        _self.provider.addBuilders(_builders)
        _inputProvider.addBuilders(_builders)
        _ = _self.controller
        MainDependencyContainer._pushDynamicResolver({ _self.controller_b4f15911de1d23192220247df39643ae6375cab3 })
        MainDependencyContainer._pushDynamicResolver(_self.movieDetail)
        return MovieListDependencyResolverProxy(_self)
    }

    static func movieListDependencyResolver() -> MovieListDependencyResolverProxy {
        let _self = MainDependencyContainer().movieListDependencyResolver()
        return _self
    }

    private func movieManagerDependencyResolver() -> MovieManagerDependencyResolver {
        let _self = MainDependencyContainer()
        var _builders = Dictionary<String, Any>()
        _builders["coreManagers"] = coreManagersBuilder
        _builders["managers"] = managersBuilder
        _self.provider.addBuilders(_builders)
        MainDependencyContainer._pushDynamicResolver({ _self.coreManagers })
        return _self
    }
}

protocol Controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4_Resolver: AnyObject {
    var controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4: MovieDetailController { get }
}

protocol Controller_b4f15911de1d23192220247df39643ae6375cab3_Resolver: AnyObject {
    var controller_b4f15911de1d23192220247df39643ae6375cab3: MovieListController { get }
}

protocol CoreManagersResolver: AnyObject {
    var coreManagers: MovieCoreManagerProviding { get }
}

protocol ImageManagerResolver: AnyObject {
    var imageManager: ImageManager { get }
}

protocol ManagersResolver: AnyObject {
    var managers: MovieCoreManagerProviding { get }
}

protocol MovieDBClientResolver: AnyObject {
    var movieDBClient: MovieDBClient { get }
}

protocol MovieDetailResolver: AnyObject {
    func movieDetail(viewModel: MovieDetailViewModel) -> MovieDetail
}

protocol MovieListResolver: AnyObject {
    var movieList: MovieList { get }
}

protocol MovieManagerResolver: AnyObject {
    var movieManager: MovieManager { get }
}

protocol ViewModelResolver: AnyObject {
    var viewModel: MovieDetailViewModel { get }
}

extension MainDependencyContainer: Controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4_Resolver, Controller_b4f15911de1d23192220247df39643ae6375cab3_Resolver, CoreManagersResolver, ImageManagerResolver, ManagersResolver, MovieDBClientResolver, MovieDetailResolver, MovieListResolver, MovieManagerResolver, ViewModelResolver {
}

extension MainDependencyContainer {
}

typealias AppDelegateDependencyResolver = MovieDBClientResolver & ManagersResolver & MovieListResolver & ImageManagerResolver

typealias ImageManagerDependencyResolver = MovieDBClientResolver

typealias MovieDetailControllerDependencyResolver = MovieManagerResolver

typealias MovieDetailInternalDependencyResolver = Controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4_Resolver & ViewModelResolver

typealias MovieListControllerDependencyResolver = MovieManagerResolver & ImageManagerResolver

typealias MovieListInternalDependencyResolver = Controller_b4f15911de1d23192220247df39643ae6375cab3_Resolver & MovieDetailResolver

typealias MovieManagerDependencyResolver = CoreManagersResolver

typealias MovieCoreManagerProvidingInputDependencyResolver = ImageManagerResolver & ManagersResolver & MovieDBClientResolver & MovieListResolver

typealias MovieDBClientInputDependencyResolver = MovieDBClientResolver

struct MovieDetailDependencyResolverProxy {

    let value: MovieDetailInternalDependencyResolver

    init(_ value: MovieDetailInternalDependencyResolver) { self.value = value }

    var controller: MovieDetailController {
        return value.controller_35f3b1765c3e413b9aebf35708866b4d430e9ee4
    }

    var viewModel: MovieDetailViewModel {
        return value.viewModel
    }
}

typealias MovieDetailDependencyResolver = MovieDetailDependencyResolverProxy

struct MovieListDependencyResolverProxy {

    let value: MovieListInternalDependencyResolver

    init(_ value: MovieListInternalDependencyResolver) { self.value = value }

    var controller: MovieListController {
        return value.controller_b4f15911de1d23192220247df39643ae6375cab3
    }

    func movieDetail(viewModel: MovieDetailViewModel) -> MovieDetail { return value.movieDetail(viewModel: viewModel) }
}

typealias MovieListDependencyResolver = MovieListDependencyResolverProxy

@propertyWrapper
struct Weaver<ConcreteType, AbstractType> {

    typealias Resolver = () -> AbstractType
    let resolver = MainDependencyContainer._popDynamicResolver(Resolver.self)

    init(_ kind: MainDependencyContainer.DependencyKind,
         type: ConcreteType.Type,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = [],
         projects: Array<String> = []) {
        // no-op
    }

    var wrappedValue: AbstractType {
        return resolver()
    }
}

extension Weaver where ConcreteType == Void {
    init(_ kind: MainDependencyContainer.DependencyKind,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = [],
         projects: Array<String> = []) {
        // no-op
    }
}

@propertyWrapper
struct WeaverP1<ConcreteType, AbstractType, P1> {

    typealias Resolver = (P1) -> AbstractType
    let resolver = MainDependencyContainer._popDynamicResolver(Resolver.self)

    init(_ kind: MainDependencyContainer.DependencyKind,
         type: ConcreteType.Type,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = [],
         projects: Array<String> = []) {
        // no-op
    }

    var wrappedValue: Resolver {
        return resolver
    }
}

extension WeaverP1 where ConcreteType == Void {
    init(_ kind: MainDependencyContainer.DependencyKind,
         scope: MainDependencyContainer.Scope = .container,
         setter: Bool = false,
         escaping: Bool = false,
         builder: Optional<Any> = nil,
         objc: Bool = false,
         platforms: Array<MainDependencyContainer.Platform> = [],
         projects: Array<String> = []) {
        // no-op
    }
}

// MARK: - Fatal Error

extension MainDependencyContainer {

    static var onFatalError: (String, StaticString, UInt) -> Never = { message, file, line in
        Swift.fatalError(message, file: file, line: line)
    }

    fileprivate static func fatalError(file: StaticString = #file, line: UInt = #line) -> Never {
        onFatalError("Invalid memory graph. This is never suppose to happen. Please file a ticket at https://github.com/scribd/Weaver", file, line)
    }
}

// MARK: - Provider

private final class Provider {

    typealias ParametersCopier = (Provider) -> Void
    typealias Builder<T> = (ParametersCopier?) -> T

    private(set) var builders: Dictionary<String, Any>

    init(builders: Dictionary<String, Any> = [:]) {
        self.builders = builders
    }
}

private extension Provider {

    func addBuilders(_ builders: Dictionary<String, Any>) {
        builders.forEach { key, value in
            self.builders[key] = value
        }
    }

    func setBuilder<T>(_ name: String, _ builder: @escaping Builder<T>) {
        builders[name] = builder
    }

    func getBuilder<T>(_ name: String, _ type: T.Type) -> Builder<T> {
        guard let builder = builders[name] as? Builder<T> else {
            return Provider.fatalBuilder()
        }
        return builder
    }

    func copy() -> Provider {
        return Provider(builders: builders)
    }
}

private extension Provider {

    static func valueBuilder<T>(_ value: T) -> Builder<T> {
        return { _ in
            return value
        }
    }

    static func weakOptionalValueBuilder<T>(_ value: Optional<T>) -> Builder<Optional<T>> where T: AnyObject {
        return { [weak value] _ in
            return value
        }
    }

    static func lazyBuilder<T>(_ builder: @escaping Builder<T>) -> Builder<T> {
        var _value: T?
        return { copyParameters in
            if let value = _value {
                return value
            }
            let value = builder(copyParameters)
            _value = value
            return value
        }
    }

    static func weakLazyBuilder<T>(_ builder: @escaping Builder<T>) -> Builder<T> where T: AnyObject {
        weak var _value: T?
        return { copyParameters in
            if let value = _value {
                return value
            }
            let value = builder(copyParameters)
            _value = value
            return value
        }
    }

    static func fatalBuilder<T>() -> Builder<T> {
        return { _ in
            MainDependencyContainer.fatalError()
        }
    }
}
