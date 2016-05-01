require 'yaml'
require 'active_support/all'

require_relative("./writer.rb")
require_relative("./selenium_runner.rb")

class Company < Hash
  # Syntactic Sugar
  def initialize(hash)
    hash.each { |k,v| self[k] = v }
  end
  def name
    self["name"]
  end
  def name=(val)
    self["name"] = val
  end
  def desc
    self["desc"]
  end
  def desc=(val)
    self["desc"] = val
  end
  def applied
    self["applied"]
  end
  def applied=(val)
    self['applied'] = val
  end
  def skip
    self['skip']
  end
  def skip=(val)
    self['skip'] = val
  end
end

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

  def find(company_name)
    all_companies.find { |company|
      company.name.eql?(company_name)
    }
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
        hash[category] = YAML.load(
          File.read "#{ROOT_PATH}/yml/companies/#{category}.yml"
        ).map { |company| Company.new(company) }
      ) rescue next hash
      next hash
    }
  end

  def all_companies
    # returns Array(company objects)
    @all_companies ||=\
      companies.values.flatten.map { |hash| Company.new(hash) }
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

  def skipped
    # returns array of company names
    filter { |company| company["skip"] || company[:skip] }
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

