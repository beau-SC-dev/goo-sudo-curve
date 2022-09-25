# GOO-based SudoSwap Curve

SudoSwap curve based on GOO (Gradual Ownership Optimization) Issuance. Read the [GOO whitepaper here](https://www.paradigm.xyz/2022/09/goo).

### Update
I've added selling. To enable this, we "go backwards" on the GOO curve by a unit of time. Time, here, is replaced with number of items bought/sold, scaled to 1e18.

The formula for going backwards on the curve (calculated by solving the GOO equation for 'initial GOO') is:
$$sellPrice = { {\pm 4 \sqrt{b} \sqrt{m} t + 4b + mt^2} \over 4}$$
- where m = emissionMultiple, b = currentBalanceWad, and t = time to scale backwards, scaled to 1e18.
We use minus rather than plus, because...well, because it works in testing, and I haven't really considered why yet.

### Important Notes
- Not gas optimized, was written quickly. 
  - Main fix: Should try to go from summation using for loop to a closed form version.
- There's a lot of other design choices that could be used here:
  - Making emission multiple a configurable parameter (spotPrice or delta) rather than a scaler.
  - Creating a custom pair type for Gobblers that directly uses the Gobblers' emission multiple.

### Design
- Pricing is based on the GOO mechanism's curve.
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
