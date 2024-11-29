# config/initializers/session_store.rb

Rails.application.config.session_store :cookie_store,
                                       key: '_project_manager_session',
                                       expire_after: 30.minutes
