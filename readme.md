A job application tracker system.

It mainly involves writing to YAML files using a text editor.

---

## Install

1. clone
2. look in .gitignore and create the folders which aren't present in the Github repo 
3. cd app
4. bundle (tested with ruby 2.4)
5. `./cli` or `./get_data`

## Usage

#### Basic concepts
  
[app/yml/categories/selected_categories.yml](app/yml/categories/selected_categories.yml) should be a list of category names. For example:  
```yml
--- 
- legal
- nonprofits
- music_services
```  

For each of these names, a corresponding file can be created i.e. `app/yml/companies/music_services.yml`. This file contains a list of objects. Any key can be added to a company object and used for queries through the `cli` script.

A few keys are already used in query methods in [app/lib/reader.rb](app/lib/reader.rb):  

**basic attributes**
- *:name* (the name of the company),
- *:desc*, (a short description)  

**additional attributes**
- *:applied* - any truthy value signifies a sent application
- *:todo*, any truthy value signifies an interesting-sounding company
- *:skip*, any truthy value signifies a skipped company

#### Note

The `.yml` extension should be used throughout the code, not `.yaml`

#### `./get_data` uses Javascript to get data from AngelList
  
  1. open a search results page on AngelList jobs.
  2. Open the javascript debugger console and paste in the script shown in the terminal
  3. wait until the infinite scroll has fetched all the results then paste in the next command
  4. paste the next command
  5. scroll back to the top of the page and copy the newly added text (in a grey box)
  6. paste the text into a file in `app/yml/companies`. Make sure there is an entry in the [app/yml/categories/selected_categories.yml](app/yml/categories/selected_categories.yml) list with the same name as thie `app/yml/companies` file. The text will have to be formatted a little bit to be proper YAML.

#### `./cli` is a query interface to the YAML data.
  1. run `./cli` to start the interactive REPL. Arbitrary Ruby can be run here, like in IRB
  2. type `help` to see a list of methods. When given a method name as an argument, `help` will show its source code. For example:  
  ```ruby
  >> help(:duplicates)
  def duplicates
    # returns Array(company objects) which have duplicate entries
    counts = Hash.new { |k,v| v = 0 }
    all_companies.each { |company|
      counts[company["name"] || company[:name]] += 1
    }
    return counts.keys.select { |k| counts[k] > 1 }
  end
  => :duplicates

  ```  
  3. Add query methods in [app/lib/reader.rb](app/lib/reader.rb)
