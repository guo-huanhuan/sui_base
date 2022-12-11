// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module base::baseCoin {
        use sui::coin::{Self,Coin ,TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::pay::{Self};
    use sui::sui::{SUI};
    use sui::url::{Self,Url};
    use std::option::{Self};
    use base::launching;
    use base::bean::{LaunchingCoin};
    //The total amount of coins is wrong
    const SUPPLY_STATE: u64 = 1;
    /// The type identifier of coin. The coin will have a type
    /// tag of kind: `Coin<package_object::mycoin::MYCOIN>`
    /// Make sure that the name of the type matches the module's name.
    struct BASECOIN has drop {}
    // Module initializer is called once on module publish. A treasury
    // cap is sent to the publisher, who then controls minting and burning
    fun init(witness: BASECOIN, ctx: &mut TxContext) {
        let decimals=6;
        let symbol=b"BASECOIN";
        let name=b"BASECOIN";
        let description=b"BASECOIN";
        let icon_url=option::some<Url>(url::new_unsafe_from_bytes(b"BASECOIN"));
        let (treasury_cap,coinmeta_data) = coin::create_currency<BASECOIN>(witness, decimals,symbol ,name,description,icon_url, ctx);
        transfer::transfer(treasury_cap, tx_context::sender(ctx));
        transfer::freeze_object(coinmeta_data);
    }

    public entry fun create_sales(treasury_cap:&mut TreasuryCap<BASECOIN>,launchingCoin:&mut LaunchingCoin, amount: u64,coin: Coin<SUI>,pay_address:address, ctx: &mut TxContext) {
        // coin::mint_and_transfer (&mut treasury_cap, amount, recipient, ctx);
        let coin_value=coin::mint(treasury_cap, amount, ctx);
        // transfer::freeze_object(treasury_cap);
        launching::create_launching(launchingCoin,coin_value,coin,pay_address,ctx);
    }
    public entry fun transfer( c: &mut Coin<BASECOIN>, amount: u64, recipient: address, ctx: &mut TxContext){
        pay::split_and_transfer(c,amount,recipient,ctx);
    }
}