# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::Metrics::CommentsMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:component, participatory_space: participatory_space) }
  let(:commentable) { create(:dummy_resource, component: component) }

  # Leave a comment (Comments)
  let(:comments) { create_list(:comment, 2, root_commentable: commentable, commentable: commentable, created_at: day) }
  # TOTAL Participants for Comments: 2
  let(:all) { comments }

  context "when executing class" do
    before { all }

    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, participatory_space).calculate

      expect(result[:cumulative_users].count).to eq(2)
      expect(result[:quantity_users].count).to eq(2)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, participatory_space).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
