# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_roster_session',
  :secret      => 'a5369be55c04d76591c21bcaa7b0ac690a5ed9792262f266bc608a2062b4cb70a0ff93619bc7bd25e3c4484980d5b4128219fad4f56beecea8ccd4830a64663b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
