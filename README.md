
# Deepbook
env: testnet 
Sau khi chạy lệnh:
```
sui client publish --gas-budget 100000000 --json
```


Ta sẽ được các kết quả và nên tạo một danh sách env variable như sau
```
export PACKAGE_ID=0x205dfc1894d23261cf0f99ad5f302639285a7882d0745abf70e1b1524400d716  


//  pay the fee for the pool creatio
export SUI_FEE_COIN_ID=0x917b5620f106d5f4cc9cfc663aa6bee307083382dbb7e501745d641215b1fa5e

export ACCOUNT_ID1=0x02b951e9357d5d6da406803e3bcacd2596808ffe733d40a171a8ea816037d1b0

export CLOCK_OBJECT_ID=0x6

# BASE coin type và quote
export BASE_COIN_TYPE=0x2::sui::SUI

export QUOTE_COIN_TYPE=0x205dfc1894d23261cf0f99ad5f302639285a7882d0745abf70e1b1524400d716::tdtc::TDTC


export TDTC_TREASURY_CAP_ID=0xb3c4c1d91fee73993bb448e6372945fb2db10709d82c20f5920180a1625b8cd5

export TDTC_COINMETADATA_ID=0x6ac1a8c15897aac4ca03ea15ca038b3041ea10b10896b714f61fbc1097eee74e

```

# Function create Pool 
CLI: Nhớ sử dụng lệnh `sui client gas --json` để lấy được object id gas của bạn 
Để có được `SUI_FEE_COIN_ID` ta sẽ cần 100 sui
Yêu cầu là phải có 100 sui thì mình có một trick giúp bạn lấy được 100 sui nhanh chóng. Đầu tiên bạn tạo một file `test.sh` và đặt nội dung trong đó là 
```
for i in $(seq 1 120); do sui client faucet --address 0x8e94820852fb723b6218c9fc1180a4542203c23aa0f752c5a61f61de5486035d; done
```

nếu bạn sử dụng binaries cho testnet hoặc devnet thì: 
```
for i in $(seq 1 120); do $SUI_TESTNET_HOME/sui-ubuntu-x86_64 client faucet --address 0x8e94820852fb723b6218c9fc1180a4542203c23aa0f752c5a61f61de5486035d; done
```
120 là 120 sui mà bạn muốn nhận được và address thì bạn nên lấy address trên wallet ở trên suiet của bạn để khi faucet thì tiền sẽ truyền vào đó.Sau khi có tiền sui trên wallet thì có thể send lại vào trong sui address ở terminal của bạn. Lúc này bạn sẽ có một object chứa 120 sui. 


Sau khi có object chứa 100 sui ta có thể pool mới với tham số truyền vào là args object id có 100 sui 
```
sui client call --package $PACKAGE_ID --module book --function new_pool --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --args $SUI_FEE_COIN_ID --gas-budget 10000000
```

Kết quả là sau khi tạo xong pool, ta sẽ nhận được 
```
export PoolOwnerCap_id=0xa5c9e2c7b068662cf9efc215169ab824be38fe52c11f12f405cde56d6ee5c7bb

export POOL_ID=0x4aa35954ba647640794beb67321e1d390fa86e67f6b1ed79081c72265e12493c

```

hay tổng quát sẽ là `0xdee9::clob_v2::Pool<$BASE_COIN_TYPE, $QUOTE_COIN_TYPE>`
ta sẽ đặt tên object_id là 
```
export POOL_ID=
```


Trong trường hợp ta muốn custom `REFERENCE_TAKER_FEE_RATE` và  `REFERENCE_MAKER_REBATE_RATE` thì ta có thể dùng function `create_customized_pool` : 
```
public fun create_customized_pool<BaseAsset, QuoteAsset>(
        tick_size: u64,
        lot_size: u64,
        taker_fee_rate: u64,
        maker_rebate_rate: u64,
        creation_fee: Coin<SUI>,
        ctx: &mut TxContext,
    )
```


Tạo account (### Create custodian account)
```
 sui client call --package $PACKAGE_ID  --module book --function new_custodian_account  --gas-budget 10000000000
```

và ta sẽ nhận được account có kiểu object type là  `0xdee9::custodian_v2::AccountCap` và export object id của nó vào Accountcap

```
export ACCOUNT1_CAP=0x02b951e9357d5d6da406803e3bcacd2596808ffe733d40a171a8ea816037d1b0                            
```

Sau đấy ta có thể mint thêm token TDTC vào trong account cap này 
```
sui client call --function mint --module tdtc --package $PACKAGE_ID  --args $TDTC_TREASURY_CAP_ID 10000000000 $ACCOUNT_ID1 --gas-budget 10000000 
```

```
export ACCOUNT1_TDTC_OBJECT_ID=0x84ec822d728cac2ed4cf5aa8e491d496f9ac4348593aa71e109494c9d63b8ac9
```
### Make deposits
Now we need to make deposits (both base and quote) to `ACCOUNT1_CAP_ID` (for limit orders). First, prepare the `BASE_COIN_ID` variable by assigning the output of `sui client gas`
```
 sui client call --package $PACKAGE_ID  --module book --function make_base_deposit  --args $POOL_ID $BASE_COIN_ID $ACCOUNT1_CAP --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --gas-budget 10000000000
```


 deposit the quote coin:
```
sui client call --package $PACKAGE_ID  --module book --function make_quote_deposit  --args $POOL_ID $ACCOUNT1_TDTC_OBJECT_ID $ACCOUNT1_CAP --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --gas-budget 10000000000 --json
```



# Place order 
```
sui client call --package $PACKAGE_ID  --module book --function place_base_market_order  --args $POOL_ID $ACCOUNT1_CAP $SUI_COIN_ID 942 "true" $CLOCK_OBJECT_ID --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --gas-budget 10000000
```


# swap
```
sui client call --package $PACKAGE_ID  --module book --function swap_exact_base_for_quote  --args $POOL_ID 40 $ACCOUNT1_CAP 1500 $BASE_COIN_ID $CLOCK_OBJECT_ID --type-args $BASE_COIN_TYPE $QUOTE_COIN_TYPE --gas-budget 10000000
```
