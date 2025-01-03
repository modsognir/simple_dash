# frozen_string_literal: true

require "spec_helper"

class TestI18n
  def self.t(key)
    key.to_s.upcase
  end
end

class DatabaseConnection
  def self.active?
    true
  end
end

class KeyValueStore
  class PingError < StandardError; end

  def ping
    "PONG"
  end
end

RSpec.describe SimpleDash do
  let(:app) do
    SimpleDash.configure do |config|
      config.dashboard :system do
        condition "database.active", -> { DatabaseConnection.active? }
        condition "keyvaluestore.active", -> { KeyValueStore.new.ping == "PONG" }
        check :database, conditions: ["database.active"]
        check :keyvaluestore, conditions: ["keyvaluestore.active"]
      end
    end

    SimpleDash[path]
  end

  let(:env) { Rack::MockRequest.env_for("/#{path}") }

  describe "GET /" do
    let(:path) { "system" }

    it "returns a 200 status code" do
      status, headers, _body = app.call(env)
      expect(status).to eq(200)
      expect(headers["content-type"]).to eq("text/html")
    end

    context "with I18n" do
      before do
        SimpleDash.configure do |config|
          config.i18n = TestI18n
        end
      end

      context "when all health checks pass" do
        it "shows the success messages" do
          _status, _headers, body = app.call(env)
          html = body.first.gsub(/<\/?[^>]*>/, "")

          expect(html).to include("✅ DATABASE")
          expect(html).to include("✅ KEYVALUESTORE")
        end
      end

      context "when a health check fails" do
        before do
          allow_any_instance_of(KeyValueStore).to receive(:ping).and_raise(KeyValueStore::PingError)
        end

        it "shows the failure message" do
          _status, _headers, body = app.call(env)
          html = body.first.gsub(/<\/?[^>]*>/, "")
          expect(html).to include("✅ DATABASE")
          expect(html).to include("✅ DATABASE.ACTIVE")
          expect(html).to include("❌ KEYVALUESTORE")
          expect(html).to include("❌ KEYVALUESTORE.ACTIVE")
        end
      end
    end

    context "without I18n" do
      it "shows the success messages" do
        _status, _headers, body = app.call(env)
        html = body.first.gsub(/<\/?[^>]*>/, "")
        expect(html).to include("✅ database")
        expect(html).to include("✅ database.active")
        expect(html).to include("✅ keyvaluestore")
        expect(html).to include("✅ keyvaluestore.active")
      end
    end
  end

  describe "GET /invalid-path" do
    let(:path) { "invalid-path" }

    it "returns a 404 status code" do
      status, headers, body = app.call(env)

      expect(status).to eq(404)
      expect(headers["content-type"]).to eq("text/html")
      expect(body).to eq(["Not Found"])
    end
  end
end
