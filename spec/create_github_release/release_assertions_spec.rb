# frozen_string_literal: true

RSpec.describe CreateGithubRelease::ReleaseAssertions do
  let(:release_assertions) { described_class.new(project) }
  let(:project) { CreateGithubRelease::Project.new(options) }
  let(:options) { CreateGithubRelease::CommandLineOptions.new { |o| o.release_type = 'major' } }

  describe '#make_assertions' do
    subject { release_assertions.make_assertions }

    let(:assertions) do
      # Assume that all classes in the Assertions module are assertions
      assertions_module = CreateGithubRelease::Assertions
      assertions_module.constants.select { |c| assertions_module.const_get(c).is_a? Class }
    end

    before do
      assertions_called = []
      @assertions_called = assertions_called
      assertions.each do |assertion|
        assertion_class = CreateGithubRelease::Assertions.const_get(assertion)
        expect(assertion_class).to receive(:new).with(project) do |_project|
          Class.new do
            @assertion = assertion
            @assertions_called = assertions_called
            def assert
              self.class.instance_variable_get(:@assertions_called) << self.class.instance_variable_get(:@assertion)
            end
          end.new
        end
      end
    end

    it 'should instantiate and call assert on all assertions' do
      subject
      expect(@assertions_called).to match_array(assertions)
    end
  end
end
