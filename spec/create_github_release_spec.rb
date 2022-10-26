# frozen_string_literal: true

RSpec.describe CreateGithubRelease do
  it 'has a version number' do
    expect(CreateGithubRelease::VERSION).not_to be nil
  end
end
