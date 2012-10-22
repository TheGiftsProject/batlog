require 'active_support/concern'

module Log
  module ControllerSupport

    extend ActiveSupport::Concern

    included do
      before_filter :set_log_context if respond_to? :before_filter
      alias_method_chain :handle_unverified_request, :log
    end

    def set_log_context
      context = {}
      context.merge!(
          :url => request.url,
          :user_agent => request.user_agent,
          :ip => request.ip,
          :remote_ip => request.remote_ip,
          :referer => request.referer,
          :environment => Rails.env.to_s,
          :session_id => request.session_options[:id],
          :session => session,
          :params => params
      )
      context.merge!(:current_user => current_user.try(:id)) if respond_to? :current_user
      context.merge!(more_context) if respond_to? :more_context
      Log.clear_context
      Log.context(context)
    end

    def handle_unverified_request_with_log
      Log.warn("Can't verify CSRF token authenticity")
      handle_unverified_request_without_log
    end

  end
end