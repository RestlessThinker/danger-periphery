# frozen_string_literal: true

require File.expand_path("spec_helper", __dir__)

module Danger
  describe Danger::DangerPeriphery do
    it "should be a plugin" do
      expect(Danger::DangerPeriphery.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      before do
      end

      # Some examples for writing tests
      # You should replace these with your own.
    end
  end
end
