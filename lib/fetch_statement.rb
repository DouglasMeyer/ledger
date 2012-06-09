module FetchStatement
  def self.run
    require "selenium/webdriver"
    require "net/netrc"

    netrc = Net::Netrc.locate('harrisbank.com')

    Capybara.register_driver :chrome do |app|
      profile = Selenium::WebDriver::Chrome::Profile.new
      profile["download.default_directory"] = Rails.root.join('tmp/downloads').to_s
      Capybara::Selenium::Driver.new(app, :browser => :chrome, :profile => profile)
    end

    #Capybara.default_driver = Capybara.javascript_driver = :chrome



    session = Capybara::Session.new(:chrome)

    session.visit('http://harrisbank.com')
    session.within('form[name="xyz"]') do
      session.fill_in 'Username', :with => netrc.login
      session.fill_in 'password', :with => netrc.password
    end
    session.click_button 'Login'


    unless session.has_xpath? XPath::HTML.link('Accounts')
      # not logged-in, need to verify
      debugger ; nil
    end
    #{
    #  'In what city were you born? (Enter full name of city)' => 'confirm_birthplace'
    #  'What was the name of your first pet?' => 'confirm_pet'
    #}
    #
    #session.fill_in 'answer', :with => netrc.send('confirm_birthplace')
    #session.check 'oftenUsed'
    #session.click_button 'Continue'

    session.within('ul[s1id="navigationList"]') do
      session.click_link 'Accounts'
    end
    session.select 'Quicken (All Versions)', :from => 'format'
    session.click_button 'Download'


    session.check "checkbox"
    session.click_button 'Download'


    session.click_button 'Complete Download'
    sleep 10
  end
end
