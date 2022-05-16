//
//  SynchronizationPresenter.swift
//  NotesApp
//
//  Created by Сашок on 13.05.2022.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

protocol SynchronizationPresentationLogic {
    func presentSynchronizationStatus(response: Synchronization.UpdateStatus.Response)
}

class SynchronizationPresenter: SynchronizationPresentationLogic {
    weak var viewController: SynchronizationDisplayLogic?
    
    func presentSynchronizationStatus(response: Synchronization.UpdateStatus.Response) {
        let viewModel = Synchronization.UpdateStatus.ViewModel(
            synchronizationEnabled: response.synchronizationEnabled,
            statusText: response.synchronizationEnabled ? "Синхронизация включена" : "Синхронизация выключена",
            systemImageName: response.synchronizationEnabled ? "checkmark.icloud" : "xmark.icloud"
        )
        
        viewController?.displaySynchronizationStatus(viewModel: viewModel)
    }
}