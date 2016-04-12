require 'yaml'
require 'active_support/all'

class Reader

  def initialize(options={})
  end

  def uncache
    @all_categories, @selected_categories,
    @companies, @all_companies =\
      nil, nil, nil, nil
  end
  
  def backup_applied
    applied.each do |name|
      name = name.to_s.downcase.gsub(" ", "_")
      `( echo "add_company('#{name}')"; echo "\n"; echo "exit" ) | #{ROOT_PATH}/lib/job_tracker_cli/job_tracker_cli `
    end
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

  def select(&blk)
    # returns Array(company objects)
    companies.reduce({}) { |memo, (category, list)|
      memo[category] = list.select { |compan|
        blk.call(compan)
      }
      memo
    }
  end

  def applied
    # returns Array(company objects)
    select { |company| company["applied"] || company[:applied] }
           .values
           .flatten
           .map { |company| company["name"] || company[:name] }           
  end

  def todos
    # returns Array(company objects)
    select { |company| company["todo"] || company[:todo] }
           .values
           .flatten
           .map { |company| company["name"] || company[:name] }
  end

  def blank
    # returns Array(company objects) which need their "desc" written
    select { |company| company["desc"].blank? && company[:desc].blank? }
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

