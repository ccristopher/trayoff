//
//  RetainerWidgetBundle.swift
//  TrayOff
//
//  Created by Cristopher Encarnacion.
//  Copyright © 2025 Cristopher Encarnacion. All rights reserved.
//

import WidgetKit
import SwiftUI

/// Widget bundle containing all TrayOff widgets.
@available(iOS 26.0, *)
@main
struct RetainerWidgetBundle: WidgetBundle {
    var body: some Widget {
        RetainerWidget()
        RetainerActivityWidget()
    }
}
