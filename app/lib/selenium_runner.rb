require 'selenium-webdriver'
require 'byebug'

module SeleniumRunner
  def new_driver
    Selenium::WebDriver.for :firefox
  end
  def run_selenium(companies=false)
    driver = self.new_driver()
    # login and navigate to the page manually
    byebug
    companies_argument_given = !!companies
    script = case companies_argument_given
    when true
      <<-JS
      interval = window.setInterval(function(){
          $(".more.hidden").trigger("click")
      }, 250)
      JS
    when false
      <<-JS
      interval = window.setInterval(function(){
          $('html, body').scrollTop( $(document).height() - $(window).height() );
      }, 250)
      JS
    end
    scroll_finished_signifier = ".end_notice"
    driver.execute_script(script)
    wait = Selenium::WebDriver::Wait.new(timeout: 1200)
    wait.until { driver.find_element(css: scroll_finished_signifier).displayed? }
    driver.execute_script("window.clearInterval(interval)")
    secondary_script = case companies_argument_given
    when true
      <<-JS
        var $selenium = $("<div id='selenium'></div>")
        $("body").prepend($selenium)
        $(".text").each(
          function(idx, elem) {
            var $el = $(elem);
            var name = $el.find(".startup-link").text();
            var desc = $el.find(".blurb").text(); var location = $($el.find(".tags a")[0]).text()
            $selenium.prepend("name: " + name + ",<br>" + "desc: " + desc + "<br>" + "location: " + location + "<br><br>" ) 
          }
        );
      JS
    when false
      <<-JS
      var $selenium = $("<div id='selenium'></div>")
      $("body").prepend($selenium)
      $(".header-info").each(
        function(idx, elem) {
          var $el = $(elem);
          var name = $el.find(".startup-link").text();
          var desc = $el.find(".tagline").text();
          var jobs = $el.find(".collapsed-listing-row").text();
          $selenium.prepend("name: " + name + ",<br>" + "desc: " + desc + "<br>" + "jobs: " + jobs + "<br><br>") 
        }
      );
      JS
    end
    driver.execute_script(secondary_script)
    # find the content at the top of the page
    byebug
    driver.quit
  end
end