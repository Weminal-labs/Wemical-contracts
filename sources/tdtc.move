module deepbook_contract::tdtc { 
    use sui::coin::{Coin, TreasuryCap, Self};
    use std::option;
    use sui::transfer;
    use sui::tx_context::{TxContext, Self};

    struct TDTC has drop{}


    #[allow(unused_function)]
    fun init(witness: TDTC, ctx: &mut TxContext) {
        let (treasury, metadata) = coin::create_currency(witness, 6, b"TDTC", b"weTDT coin", b"weTDT coin created by weminal labs", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx))
    }   

    public entry fun mint(
        treasury_cap: &mut TreasuryCap<TDTC>,  amount: u64, recipient: address, ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(treasury_cap, amount, recipient, ctx)
    }

    public entry fun burn(treasury_cap: &mut TreasuryCap<TDTC>, coin: Coin<TDTC>) {
        coin::burn(treasury_cap, coin);
    }


}