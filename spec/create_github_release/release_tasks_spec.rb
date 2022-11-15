# frozen_string_literal: true

RSpec.describe CreateGithubRelease::ReleaseTasks do
  let(:release_tasks) { described_class.new(options) }
  let(:options) { CreateGithubRelease::Options.new { |o| o.release_type = 'major' } }

  describe '#run' do
    subject { release_tasks.run }

    let(:tasks) do
      # Assume that all classes in the Tasks module are tasks
      tasks_module = CreateGithubRelease::Tasks
      tasks_module.constants.select { |c| tasks_module.const_get(c).is_a? Class }
    end

    before do
      tasks_called = []
      @tasks_called = tasks_called
      tasks.each do |task|
        task_class = CreateGithubRelease::Tasks.const_get(task)
        expect(task_class).to receive(:new).with(options) do |_options|
          Class.new do
            @task = task
            @tasks_called = tasks_called
            def run
              self.class.instance_variable_get(:@tasks_called) << self.class.instance_variable_get(:@task)
            end
          end.new
        end
      end
    end

    it 'should instantiate and call run on all tasks' do
      subject
      expect(@tasks_called).to match_array(tasks)
    end
  end
end
