# Guide to Solving and Reviewing Green Grocer

## `consolidate_cart`

When reading the `consolidate_cart` method spec, we are looking to understand the setup the method will be run against.

`spec/grocer_spec.rb:24`

```ruby
avocado = items.find { |item| item['AVOCADO'] }
kale = items.find { |item| item['KALE'] }
cart = [avocado, avocado, kale]
```

There's a cart with 2 avocados and 1 kale, our `consolidate_cart` method should return a hash that represents the cart. If we look at the `expected_consolidated_cart`, the desired outcome, we can see the structure of this hash.

```ruby
expected_consolidated_cart = {
  "AVOCADO" => {
    :price => 3.00,
    :clearance => true,
    :count => 2
  },
  "KALE" => {
    :price => 3.00,
    :clearance => false,
    :count => 1
  }
}
```

It's a nested hash and if we think about the semantics of it, the meta data, it has an implied structure of:

```
ITEM_NAME
  ITEM_SUMMARY
```

Each top-level key is the item's name and the value of the item is the summary of hash of this item in a cart.

This structure dictates the algorithm we'll use to build this method. Given an array of non-unique items, the method must iterate over each item and either add it to the cart hash, or simply increment the item's count. The psuedo-code might be:

```
setup the empty consolidated_cart hash
for each item in the cart array
  check to see if the item's name already exists as a key in the consolidated_cart
  if it does,
    simply increment the count of the item
  if it does not,
    initialize the item in the consolidated cart
```

We'll be using the presence of the item's name as a key to know whether or not we've seen it before. Often in programming we're looking for data or events we can easily monitor, measure, or instrument, in order to know how our program should behave.

With that algorithm, an implementation of the method might look like:

```ruby
def consolidate_cart(cart:[])
  consolidated_cart = {}
  cart.each do |item|
    item_name = item.keys.first
    if consolidated_cart[item_name]
      consolidated_cart[item_name][:count] += 1
    else
      consolidated_cart[item_name] = {
        price: item[item_name][:price],
        clearance: item[item_name][:clearance],
        count: 1
      }
    end
  end
  consolidated_cart
end
```

If we wanted to be super fancy, we could remove the dependency of maintaining a local return variable, `consolidated_cart` and encapsulate that object into a higher-level iterator, `each_with_object`. This method will inject an object into the iteration, passing it along with each loop so that we can modify it, and then finally, the method returns this object.

```ruby
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
```

## `checkout`

This method implements complex business logic and it's describe block provides a good summary of what we need to accomplish.

Run `rspec --format=documentation`:
```
checkout
  adds 20% discount to items currently on clearance
  considers coupons
  considers coupons and clearance discounts
  charges full price for items that fall outside of coupon count
  only applies coupons that meet minimum amount
  applies 10% discount if cart over $100
  using the consolidate_cart method during checkout
    consolidates cart before calculation
```

There's a lot there and it seems that there is a bunch of logic related to discounting, whether through coupons, clearance, or a discount for over $100.

It seems a logical place to start would be to first get the method to behave in the simplest manner possible, ignore everything and just tally a final price. Once we have that base functionality, the simplest use-case working, we can start implementing the more complex logic.

### Version 1 of `checkout` - Base functionality.

We're most interested in the following test when approaching this first version, or MVP, if that's your thing.

```
checkout
  using the consolidate_cart method during checkout
    consolidates cart before calculation
```

It sets up a simple specification first, that we should take advantage of our working consolidate_cart method and first consolidate the cart.

