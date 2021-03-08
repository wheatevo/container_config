# frozen_string_literal: true

RSpec.describe ContainerConfig::Provider::SecretVolume do
  subject { described_class.new }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original
    allow(Dir).to receive(:glob).and_call_original
  end

  describe "#name" do
    it "returns its name" do
      expect(subject.name).to eq("Secret Volume")
    end
  end

  describe "#load" do
    context "when the secret file exists" do
      it "returns the value" do
        expect(Dir).to receive(:glob).with("/etc/*-secrets/**/SECRET_KEY").and_return(
          ["/etc/rails-secrets/test/SECRET_KEY"]
        )
        expect(File).to receive(:exist?).with("/etc/rails-secrets/test/SECRET_KEY").and_return(true)
        expect(File).to receive(:read).with("/etc/rails-secrets/test/SECRET_KEY").and_return("the_secret_key")

        expect(subject.load("SECRET_KEY")).to eq("the_secret_key")
      end
    end

    context "when the secret file does not exist" do
      it "returns nil" do
        expect(Dir).to receive(:glob).with("/etc/*-secrets/**/SECRET_KEY").and_return([])
        expect(subject.load("SECRET_KEY")).to eq(nil)
      end
    end
  end
end
