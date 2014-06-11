require "debugger"

def consolidate_cart(cart: [])
  container = {}
  cart.each do |item_hash|
    item_hash.each do |name, value_hash|
      unless value_hash[:count]
        value_hash[:count] = 0
      end
      value_hash[:count] += 1
      container[name] = value_hash
    end
  end
  container 
end

def apply_coupons(cart: [], coupons: [])
  couponed_items= {}
  coupons.each do |coupon_hash|
    cart.each do |name, item_hash|
      if name == coupon_hash[:item] && item_hash[:count] >= coupon_hash[:num]
        item_hash[:count] = item_hash[:count] - coupon_hash[:num]
        new_name = coupon_hash[:item] + " w/coupon"
        couponed_items[new_name] = { :price => coupon_hash[:cost], :count => 1, :clearance => :false }
      end
    end
  end
  cart.merge(couponed_items)

  #{
  #  {"BEER"=>{:price=>13.0, :clearance=>false, :count=>-1}, 
  #  {"BEER w/coupon"=>{:price=>20.0, :count=>2, :clearance=>:false}
  #}

end

def checkout(cart: [], coupons: [])
  call_later = cart
  cart = consolidate_cart(cart: cart)
  final_cart = apply_coupons(cart: cart, coupons: coupons)
  total = 0
  final_cart.each do |name, item_hash|
    if item_hash[:clearance]
      item_hash[:price] = item_hash[:price] - (item_hash[:price] * 0.20)
    end
    total += item_hash[:price] * item_hash[:count]
  end
  if total > 100
    total = total - ( total * 0.10 )
  end
  # debugger

  total
end
