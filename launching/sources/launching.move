module base::launching{
    use base::util::{Self,LaunchingCoin};
    use base::cashbox::{Self,CreatorCap,CoinSafe};
    use base::vec_set::{Self,VecSet};
    use base::vec_map::{Self,VecMap,Entry};
    use sui::transfer;
    use sui::tx_context::{Self,TxContext};
    use sui::coin::{Self,Coin};
    use sui::sui::{SUI};
    use sui::object::{Self,UID};
    use std::vector;
    //Receiving address
    const ADMIN_ADDRESS : address = @0xf116a4ecb0f483cadc1b75f8770f096befa45ab9;
    //Launching Basic Information
    struct LaunchingBase<phantom T>  has store,drop,copy{
        begin_date: u64,
        end_date: u64,
        proportion:u64,
        is_processing:bool,
        participation_form:VecMap<address,u64>,
    }
    //Launching Seed Round Information
    struct LaunchingSeed<phantom T>  has key{
        id: UID,
        //The maximum subscription ratio is set individually for each account in the seed round
        form: VecMap<address,u64>,
        mix_amount:u64,
        launching_base:LaunchingBase<T>,
    }
    //Launching whitelist information
    struct LaunchingWl<phantom T>  has key{
        id: UID,
        form: VecSet<address>,
        mix_amount:u64,
        max_amount:u64,
        launching_base:LaunchingBase<T>,
    }
    //Launching public information
    struct LaunchingPu<phantom T>  has key{
        id: UID,
        mix_amount:u64,
        max_amount:u64,
        launching_base:LaunchingBase<T>,
    }
    public fun begin_date<T>(launchingBase: &LaunchingBase<T>):&u64{
            &launchingBase.begin_date
    }
    public fun end_date<T>(launchingBase: &LaunchingBase<T>):&u64{
            &launchingBase.end_date
    }
    public fun proportion<T>(launchingBase: &LaunchingBase<T>):&u64{
            &launchingBase.proportion
    }
    public fun new_LaunchingBase_zero<T>():LaunchingBase<T>{
          let launchingBase=LaunchingBase{
                begin_date: 0,
                end_date: 0,
                proportion:0,
                is_processing:true,
                participation_form:vec_map::empty<address,u64>(),
          };
          launchingBase
    }
    public fun update_LaunchingBase<T>(launchingBase:&mut LaunchingBase<T>,begin_date: u64,end_date: u64,proportion:u64){
        launchingBase.begin_date=begin_date;
        launchingBase.end_date=end_date;
        launchingBase.proportion=proportion;
    }
    public fun add_participation_form<T>(launchingBase:&mut LaunchingBase<T>,sui:& Coin<SUI>,ctx: &mut TxContext){
        let sender = tx_context::sender(ctx);
        let value =coin::value<SUI>(sui);
        vec_map::insert<address,u64>(&mut launchingBase.participation_form,sender,value);
    }
    public  fun create_launching<T:drop>(launchingCoin: &mut LaunchingCoin,coin:Coin<T>,sui: Coin<SUI>,ctx: &mut TxContext){
        util::verify_coin(&sui);
        util::verify_witness<T>(launchingCoin);
        let sender = tx_context::sender(ctx);
        let launchingSeed=LaunchingSeed<T>{
            id: object::new(ctx),
            form: vec_map::empty<address,u64>(),
            mix_amount:0,
            launching_base:new_LaunchingBase_zero<T>(),
        };
        let launchingWl=LaunchingWl<T>{
            id: object::new(ctx),
            form: vec_set::empty<address>(),
            mix_amount:0,
            max_amount:0,
            launching_base:new_LaunchingBase_zero<T>(),
        };
        let launchingPu=LaunchingPu<T>{
            id: object::new(ctx),
            mix_amount:0,
            max_amount:0,
            launching_base:new_LaunchingBase_zero<T>(),
        };
        //Launching information sharing
        transfer::share_object(launchingSeed);
        transfer::share_object(launchingWl);
        transfer::share_object(launchingPu);
        //pay to admin
        transfer::transfer(sui, ADMIN_ADDRESS);
        //create coin safe
        cashbox::create_coinSafe<T>(coin,ctx);
        cashbox::create_creatorCap<T>(sender,ctx);

    }


    public entry fun update_launching_seed<T>(
        _:&mut CreatorCap<T>,
        launchingSeed:&mut LaunchingSeed<T>,
        //form: VecMap<address,u64>,
        form_address:vector<address>,
        form_u64:vector<u64>,
        mix_amount:u64,
        begin_date: u64,
        end_date: u64,
        proportion:u64){
            let size=vector::length(&form_address);
            util::verify_from(form_address,form_u64);
            let form=vector::empty<Entry<address,u64>>();
            let i = 0;
            while (i < size) {
                let entry_address=vector::borrow_mut(&mut form_address,i);
                let entry_u64=vector::borrow_mut(&mut form_u64,i);
                let entry=vec_map::create_entry(*entry_address,*entry_u64);
                vector::push_back(&mut form,entry);
                i=i+1;
            };


            launchingSeed.mix_amount=mix_amount;
            launchingSeed.form=vec_map::create<address,u64>(form);
            let launching_base=&mut launchingSeed.launching_base;
            update_LaunchingBase(launching_base,begin_date,end_date,proportion);
    }
    public entry fun update_launching_wl<T>(
        _:&mut CreatorCap<T>,
        launching_wl:&mut LaunchingWl<T>,
        form: vector<address>,
        mix_amount:u64,
        max_amount:u64,
        begin_date: u64,
        end_date: u64,
        proportion:u64){
            launching_wl.form=vec_set::create(form);
            launching_wl.mix_amount=mix_amount;
            launching_wl.max_amount=max_amount;
            let launching_base=&mut launching_wl.launching_base;
            update_LaunchingBase(launching_base,begin_date,end_date,proportion);
    }
    public entry fun update_launching_pu<T>(
        _:&mut CreatorCap<T>,
        launching_pu:&mut LaunchingPu<T>,
        mix_amount:u64,
        max_amount:u64,
        begin_date: u64,
        end_date: u64,
        proportion:u64){
            launching_pu.mix_amount=mix_amount;
            launching_pu.max_amount=max_amount;
            let launching_base=&mut launching_pu.launching_base;
            update_LaunchingBase(launching_base,begin_date,end_date,proportion);
    }


    public entry fun join_launching_pu<T>(
        launching_pu:&mut LaunchingPu<T>,
        coinSafe:&mut CoinSafe<T>,
        sui:Coin<SUI>,
        ctx: &mut TxContext
        ){
            util::verify_launching_is_processing(launching_pu.launching_base.is_processing);
            let sui_value=coin::value<SUI>(&sui);
            util::verify_amount(sui_value,launching_pu.mix_amount , launching_pu.max_amount);
            util::verify_participation_form(&launching_pu.launching_base.participation_form,ctx);
            let coin_value=launching_pu.launching_base.proportion * sui_value;
            add_participation_form<T>(&mut launching_pu.launching_base,& sui,ctx);
            cashbox::join_coinSafe<T>(coinSafe,sui,coin_value,ctx);
    }
    public entry fun join_launching_wl<T>(
        launching_wl:&mut LaunchingWl<T>,
        coinSafe:&mut CoinSafe<T>,
        sui:Coin<SUI>,
        ctx: &mut TxContext
        ){
            util::verify_wl(& launching_wl.form,ctx);
            util::verify_launching_is_processing(launching_wl.launching_base.is_processing);
            let sui_value=coin::value<SUI>(&sui);
            util::verify_amount(sui_value,launching_wl.mix_amount , launching_wl.max_amount);
            util::verify_participation_form(&launching_wl.launching_base.participation_form,ctx);
            let coin_value=launching_wl.launching_base.proportion * sui_value;
            add_participation_form<T>(&mut launching_wl.launching_base,& sui,ctx);
            cashbox::join_coinSafe<T>(coinSafe,sui,coin_value,ctx);
    }
    public entry fun join_launching_seed<T>(
        launching_seed:&mut LaunchingSeed<T>,
        coinSafe:&mut CoinSafe<T>,
        sui:Coin<SUI>,
        ctx: &mut TxContext
        ){
            let from=launching_seed.form;
            util::verify_seed(& from,ctx);
            util::verify_launching_is_processing(launching_seed.launching_base.is_processing);
            let sui_value=coin::value<SUI>(&sui);
            let max_amount=vec_map::get<address,u64>(& from,& tx_context::sender(ctx));
            util::verify_amount(sui_value,launching_seed.mix_amount , * max_amount);
            util::verify_participation_form(&launching_seed.launching_base.participation_form,ctx);
            let coin_value=launching_seed.launching_base.proportion * sui_value;
            add_participation_form<T>(&mut launching_seed.launching_base,& sui,ctx);
            cashbox::join_coinSafe<T>(coinSafe,sui,coin_value,ctx);
    }
    //    #[test]
    //   fun test1(){
    //     use sui::test_scenario::{Self};
    //     // use std::debug;
    //     let admin = @0xf116a4ecb0f483cadc1b75f8770f096befa45ab9;
    //     let scenario = test_scenario::begin(admin);
    //     { 
           
    //         let ctx= test_scenario::ctx(&mut scenario);
    //         let launchingSeed=LaunchingSeed<u64>{
    //         id: object::new(ctx),
    //         form: vec_map::empty<address,u64>(),
    //         mix_amount:0,
    //         launching_base:new_LaunchingBase_zero<u64>(),
    //         };
    //         let v=vector::empty<u64>();
    //         vector::push_back<u64>(&mut v,10);
    //         vector::push_back<u64>(&mut v,20);
    //         vector::push_back<u64>(&mut v,30);
    //         let ad=vector::empty<address>();
    //         vector::push_back<address>(&mut ad,@0xf116a4ecb0f483cadc1b75f8770f096befa45ab1);
    //         vector::push_back<address>(&mut ad,@0xf116a4ecb0f483cadc1b75f8770f096befa45ab2);
    //         vector::push_back<address>(&mut ad,@0xf116a4ecb0f483cadc1b75f8770f096befa45ab3);
    //         update_launching_seed(&mut launchingSeed,ad,v,1,2,3,4);
    //         transfer::transfer(launchingSeed,admin);

    //     };
    //     test_scenario::end(scenario);
        
    //  }
}