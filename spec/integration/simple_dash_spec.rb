# frozen_string_literal: true

require "spec_helper"

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

    SimpleDash["system"]
  end

  let(:env) { Rack::MockRequest.env_for("/") }

  before do
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
  end

  describe "GET /" do
    it "returns a 200 status code" do
      status, headers, _body = app.call(env)
      expect(status).to eq(200)
      expect(headers["Content-Type"]).to eq("text/html")
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
          expect(html).to include("❌ KEYVALUESTORE")
        end
      end
    end

    context "without I18n" do
      it "shows the success messages" do
        _status, _headers, body = app.call(env)
        html = body.first.gsub(/<\/?[^>]*>/, "")
        expect(html).to include("✅ database")
        expect(html).to include("✅ keyvaluestore")
      end
    end
  end

  describe "GET /invalid-path" do
    let(:env) { Rack::MockRequest.env_for("/invalid-path") }

    it "returns a 404 status code" do
      status, headers, body = app.call(env)
      
      expect(status).to eq(404)
      expect(headers["Content-Type"]).to eq("text/html")
      expect(body).to eq(["Not Found"])
    end
  end
end 
