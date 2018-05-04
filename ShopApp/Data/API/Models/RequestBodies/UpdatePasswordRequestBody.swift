//
//  UpdatePasswordRequestBody.swift
//  ShopApp
//
//  Created by Radyslav Krechet on 4/20/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation

struct UpdatePasswordRequestBody: RequestBody {
    var currentPassword: String
    var newPassword: String
}
