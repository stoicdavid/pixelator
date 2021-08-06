require 'ipaddr'

class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      @remote_ip ||= (env['HTTP_CF_CONNECTING_IP'] ||
                      env['action_dispatch.remote_ip'] ||
                      ip).to_s
    end

    def allowed_ip?
      allowed_ips = ["127.0.0.1", "::1"]
      allowed_ips.include?(remote_ip)
    end
  end

  safelist('allow from localhost') do |req|
    req.allowed_ip?
  end

  blocklist("fail2ban") do |req|
    Rack::Attack::Fail2Ban.filter("fail2ban-#{req.remote_ip}", maxretry: 1, findtime: 1.day, bantime: 1.day) do
      CGI.unescape(req.query_string) =~ %r{/etc/passwd} ||
        req.path.include?("/etc/passwd") ||
        req.path.include?("wp-admin") ||
        req.path.include?("wp-login") ||
        /\S+\.php/.match?(req.path)
    end
  end

  throttle("limit logins per email", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      if (req.params["user"].to_s.size > 0) and (req.params["user"]["email"].to_s.size > 0)
        req.params["user"]["email"]
      end
    end
  end

  throttle("limit signups", limit: 5, period: 1.minute) do |req|
    req.remote_ip if req.path == "/users" && req.post?
  end

  # Exponential backoff for all requests to "/" path
  #
  # Allows 240 requests/IP in ~8 minutes
  #        480 requests/IP in ~1 hour
  #        960 requests/IP in ~8 hours (~2,880 requests/day)
  (3..5).each do |level|
    throttle("req/ip/#{level}",
               limit: (30 * (2 ** level)),
               period: (0.9 * (8 ** level)).to_i.seconds) do |req|
      req.remote_ip # unless req.path.starts_with?('/assets')
    end
  end
end

ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
  req = payload[:request]

  request_headers = { "CF-RAY" => req.env["HTTP_CF_RAY"] }

  Rails.logger.info "[Rack::Attack][Blocked] remote_ip: #{req.remote_ip}, path: #{req.path}, headers: #{request_headers.inspect}"

  AdminMailer.rack_attack_notification(name, start, finish, request_id, req.remote_ip, req.path, request_headers).deliver_later
end