module base::money{
    use sui::sui::{SUI};
    use sui::tx_context::{Self,TxContext};
    use sui::object::{Self,UID};
    use sui::coin::{Self,Coin};
    use sui::transfer;
    use std::string::String;
    use base::event;
    use base::util;
    public entry fun pay_money(
        decimals: u8,
        supply:u64,
        name: String,
        symbol: String,
        description: String,
        icon_url: String,
        sui: Coin<SUI>,
        ctx: &mut TxContext){
        util::verify_coin(&sui);
        //pay to admin
        transfer::transfer(sui, @admin_address);
        event::add_coin_event(
            decimals,
            supply,
            name,
            symbol,
            description,
            icon_url,
            tx_context::sender(ctx)
        );
    }
}