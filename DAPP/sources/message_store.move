module my_addr::message_store {
    use std::string::{String};
    use std::signer;
    use aptos_framework::account;
    use aptos_framework::event;
    
    struct MessageHolder has key {
        message: String,
        message_change_events: event::EventHandle<MessageChangeEvent>,
    }

    struct MessageChangeEvent has drop, store {
        from_message: String,
        to_message: String,
    }

    public entry fun set_message(account: &signer, new_message: String) acquires MessageHolder {
        //let account_addr = account::get_signer_address(account);
        let account_addr = signer::address_of(account);

        
        if (!exists<MessageHolder>(account_addr)) {
            let message_holder = MessageHolder {
                message: new_message,
                message_change_events: account::new_event_handle<MessageChangeEvent>(account),
            };
            move_to(account, message_holder);
        } else {
            let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);
            let from_message = *&old_message_holder.message;
            event::emit_event(&mut old_message_holder.message_change_events, MessageChangeEvent {
                from_message,
                to_message: copy new_message,
            });
            old_message_holder.message = new_message;
        }
    }

    #[view]
    public fun get_message(account_addr: address): String acquires MessageHolder {
        assert!(exists<MessageHolder>(account_addr), 1);
        *&borrow_global<MessageHolder>(account_addr).message
    }
}