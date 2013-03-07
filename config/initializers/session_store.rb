# Be sure to restart your server when you modify this file.

Ledger::Application.config.session_store :upgrade_signature_to_encryption_cookie_store, key: '_ledger_session'
