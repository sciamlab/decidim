# frozen_string_literal: true

require "spec_helper"

describe Decidim::Metrics::ParticipantsMetricManage do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let!(:participatory_space) { create(:participatory_process, organization: organization) }
  let(:key) { [participatory_space.class.name, participatory_space.id] }
  let(:query) do
    q = {}
    q[key] = {
      cumulative_users: [1, 2, 3, 4, 5, 6, 7, 8],
      quantity_users: [1, 2]
    }
    q
  end

  context "when executing" do
    context "without data" do
      it "does not create any record" do
        expect(Decidim::Metric.count).to eq(0)
        generate_metric_registry
        expect(Decidim::Metric.count).to eq(0)
      end
    end

    context "with data" do
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(described_class).to receive(:query).and_return(query)
        # rubocop:enable RSpec/AnyInstance
      end

      it "creates new metric records" do
        registry = generate_metric_registry

        expect(registry.collect(&:day)).to eq([day])
        expect(registry.collect(&:cumulative)).to eq([8])
        expect(registry.collect(&:quantity)).to eq([2])
      end

      it "updates metric records" do
        create(:metric, metric_type: "participants", day: day, cumulative: 1, quantity: 1, organization: organization, category: nil, participatory_space: participatory_space)
        registry = generate_metric_registry

        expect(Decidim::Metric.count).to eq(1)
        expect(registry.collect(&:cumulative)).to eq([8])
        expect(registry.collect(&:quantity)).to eq([2])
      end
    end
  end
end

def generate_metric_registry(date = nil)
  metric = described_class.for(date, organization)
  metric.save
end
