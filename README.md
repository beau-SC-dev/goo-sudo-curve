# GOO-based SudoSwap Curve

SudoSwap curve based on GOO (Gradual Ownership Optimization) Issuance. Read the [GOO whitepaper here](https://www.paradigm.xyz/2022/09/goo).

The formula for going backwards on the curve is:
$$sellPrice = { [+-4 \sqrt{b} sqrt{m} t + 4b + mt^2] / 4}$$
where m = emissionMultiple, b = currentBalanceWad, and t = time to scale backwards, scaled to 1e18

### Important Notes
- This version is only built for "TOKEN" pool types, as it only supports buying.
- Selling will be necessary, otherwise, by the GOO design, prices will get a bit crazy as NFTs are only bought.
  - Could "go backwards" on the curve by solving
  $$c = { {mt^2 \over 4} + i + t \sqrt{mi} }$$
  - For i, where t is numItems scaled to 1e18 and c is the curve's current "GOO balance", and then calculating sell price based on that. 
  - I started adding a function for this to LibGOO, but didn't finish.
- Not gas optimized, was written quickly. 
  - Should try to go from summation using for loop to a closed form version, among other things.
- There's a lot of other design choices that could be used here:
  - Making emission multiple a configurable parameter (spotPrice or delta) rather than a scaler
  - Creating a custom pair type for Gobblers that directly uses the Gobblers' emission multiple

### Design
- This version is intended to hold some amount of NFTs that can be bought by users
- The configurable parameters are: 
  - spotPrice ("current GOO balance")
  - delta ("scaler", which is used to divide pricing down (or up) to a reasonable level depending on preference)
- Emission multiple is set to a constant 1

### Pricing Curve
Curve for g(t) (GOO at time t) where emission multiple = 1, initial balance = 1:
![alt text](https://github.com/beau-SC-dev/goo-sudo-curve/blob/main/images/curve.png)

### Setup

```sh
git clone https://github.com/beau-SC-dev/goo-sudo-curve.git
cd goo-issuance
```
Install lib/forge=std and lib/solmate as well

### Run Tests

```sh
forge test
```
