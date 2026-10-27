package com.tap.Dao;

import java.util.List;
import com.tap.model.Cart;

public interface CartDao {

    void addCart(Cart cart);

    Cart getCart(int cartId);

    List<Cart> getAllCarts();

    List<Cart> getCartsByUserId(int userId);

    void updateCart(Cart cart);

    void deleteCart(int cartId);
}