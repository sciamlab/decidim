# frozen_string_literal: true

require "spec_helper"

describe Decidim::MetricMeasure do
  let(:resource) { create(:dummy_resource) }
  let(:date) { (Time.zone.today - 1.week) }
  let(:yesterday_date) { Time.zone.today - 1.day }
  let(:future_date) { Time.zone.today + 1.week }

  context "when executing a metric management" do
    it "creates a MetricManageObject" do
      manager = described_class.for(nil, resource)

      expect(manager).to be_valid
    end

    it "creates a MetricManageObject with a passing date parameter" do
      manager = described_class.for(date.strftime("%Y-%m-%d"), resource)

      expect(manager).to be_valid
    end

    it "fails with an invalid date" do
      expect { described_class.for("123456789", resource) }.to raise_error(ArgumentError)
    end

    it "fails with a future date" do
      expect { described_class.for(future_date.strftime("%Y-%m-%d"), resource) }.to raise_error(ArgumentError)
    end

    it "fails with a nill resource" do
      expect { described_class.for(future_date.strftime("%Y-%m-%d"), nil) }.to raise_error(ArgumentError)
    end
  end
end
