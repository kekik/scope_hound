# frozen_string_literal: true

require "spec_helper"

RSpec.describe ScopeHound::FilterProxy do
  before(:context) do
    ActiveRecord::Schema.define do
      suppress_messages do
        create_table :scope_hound_test_records, force: true do |t|
          t.string :status
          t.integer :category_id
          t.string :primary_tag
          t.string :secondary_tag
        end
      end
    end
  end

  after(:context) do
    ActiveRecord::Schema.define do
      suppress_messages do
        drop_table :scope_hound_test_records, if_exists: true
      end
    end
  end

  let(:filter_scopes_module) do
    Module.new do
      extend ScopeHound::FilterScopable

      filter_scope :status, ->(value) { where(status: value) }
      filter_scope :category_id, ->(value) { where(category_id: value) }
      filter_scope :tag, lambda { |value|
        where(primary_tag: value).or(where(secondary_tag: value))
      }

      filter_scope_path_for :status
      filter_scope_path_for :category_id
      filter_scope_path_for :tag, %w[primary_tag secondary_tag]
    end
  end

  let(:record_class) do
    proxy_class = nil

    Class.new(ActiveRecord::Base) do
      self.table_name = "scope_hound_test_records"

      extend ScopeHound::FilterableModel

      class << self
        attr_writer :proxy_class

        def filter_proxy = @proxy_class
      end

      self.proxy_class = proxy_class
    end
  end

  let(:proxy_class) do
    scopes = filter_scopes_module
    model = record_class

    Class.new(described_class) do
      define_singleton_method(:query_scope) { model }
      define_singleton_method(:filter_scopes_module) { scopes }
    end
  end

  before do
    record_class.proxy_class = proxy_class
    record_class.delete_all

    record_class.create!(status: "published", category_id: 1, primary_tag: "alpha", secondary_tag: "beta")
    record_class.create!(status: "published", category_id: 2, primary_tag: "beta", secondary_tag: "gamma")
    record_class.create!(status: "draft", category_id: 1, primary_tag: "delta", secondary_tag: "alpha")
  end

  describe "filter scopes" do
    it "returns the same scope when the filter value is blank" do
      scope = record_class.all.extending(filter_scopes_module)

      expect(scope.status(nil)).to be(scope)
      expect(scope.category_id("")).to be(scope)
    end
  end

  describe ".filter_by" do
    it "applies matching filter scopes and ignores blank or unknown filters" do
      filtered_scope, unique_values = proxy_class.filter_by(status: "published", category_id: nil, missing: "value")

      expect(filtered_scope.pluck(:status)).to eq(%w[published published])
      expect(unique_values[:status]).to eq(["published"])
      expect(unique_values[:category_id]).to match_array([1, 2])
      expect(unique_values[:tag]).to match_array(%w[alpha beta gamma])
    end

    it "supports unique value calculation from multiple registered paths" do
      filtered_scope, unique_values = proxy_class.filter_by(tag: "alpha")

      expect(filtered_scope.count).to eq(2)
      expect(unique_values[:tag]).to match_array(%w[alpha beta delta])
    end

    it "is delegated from models extending FilterableModel" do
      filtered_scope, unique_values = record_class.filter_by(status: "draft")

      expect(filtered_scope.pluck(:status)).to eq(["draft"])
      expect(unique_values[:category_id]).to eq([1])
    end
  end

  describe "required class methods" do
    it "raises when query_scope is not defined" do
      klass = Class.new(described_class) do
        def self.filter_scopes_module = Module.new
      end

      expect { klass.filter_by(status: "published") }
        .to raise_error(RuntimeError, /does not define query_scope/)
    end

    it "raises when filter_scopes_module is not defined" do
      model = record_class

      klass = Class.new(described_class) do
        define_singleton_method(:query_scope) { model }
      end

      expect { klass.filter_by(status: "published") }
        .to raise_error(RuntimeError, /does not define filter_scopes_module/)
    end
  end
end

RSpec.describe ScopeHound::FilterableModel do
  describe "required model API" do
    it "raises when the model does not define filter_proxy" do
      klass = Class.new do
        extend described_class
      end

      expect { klass.filter_by(status: "published") }
        .to raise_error(RuntimeError, /requires filter_proxy method to be defined/)
    end
  end
end
