module base::event{
    use std::string::String;
    use sui::event::emit;
    friend base::money;
    struct AddCoinEvent has copy, drop {
        decimals: u8,
        supply:u64,
        name: String,
        symbol: String,
        description: String,
        icon_url: String,
        pay_address:address
    }
     public(friend) fun add_coin_event(
        decimals: u8,
        supply:u64,
        name: String,
        symbol: String,
        description: String,
        icon_url: String,
        pay_address:address
    ) {
        emit(
            AddCoinEvent {
                decimals,
                supply,
                name,
                symbol,
                description,
                icon_url,
                pay_address
            }
        )
    }
}