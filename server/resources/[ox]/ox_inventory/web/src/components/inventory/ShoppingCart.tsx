import React, { useState, useCallback } from 'react';
import { useDrop } from 'react-dnd';
import { useAppSelector, useAppDispatch } from '../../store';
import { fetchNui } from '../../utils/fetchNui';
import { Items } from '../../store/items';
import { Locale } from '../../store/locale';
import { SlotWithItem } from '../../typings';

interface CartItem {
  slot: number;
  name: string;
  price: number;
  count: number;
  currency?: string;
  metadata?: any;
}

const ShoppingCart: React.FC = () => {
  const [cartItems, setCartItems] = useState<CartItem[]>([]);
  const [paymentMethod, setPaymentMethod] = useState<'cash' | 'bank'>('cash');
  const rightInventory = useAppSelector((state) => state.inventory.rightInventory);
  const dispatch = useAppDispatch();

  const [{ isOver }, drop] = useDrop({
    accept: 'SLOT',
    drop: (item: any) => {
      if (rightInventory.type === 'shop' && item.inventory === 'shop') {
        const shopItem = rightInventory.items.find((i) => i.slot === item.item.slot) as SlotWithItem;
        if (shopItem && shopItem.price) {
          const existingItem = cartItems.find((cartItem) => cartItem.slot === item.item.slot);
          
          if (existingItem) {
            setCartItems(prev => 
              prev.map(cartItem => 
                cartItem.slot === item.item.slot 
                  ? { ...cartItem, count: cartItem.count + 1 }
                  : cartItem
              )
            );
          } else {
            setCartItems(prev => [...prev, {
              slot: item.item.slot,
              name: item.item.name,
              price: shopItem.price || 0,
              count: 1,
              currency: shopItem.currency,
              metadata: item.item.metadata
            }]);
          }
        }
      }
    },
    collect: (monitor) => ({
      isOver: monitor.isOver(),
    }),
  });

  const removeFromCart = (slot: number) => {
    setCartItems(prev => prev.filter(item => item.slot !== slot));
  };

  const updateCartItemCount = (slot: number, count: number) => {
    if (count <= 0) {
      removeFromCart(slot);
    } else {
      setCartItems(prev => 
        prev.map(item => 
          item.slot === slot ? { ...item, count } : item
        )
      );
    }
  };

  const getTotalPrice = () => {
    return cartItems.reduce((total, item) => total + (item.price * item.count), 0);
  };

  const handlePurchase = async () => {
    if (cartItems.length === 0) return;

    try {
      await fetchNui('purchaseItems', {
        items: cartItems,
        paymentMethod,
        totalPrice: getTotalPrice()
      });
      
      setCartItems([]);
    } catch (error) {
      // Purchase failed
    }
  };

  const clearCart = () => {
    setCartItems([]);
  };

  const getItemLabel = (itemName: string, metadata?: any) => {
    return metadata?.label || Items[itemName]?.label || itemName;
  };

  const getCurrencySymbol = (currency?: string) => {
    if (currency === 'money' || !currency) return Locale.$ || '$';
    return currency;
  };

  if (rightInventory.type !== 'shop') return null;

  return (
    <div 
      ref={drop}
      className={`shopping-cart ${isOver ? 'cart-drag-over' : ''}`}
    >
      <div className="cart-header">
        <h3>Shopping Cart</h3>
        <div className="cart-header-right">
          <div className="cart-total">
            Total: {getCurrencySymbol()}{getTotalPrice().toLocaleString()}
          </div>
          {cartItems.length > 0 && (
            <button 
              className="cart-clear-btn"
              onClick={clearCart}
              title="Clear Cart"
            >
              Clear
            </button>
          )}
        </div>
      </div>

      <div className="cart-items">
        {cartItems.length === 0 ? (
          <div className="cart-empty">
            Drag items here to add to cart
          </div>
        ) : (
          cartItems.map((item) => (
            <div key={item.slot} className="cart-item">
              <div className="cart-item-image">
                <img src={`nui://ox_inventory/web/images/${item.name}.png`} />
              </div>
              <div className="cart-item-info">
                <span className="cart-item-name">
                  {getItemLabel(item.name, item.metadata)}
                </span>
                <span className="cart-item-price">
                  {getCurrencySymbol(item.currency)}{item.price.toLocaleString()} each
                </span>
              </div>
              <div className="cart-item-controls">
                <button 
                  className="cart-quantity-btn"
                  onClick={() => updateCartItemCount(item.slot, item.count - 1)}
                >
                  -
                </button>
                <span className="cart-quantity">{item.count}</span>
                <button 
                  className="cart-quantity-btn"
                  onClick={() => updateCartItemCount(item.slot, item.count + 1)}
                >
                  +
                </button>
                <button 
                  className="cart-remove-btn"
                  onClick={() => removeFromCart(item.slot)}
                >
                  ×
                </button>
              </div>
            </div>
          ))
        )}
      </div>

      {cartItems.length > 0 && (
        <div className="cart-footer">
          <div className="payment-methods">
            <button
              className={`payment-method-btn ${paymentMethod === 'cash' ? 'active' : ''}`}
              onClick={() => setPaymentMethod('cash')}
            >
              Cash
            </button>
            <button
              className={`payment-method-btn ${paymentMethod === 'bank' ? 'active' : ''}`}
              onClick={() => setPaymentMethod('bank')}
            >
              Bank
            </button>
          </div>
          <button 
            className="cart-purchase-btn"
            onClick={handlePurchase}
          >
            Purchase
          </button>
        </div>
      )}
    </div>
  );
};

export default ShoppingCart;
