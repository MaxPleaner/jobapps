require 'yaml'
require 'active_support/all'
require 'pry'

require_relative("./writer.rb")
require_relative("./selenium_runner.rb")

class Reader
  include Writer
  include SeleniumRunner
  def initialize(options={})
    puts "#{"**".blue} #{"  Jobapps REPL  ".white_on_black} #{"** http://github.com/maxpleaner/jobapps".blue}"
    puts "".blue
    puts "#{"try entering".yellow} #{"help".green}"
  end

  def run_selenium
    puts "companies page? empty newline means no"
    companies_arg = gets.chomp
    super(!companies_arg.blank?)
  end

  def write(name, content)
    super(name, content) # from lib/writer.rb
  end

  def delete_duplicates(name)
    puts "WARNING: this will delete duplicates from the name you have given"
    puts "i.e. if you give a 'sf_ruby' argument, companies in that category will"
    puts "be deleted if they are found elsewhere"
    puts "newline to confirm, any text cancels"
    input = gets.chomp
    if input.blank?
      super(name)
    end
  end

  def add_category(name)
    super(name) # from lib/writer.rb
  end

  def uncache
    @all_categories, @selected_categories,
    @companies, @all_companies =\
      nil, nil, nil, nil
  end
  
# ==========
# Commenting this out as it is pointless
# ==========
  # def backup_applied
    # Note that this will not work unless you call "migrate" in the ./job_tracker_cli/job_tracker_cli REPL
    # job_tracker_cli is a totally separate project that's not really integrated nor necessary to use
    # see http://github.com/maxpleaner/job_tracker_cli
  #   applied.each do |name|
  #     name = name.to_s.downcase.gsub(" ", "_")
  #     `( echo "add_company('#{name}')"; echo "\n"; echo "exit" ) | #{ROOT_PATH}/lib/job_tracker_cli/job_tracker_cli `
  #   end
  # end
  
  def all_categories
    # returns Hash (key: name, val: attributes)
    @all_categories ||= YAML.load(File.read "#{ROOT_PATH}/yml/categories/categories.yml")
  end

  def selected_categories
    # returns Array(category names)
    @selected_categories ||= YAML.load(File.read("#{ROOT_PATH}/yml/categories/selected_categories.yml"))
  end


  def companies
    # returns Hash (key: category, val: array of company objects)
    @companies ||= selected_categories.reduce({}) { |hash, category|
      (
        hash[category] = YAML.load(File.read "#{ROOT_PATH}/yml/companies/#{category}.yml")
      ) rescue next hash
      next hash
    }
  end

  def all_companies
    # returns Array(company objects)
    @all_companies ||=\
      companies.values.flatten
  end

  def filter(&blk)
    # returns hash
    # key: category
    # val: Array(company objects)
    return companies if blk.nil?
    companies.keys.reduce({}) { |memo, category|
      list = companies[category]
      memo[category] = list.select { |compan|
        blk.call(compan)
      }
      memo
    }.reject { |k,v| v.empty? }
  end

  def applied
    # returns array of company names
    filter { |company| company["applied"] || company[:applied] }
           .values
           .flatten
           .map { |company| company["name"] || company[:name] }           
  end

  def todos
    # returns array of company names
    filter { |company| company["todo"] || company[:todo] }
           .values
           .flatten
           .map { |company| company["name"] || company[:name] }
  end

  def blank
    # returns array of company names
    filter { |company| company["desc"].blank? && company[:desc].blank? }
           .values
           .flatten
           .map { |company| company["name"] || company[:name] }
  end

  def duplicates
    # returns Array(company objects) which have duplicate entries
    counts = Hash.new { |k,v| v = 0 }
    all_companies.each { |company|
      counts[company["name"] || company[:name]] += 1
    }
    return counts.keys.select { |k| counts[k] > 1 }
  end

end

