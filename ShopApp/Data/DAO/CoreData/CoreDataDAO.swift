//
//  CoreDataDAO.swift
//  ShopApp
//
//  Created by Evgeniy Antonov on 11/8/17.
//  Copyright © 2017 Evgeniy Antonov. All rights reserved.
//

import CoreStore
import ShopApp_Gateway

class CoreDataDAO: DAO {
    func getCartProductList() -> [CartProduct] {        
        let items: [CartProductEntity]? = CoreStore.fetchAll(From<CartProductEntity>())
        return items?.map({ CoreDataCartProductAdapter.adapt(item: $0)! }) ?? [CartProduct]()
    }
    
    func addCartProduct(cartProduct: CartProduct, callback: @escaping RepoCallback<CartProduct>) {
        let predicate = getPredicate(with: cartProduct.productVariant?.id)
        CoreStore.perform(asynchronous: { (transaction) in
            var item = transaction.fetchOne(From<CartProductEntity>(), Where(predicate))
            if item != nil {
                let newQuantity = Int(item?.quantity ?? 0) + cartProduct.quantity
                item?.quantity = Int64(newQuantity < kCartProductQuantityMax ? newQuantity : kCartProductQuantityMax)
            } else {
                item = transaction.create(Into<CartProductEntity>())
                CartProductEntityUpdateService.update(item, with: cartProduct, transaction: transaction)
            }
        }, completion: { (result) in
            switch result {
            case .success:
                let item = CoreStore.fetchOne(From<CartProductEntity>(), Where(predicate))
                callback(CoreDataCartProductAdapter.adapt(item: item), nil)
            case .failure(let error):
                callback(nil, RepoError(with: error))
            }
        })
    }
    
    func deleteProductFromCart(with productVariantId: String?, callback: @escaping RepoCallback<Bool>) {
        let predicate = getPredicate(with: productVariantId)
        CoreStore.perform(asynchronous: { (transaction) in
            let item: CartProductEntity? = transaction.fetchOne(From<CartProductEntity>(), Where(predicate))
            transaction.delete(item)
        }, completion: { (result) in
            switch result {
            case .success:
                callback(true, nil)
            case .failure(let error):
                callback(false, RepoError(with: error))
            }
        })
    }
    
    func deleteAllProductsFromCart(with callback: @escaping RepoCallback<Bool>) {
        CoreStore.perform(asynchronous: { (transaction) in
            transaction.deleteAll(From<CartProductEntity>())
        }, completion: { (result) in
            switch result {
            case .success:
                callback(true, nil)
            case .failure(let error):
                callback(false, RepoError(with: error))
            }
        })
    }
    
    func changeCartProductQuantity(with productVariantId: String?, quantity: Int, callback: @escaping RepoCallback<CartProduct>) {
        let predicate = getPredicate(with: productVariantId)
        CoreStore.perform(asynchronous: { (transaction) in
            let item: CartProductEntity? = transaction.fetchOrCreate(predicate: predicate)
            item?.quantity = Int64(quantity)
        }, completion: { (result) in
            switch result {
            case .success:
                let item = CoreStore.fetchOne(From<CartProductEntity>(), Where(predicate))
                callback(CoreDataCartProductAdapter.adapt(item: item), nil)
            case .failure(let error):
                callback(nil, RepoError(with: error))
            }
        })
    }
    
    private func getPredicate(with productVariantId: String?) -> NSPredicate {
        let variantId = productVariantId ?? ""
        return NSPredicate(format: "productVariant.id == %@", variantId)
    }
}
