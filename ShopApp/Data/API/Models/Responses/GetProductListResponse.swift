//
//  GetProductListResponse.swift
//  ShopApp
//
//  Created by Radyslav Krechet on 4/30/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation

struct GetProductListResponse: PaginationResponse {
    var items: [GetProductResponse]
    var totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
    }
}
