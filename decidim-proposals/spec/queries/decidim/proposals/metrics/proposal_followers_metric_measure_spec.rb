# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::Metrics::ProposalFollowersMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:proposals_component) { create(:proposal_component, :published, participatory_space: participatory_space) }
  let(:proposal) { create(:proposal, :with_endorsements, published_at: day, component: proposals_component) }
  let(:draft) { create(:collaborative_draft, published_at: day, component: proposals_component) }
  let!(:follows) do
    create_list(:follow, 10, followable: proposal, created_at: day)
    create_list(:follow, 10, followable: draft, created_at: day)
  end

  context "when executing class" do
    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(20)
      expect(result[:quantity_users].count).to eq(20)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, proposals_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
