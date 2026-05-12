# frozen_string_literal: true

require "spec_helper"

RSpec.describe ScopeHound::FilterableController, type: :controller do
  let(:controller_class) do
    Class.new(ActionController::Base) do
      include ScopeHound::FilterableController

      def filter_params
        { status: "published" }
      end
    end
  end

  subject(:controller) { controller_class.new }

  describe "#filter" do
    it "returns the filtered scope and stores filter metadata" do
      scope = double("scope")
      filtered_scope = instance_double(ActiveRecord::Relation)
      unique_filters = { status: ["published"] }

      allow(scope).to receive(:filter_by).with(status: "published").and_return([filtered_scope, unique_filters])

      expect(controller.filter(scope)).to eq(filtered_scope)
      expect(controller.all_filtered_records).to eq(filtered_scope)
      expect(controller.unique_filters).to eq(unique_filters)
    end

    it "raises a helpful error when the scope does not implement filter_by" do
      expect { controller.filter(Object.new, {}) }
        .to raise_error(RuntimeError, /does not extend FilterProxy interface/)
    end
  end

  describe "#filter_params" do
    it "raises when a controller includes the concern without defining filter_params" do
      klass = Class.new(ActionController::Base) do
        include ScopeHound::FilterableController
      end

      expect { klass.new.filter_params }
        .to raise_error(RuntimeError, /does not define filter_params method/)
    end
  end

  describe "#filter_values" do
    before do
      controller.unique_filters = { status: [2] }
    end

    it "returns every value when show_all is true" do
      values = { "Draft" => 1, "Published" => 2 }

      expect(controller.filter_values(:status, values, show_all: true)).to eq(values)
    end

    it "filters values to those present in unique_filters by default" do
      values = { "Draft" => 1, "Published" => 2 }

      expect(controller.filter_values(:status, values)).to eq("Published" => 2)
    end
  end

  describe "private helpers" do
    it "splits nested attribute paths into associations and field name" do
      associations, field = controller.send(:get_attribute_and_associations, "author.profile.id")

      expect(associations).to eq(%w[author profile])
      expect(field).to eq("id")
    end
  end
end
