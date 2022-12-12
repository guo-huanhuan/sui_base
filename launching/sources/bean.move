module base::bean{
    use sui::object::{Self,UID};
    use sui::bag::{Self,Bag};
    use sui::transfer;
    use sui::tx_context::{TxContext};
    friend base::cashbox;
    friend base::launching;
    friend base::util;
    struct CionCap<phantom T> has store,drop,copy{
    }
    struct LaunchingCoin has key{
        id: UID,
        coin_map:Bag,
     }    
     struct CreatorCap<phantom T>  has key{
        id: UID,
    }
    fun init(ctx: &mut TxContext) {
        let launchingCoin=LaunchingCoin{
            id: object::new(ctx),
            coin_map: bag::new(ctx),
          };
        transfer::share_object(launchingCoin);
     }

    public (friend) fun create_creatorCap<T>(sender:address,ctx: &mut TxContext){
        transfer::transfer(CreatorCap<T>{id: object::new(ctx)},sender);
    }

    public (friend) fun add_witness<T:drop>(launchingCoin:&mut LaunchingCoin){
      // Make sure there's only one instance of the type T
        bag::add(&mut launchingCoin.coin_map, CionCap<T>{},0);
     }
     public fun ten_pow(decimals:u64):u64{
        let i=1;
        let d=1;
        while (i <= decimals) {
            d=d*10;
            i=i+1;
        };
          d
     }
}