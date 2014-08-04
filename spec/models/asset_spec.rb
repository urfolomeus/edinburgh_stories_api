require 'spec_helper'

describe Asset do
  describe "validating" do
    it "must have a user" do
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to include("can't be blank")
    end

    it "must have a title" do
      expect(subject).to be_invalid
      expect(subject.errors[:title]).to include("can't be blank")
    end

    it "must have a url" do
      expect(subject).to be_invalid
      expect(subject.errors[:url]).to include("can't be blank")
    end

    it "must have a valid file_type" do
      expect(subject).to be_invalid
      expect(subject.errors[:file_type]).to include("is not included in the list")
    end
  end
end
