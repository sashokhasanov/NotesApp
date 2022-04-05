//
//  AsyncOperation.swift
//  NotesApp
//
//  Created by Сашок on 04.04.2022.
//

import Foundation

class AsyncOperation : Operation {
    override var isAsynchronous: Bool {
        true
    }
    
    override var isReady: Bool {
        super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        state == .executing
    }
    
    override var isFinished: Bool {
        state == .finished
    }
    
    private var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
    
    override func start() {
        guard !isCancelled else {
            state = .finished
            return
        }
        state = .executing
        main()
    }
    
    override func main() {
        fatalError("\(#function) must be overriden")
    }
    
    func finish() {
        state = .finished
    }
    
    private enum State : String {
        case ready, executing, finished
        
        var keyPath: String {
            return "is" + rawValue.capitalized
        }
    }
}
