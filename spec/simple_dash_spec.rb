# frozen_string_literal: true

RSpec.describe SimpleDash do
  it "has a version number" do
    expect(SimpleDash::VERSION).not_to be nil
  end

  it "defaults to I18n stand-in" do
    expect(SimpleDash.configuration.i18n).to eql(SimpleDash::I18n)
  end
end
