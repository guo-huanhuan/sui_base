module base::cashbox{
    use base::util;
    use sui::tx_context::{Self,TxContext};
    use sui::coin::{Self,Coin};
    use sui::sui::{SUI};
    use sui::object::{Self,UID};
    use base::vec_map::{Self,VecMap};
    use sui::transfer;
    // Activity initialization state
    const INIT_STATUS: u64 = 0;
    // activity in status
    const SALE_STATUS: u64 = 1;
    // activity completion status
    const COMPLETE_STATUS: u64 = 2;
    // activity refund status
    const REFUND_STATUS: u64 = 3;
    struct CreatorCap<phantom T>  has key{
        id: UID,
    }
    struct CoinValue<phantom T> has store,drop{
        sui_value:u64,
        coin_value:u64,
    }
    struct CoinSafe<phantom T> has key{
        id: UID,
        coin_value:Coin<T>,
        sui_value:Coin<SUI>,
        form: VecMap<address,CoinValue<T>>,
        status:u64,
        coin_mix:u64,
        coin_max:u64,
    }
    public fun create_coinSafe<T>(coin:Coin<T>,ctx: &mut TxContext){
        let coinSafe=CoinSafe<T>{
            id: object::new(ctx),
            coin_value:coin,
            sui_value:coin::zero<SUI>(ctx),
            form:vec_map::empty<address,CoinValue<T>>(),
            status:0,
            coin_mix:0,
            coin_max:0,
        };
        transfer::share_object(coinSafe);
    }
    public fun create_creatorCap<T>(sender:address,ctx: &mut TxContext){
        transfer::transfer(CreatorCap<T>{id: object::new(ctx)},sender);
    }
    public fun updat_coinSafe<T>(
        _:&mut CreatorCap<T>,
        coinSafe:&mut CoinSafe<T>,
        coin_mix:u64,
        coin_max:u64){
        util::verify_coinsafe_status(coinSafe.status,INIT_STATUS);
        coinSafe.coin_max=coin_mix;
        coinSafe.coin_max=coin_max;
    }
    public fun start_launchinge<T>(
        _:&mut CreatorCap<T>,
        coinSafe:&mut CoinSafe<T>){
        util::verify_coinsafe_status(coinSafe.status,INIT_STATUS);
        coinSafe.status=SALE_STATUS;
    }

    public fun join_coinSafe<T>(coinSafe:&mut CoinSafe<T>,sui:Coin<SUI>,coin_value:u64,ctx: &mut TxContext){
        let sender =tx_context::sender(ctx);
        let sui_value=coin::value<SUI>(&sui);
        if(vec_map::contains<address,CoinValue<T>>(&coinSafe.form,& sender)){
            let coinValue=vec_map::get_mut<address,CoinValue<T>>(&mut coinSafe.form,& sender);
            coinValue.sui_value=sui_value;
            coinValue.coin_value=coin_value;
        }else{
            let coinValue=CoinValue<T>{sui_value:sui_value,coin_value:coin_value};
            vec_map::insert(&mut coinSafe.form,sender,coinValue);
        };
        coin::join(&mut coinSafe.sui_value,sui);
    }

    public entry fun refund_coinSafe<T>(coinSafe:&mut CoinSafe<T> , ctx: &mut TxContext){
        let sender =tx_context::sender(ctx);
        util::verify_coinsafe_from(vec_map::contains<address,CoinValue<T>>(&coinSafe.form,& sender));
        let coinValue=vec_map::get_mut<address,CoinValue<T>>(&mut coinSafe.form,& sender);
        let sender_sui=coin::split<SUI>(&mut coinSafe.sui_value , coinValue.sui_value , ctx);
        vec_map::remove<address,CoinValue<T>>(&mut coinSafe.form,& sender);
        transfer::transfer(sender_sui,sender);
    }
    //        #[test]
    //   fun test1(){
    //     use sui::test_scenario::{Self};
    //     use std::debug;
    //     let admin = @0xf116a4ecb0f483cadc1b75f8770f096befa45ab9;
    //     let scenario = test_scenario::begin(admin);
    //     { 
    //         let ctx= test_scenario::ctx(&mut scenario);
    //         let form= vec_map::empty<address,CoinValue<u64>>();
    //         let coinValue=CoinValue<u64>{sui_value:0,coin_value:0};
    //         vec_map::insert(&mut form,admin,coinValue);
    //         if(vec_map::contains<address,CoinValue<u64>>(&form,& admin)){
    //             let c=vec_map::get_mut<address,CoinValue<u64>>(&mut form,& admin);
    //             c.sui_value=10;
    //             c.coin_value=20;
    //             // vec_map::insert(&mut form,admin,*c);
    //         }else{
    //             let c=CoinValue<u64>{sui_value:10,coin_value:10};
    //             vec_map::insert(&mut form,admin,c);
    //         };

    //         let v=vec_map::get_mut<address,CoinValue<u64>>(&mut form,& admin);
    //         debug::print(& v.sui_value);
            
    //         let coinSafe=CoinSafe<u64>{
    //         id: object::new(ctx),
    //         coin_value:coin::zero<u64>(ctx),
    //         sui_value:coin::zero<SUI>(ctx),
    //         form:form,
    //         status:0,
    //         coin_mix:0,
    //         coin_max:0,
    //     };
    //         transfer::transfer(coinSafe, admin);
    //     };
    //     test_scenario::end(scenario);
        
    //  }
}