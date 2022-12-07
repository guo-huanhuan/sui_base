// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

module base::baseCoin {
    use sui::coin::{Self,Coin ,TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::pay::{Self};
    use sui::sui::{SUI};
    use sui::url::{Url};
    use std::option::{Self};
    use base::launching;
    use base::util::{LaunchingCoin};
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
        let icon_url=option::none<Url>();
        let (treasury_cap,coinmeta_data) = coin::create_currency<BASECOIN>(witness, decimals,symbol ,name,description,icon_url, ctx);
        transfer::transfer(treasury_cap, tx_context::sender(ctx));
        transfer::freeze_object(coinmeta_data);
    }

    public entry fun create_sales(treasury_cap:&mut TreasuryCap<BASECOIN>,launchingCoin:&mut LaunchingCoin, amount: u64,coin: Coin<SUI>, ctx: &mut TxContext) {
        // coin::mint_and_transfer (&mut treasury_cap, amount, recipient, ctx);
        let coin_value=coin::mint(treasury_cap, amount, ctx);
        // transfer::freeze_object(treasury_cap);
        launching::create_launching(launchingCoin,coin_value,coin,ctx);
    }
    public entry fun transfer( c: &mut Coin<BASECOIN>, amount: u64, recipient: address, ctx: &mut TxContext){
        pay::split_and_transfer(c,amount,recipient,ctx);
    }
    //        #[test]
    //   fun test1(){
    //     use sui::test_scenario::{Self};
    //     let admin = @0xf116a4ecb0f483cadc1b75f8770f096befa45ab9;
    //     let scenario = test_scenario::begin(admin);
    //     { 
    //       let ll=LaunchingBase<BASECOIN>{
    //             begin_date: 1,
    //             end_date: 2,
    //             proportion:3,
    //             is_processing:true,
    //       };
    //     //   let kk=LaunchingBase<BASECOIN>{
    //     //         begin_date: 1,
    //     //         end_date: 2,
    //     //         proportion:3,
    //     //         is_processing:true,
    //     //   };
    //     //   let b=bag::new(test_scenario::ctx(&mut scenario));
    //     //   bag::add(&mut b,ll,0);
    //     //   let u:& u64=bag::borrow(&mut b,ll);
    //     //   debug::print(u);

    //     //   bag::add(&mut b,kk,1);

    //     //   transfer::transfer(b, admin);
    //     };
    //     test_scenario::end(scenario); 
    //  }
}