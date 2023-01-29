# frozen_string_literal: true

RSpec.describe CreateGithubRelease::BacktickDebug do
  describe '#backtick' do
    let(:command) { 'echo foo' }
    subject { including_class.new.send(:`, command) }

    context 'when backtick_debug? is false' do
      let(:including_class) do
        Class.new do
          include CreateGithubRelease::BacktickDebug
          def backtick_debug?
            false
          end
        end
      end

      let(:expected_output) { '' }

      it 'should NOT output debug information' do
        expect { subject }.to output(expected_output).to_stdout
      end
    end

    context 'when backtick_debug? is true' do
      context 'when the command succeeds' do
        let(:including_class) do
          Class.new do
            include CreateGithubRelease::BacktickDebug
            def backtick_debug?
              true
            end
          end
        end

        let(:expected_output) { <<~EXPECTED_OUTPUT }
          COMMAND
            echo foo
          OUTPUT
            foo
          EXITSTATUS
            0
        EXPECTED_OUTPUT

        it 'should output the expected debug information' do
          expect { subject }.to output(expected_output).to_stdout
        end
      end

      context 'when the command fails' do
        let(:command) { 'echo foo; exit 1' }

        let(:including_class) do
          Class.new do
            include CreateGithubRelease::BacktickDebug
            def backtick_debug?
              true
            end
          end
        end

        let(:expected_output) { <<~EXPECTED_OUTPUT }
          COMMAND
            echo foo; exit 1
          OUTPUT
            foo
          EXITSTATUS
            1
        EXPECTED_OUTPUT

        it 'should output the expected debug information' do
          expect { subject }.to output(expected_output).to_stdout
        end
      end
    end
  end
end
