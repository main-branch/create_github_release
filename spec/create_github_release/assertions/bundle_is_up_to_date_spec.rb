# frozen_string_literal: true

RSpec.describe CreateGithubRelease::Assertions::BundleIsUpToDate do
  let(:assertion) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  before do
    allow(assertion).to receive(:`).with(String) { |command| execute_mocked_command(mocked_commands, command) }
  end

  describe '#assert' do
    subject { @stdout, @stderr = capture_output { assertion.assert } }
    let(:stdout) { @stdout }
    let(:stderr) { @stderr }

    before do
      allow(File).to receive(:exist?).and_call_original
    end

    context 'when Gemfile.lock exists' do
      before do
        allow(File).to receive(:exist?).with('Gemfile.lock') { true }
      end

      let(:mocked_commands) do
        [
          MockedCommand.new('bundle update --quiet', exitstatus: exitstatus)
        ]
      end

      context 'when bundle update succeeds' do
        let(:exitstatus) { 0 }
        it 'should succeed' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when bundle update fails' do
        let(:exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
        end
      end
    end

    context 'when Gemfile.lock DOES NOT exist' do
      before do
        allow(File).to receive(:exist?).with('Gemfile.lock') { false }
      end

      let(:mocked_commands) do
        [
          MockedCommand.new('bundle install --quiet', exitstatus: exitstatus)
        ]
      end

      context 'when bundle install succeeds' do
        let(:exitstatus) { 0 }
        it 'should succeed' do
          expect { subject }.not_to raise_error
        end
      end

      context 'when bundle install fails' do
        let(:exitstatus) { 1 }
        it 'should fail' do
          expect { subject }.to raise_error(SystemExit)
        end
      end
    end
  end
end
