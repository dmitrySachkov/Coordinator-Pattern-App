//
//  Navigator.swift
//  Coordinator Pattern App
//
//  Created by Dmitry Sachkov on 14.01.2026.
//

import SwiftUI

typealias Coordinatable = View & Identifiable & Hashable & Equatable

@Observable
class Navigator<CoordinatorPage: Coordinatable> {
    
    var path: [CoordinatorPage] = []
    var sheet: CoordinatorPage?
    var sheetParam: Set<PresentationDetent> = []
    var fullScreenCover: CoordinatorPage?
    
    enum PushType {
        case link
        case sheet
        case fullScreenCover
    }
    
    enum PopType {
        case link(_ last: Int)
        case sheet
        case fullScreenCover
    }
    
    func push(_ page: CoordinatorPage,
              type: PushType = .link,
              detent: Set<PresentationDetent> = []) {
        
        switch type {
        case .link:
            path.append(page)
        case .sheet:
            sheetParam = detent
            sheet = page
        case .fullScreenCover:
            fullScreenCover = page
        }
    }
    
    func pop(type: PopType = .link(1)) {
        switch type {
        case .link(let last):
            path.removeLast(last)
        case .sheet:
            sheet = nil
        case .fullScreenCover:
            fullScreenCover = nil
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func setPath(_ destination: CoordinatorPage) {
        path.append(destination)
    }
}


