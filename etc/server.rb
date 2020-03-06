#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 6.0"
  gem "puma", "~> 4.0"
end

require "rails"
require "global_id"

require "action_controller/railtie"
require "action_view/railtie"
require "action_cable/engine"

require "rack/handler/puma"

class TestApp < Rails::Application
  secrets.secret_token    = "secret_token"
  secrets.secret_key_base = "secret_key_base"

  config.logger = Logger.new($stdout)
  config.log_level = :debug
  config.eager_load = true

  config.filter_parameters << :token

  initializer "routes" do
    Rails.application.routes.draw do
      mount ActionCable.server => "/cable"
    end
  end
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :id, :token

    def connect
      self.id = SecureRandom.uuid
      self.token = request.params[:token] ||
        request.cookies["token"] ||
        request.headers["X-API-TOKEN"]
    end
  end
end

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

ActionCable.server.config.cable = { "adapter" => "async" }
ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true

class DemoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "demo"
  end
end

class EchoChannel < ApplicationCable::Channel
  def subscribed
    stream_from "echo"
  end

  def echo_params
    transmit params.without("channel")
  end

  def echo(data)
    transmit pong: data.without("action")
  end

  def echo_token
    transmit token: token
  end

  def echo_headers
    headers = connection.send(:request).headers.select { |k,| k.start_with?(/http_x_api/i) }
    transmit headers
  end
end

Rails.application.initialize!

Rack::Handler::Puma.run(Rails.application, :Port => 8080)
