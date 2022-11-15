# frozen_string_literal: true

RSpec.describe CreateGithubRelease::TaskBase do
  let(:task) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  describe '#run' do
    subject { task.run }
    it 'calling run on an instance of TaskBase should raise a NotImplementedError' do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe '#options' do
    subject { task.options }
    it { is_expected.to eq(options) }
  end
end
