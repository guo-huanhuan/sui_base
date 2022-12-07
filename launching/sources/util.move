module base::util{
     use sui::coin::{Self,Coin};
     use sui::sui::{SUI};
     use sui::object::{Self,UID};
     use std::vector;
     use sui::transfer;
     use sui::bag::{Self,Bag};
     use sui::tx_context::{Self,TxContext};
     use base::vec_map::{Self,VecMap};
     use base::vec_set::{Self,VecSet};
     struct CionCap<phantom T> has store,drop,copy{
    }
     struct LaunchingCoin has key{
          id: UID,
          coin_map:Bag,
     }
    //Subscription time has not started
    const BEGIN_DATE_ERROR : u64 = 10;
    //Subscription period has ended
    const END_DATE_ERROR : u64 = 11;
    //Greater than the maximum subscription amount
    const MIA_AMOUNT_ERROR : u64 = 12;
    //Below the minimum subscription quantity
    const MIX_AMOUNT_ERROR : u64 = 13;
    //Insufficient amount
    const COIN_ERROR : u64 = 14;
    // For when a type passed to create_supply is not a one-time witness.
    const EBAD_WITNESS: u64 = 15;
    // Form address and amount amount are inconsistent
    const FROM_ERROR: u64 = 16;
    // Coinsafe_status error
    const COINSAFE_STATUS: u64 = 17;
    // The sender address is no longer in the COIN safe
    const COINSAFE_FROM_ERROR: u64 = 18;
    // event not open
    const IS_PROCESSING_ERROR: u64 = 19;
    // not in the whitelist
    const NO_WL_ERROR: u64 = 20;
    // not in the seed
    const NO_SEED_ERROR: u64 = 21;
    // Already participated once, cannot participate multiple times
    const PARTICIPATION_FORM_ERROR: u64 = 22;
     fun init(ctx: &mut TxContext) {
          let launchingCoin=LaunchingCoin{
               id: object::new(ctx),
               coin_map: bag::new(ctx),
          };
          transfer::share_object(launchingCoin);
     }
     public fun verify_witness<T:drop>(launchingCoin:&mut LaunchingCoin){
      // Make sure there's only one instance of the type T
        bag::add(&mut launchingCoin.coin_map,CionCap<T>{},0);
     }
     public fun verify_date(date:u64, begin_date:u64, end_date:u64){
        assert!(date >= begin_date , BEGIN_DATE_ERROR);
        assert!(date <= end_date , END_DATE_ERROR);
     }
     public fun verify_amount(amount:u64, mix_amount:u64, max_amount:u64){
        assert!(amount >= mix_amount , MIA_AMOUNT_ERROR);
        assert!(amount <= max_amount , MIX_AMOUNT_ERROR);
     }
     public fun verify_coin(coin: &Coin<SUI>){
        assert!(coin::value(coin) >= 1000 , COIN_ERROR);
     }
     public fun verify_coinsafe_status(coinsafe_status:u64 ,verify_status:u64){
        assert!(coinsafe_status!=verify_status , COINSAFE_STATUS);
     }
     public fun verify_from(form_address:vector<address>,form_u64:vector<u64>){
      // Make sure there's only one instance of the type T
        assert!(vector::length(&form_address) == vector::length(&form_u64) , FROM_ERROR);
     }
     public fun verify_coinsafe_from(b:bool){
      assert!(b , COINSAFE_FROM_ERROR);
     }
     public fun verify_launching_is_processing(is_processing: bool){
        assert!(is_processing , IS_PROCESSING_ERROR);
     }
     public fun verify_wl(from:& VecSet<address>,ctx: &mut TxContext){
         assert!(vec_set::contains<address>(from,& tx_context::sender(ctx)) , NO_WL_ERROR);
     }
     public fun verify_seed(from:& VecMap<address,u64>,ctx: &mut TxContext){
        assert!(vec_map::contains<address,u64>(from,& tx_context::sender(ctx)) ,NO_SEED_ERROR);
     }
      public fun verify_participation_form(from:& VecMap<address,u64>,ctx: &mut TxContext){
        assert!(!vec_map::contains<address,u64>(from,& tx_context::sender(ctx)) ,PARTICIPATION_FORM_ERROR);
     }
//    #[test]
//       fun test1(){
//         use sui::test_scenario::{Self};
//         let admin = @0xf116a4ecb0f483cadc1b75f8770f096befa45ab9;
//         let scenario = test_scenario::begin(admin);
//         { 
//            assert!(100 >= 101 , MIA_AMOUNT_ERROR);
//            assert!(100 <= 100 , MIX_AMOUNT_ERROR);
//         };
//         test_scenario::end(scenario);
        
//      }
}