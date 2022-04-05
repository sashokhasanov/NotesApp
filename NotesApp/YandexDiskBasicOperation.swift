//
//  YandexDiskBasicOperation.swift
//  NotesApp
//
//  Created by Сашок on 05.04.2022.
//

import Foundation

class YandexDiskBasicOperation: AsyncOperation {
    let baseUrl = "https://cloud-api.yandex.net/v1/disk/resources"
    
    var accessToken: String? {
        YandexDiskTokenProvider.shared.getAuthToken()
    }
}
