# invoiced
Sample login tests for Invoiced

NOTE: Project is created with:
 * Ruby 2.7.1
 * Capybara/Selenium

## To run tests:
  1. Ensure that Ruby 2.7.1 is installed
  2. clone repo to local directory
  3. cd to directory
  4. install bundler `gem install bundler`
  5. run `bundle install` to install dependencies
  6. kick off test by running `bundle exec rspec`

NOTE: The tests can be run 'headlessly' by feeding the 
`DRIVER=headless` argument when calling the test:

run `DRIVER=headless bundle exec rspec`