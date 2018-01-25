//
//  TargetedExtension.swift
//  MobileFluidSimulation
//
//  Created by Haga Masaki on 26/09/2017.
//  Copyright © 2017 Haga Masaki. All rights reserved.
//

import Foundation

public struct MFSExtension<Base> {
    public let base: Base
    
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol MFSExtensionCompatible {
    associatedtype CompatibleType
    
    static var mfs: MFSExtension<CompatibleType>.Type { get set }
    
    var mfs: MFSExtension<CompatibleType> { get set }
}

extension MFSExtensionCompatible {
    public static var mfs: MFSExtension<Self>.Type {
        get {
            return MFSExtension<Self>.self
        }
        set {
        }
    }
    
    public var mfs: MFSExtension<Self> {
        get {
            return MFSExtension(self)
        }
        set {
        }
    }
}

import class Foundation.NSObject

extension NSObject: MFSExtensionCompatible { }

