require 'spec_helper'

describe ModelConfiguration::Association do

  let(:association) { ModelConfiguration::Association.new(name, options) }
  let(:name) { "association_name" }
  let(:options) { {} }

  describe "#as_field_name" do
    subject { association.as_field_name }

    context "when field_name includes _id already" do
      let(:name) { "model_id" }
      it { should eq(":model_id") }
    end

    context "when field_name doesn't include _id" do
      let(:name) { "model" }
      it { should eq(":model_id") }
    end
  end

  describe "#as_input" do
    subject { association.as_input }
    let(:expected_output) { "f.input :model_id, collection: Model.all" }

    context "when field_name includes _id already" do
      let(:name) { "model_id" }
      it { should eq(expected_output) }
    end

    context "when field_name doesn't include _id" do
      let(:name) { "model" }
      it { should eq(expected_output) }
    end
  end

  describe "#is_association?" do
    subject { association.is_association? }
    it { should eq(true) }
  end

end