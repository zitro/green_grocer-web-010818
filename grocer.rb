def consolidate_cart(cart:[])
	cart.each_with_object({}) do |item, consolidated|
		item_name = item.keys.first
		if consolidated[item_name]
			consolidated[item_name][:count] += 1
		else
			consolidated[item_name] = {
				price: item[item_name][:price],
				clearance: item[item_name][:clearance],
				count: 1
			}
		end
	end
end

def checkout(cart: [], coupons: [])
	new_cart = consolidate_cart(cart: cart)
	total = 0
	new_cart.each_pair do |item, properties|
		sub_total = 0
		if coupon = coupons.find {|coupon| coupon[:item] == item }
			if coupon[:num] <= properties[:count]
				properties[:count] -= coupon[:num]
				sub_total += coupon[:cost]
			end
		end

		sub_total += properties[:price] * properties[:count]
		if properties[:clearance]
			sub_total = sub_total - (sub_total * 0.20)
		end

		if sub_total > 100
			sub_total = sub_total - (sub_total * 0.10)
		end

		total += sub_total
	end
	total
end
