require_relative '../spec_helper'

feature 'visiting google.com' do
  scenario 'it can view the TruHearing homepage' do
    visit '/'

    expect(page).to have_content 'Hello World'
  end
end
