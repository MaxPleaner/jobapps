A job application tracker system.

It mainly involves writing to YAML files using a text editor.

## Update

I've replaced a large part of this project with a web interface. See [jobapps-web](http://github.com/maxpleaner/jobapps-web). 

However the web interface uses the same formatted YAML files as this project.

In short, this program can be used to create lists of companies in YAML files which are then imported into the jobapps-web program. 

## Update 2

I wrote _yet another_ iteration of this project, which of course is the best. It's at https://github.com/MaxPleaner/job_search_companion

---

## Install

1. clone
2. cd app
3. bundle (tested with ruby 2.4)
4. `./cli` or `./get_data`

---


## Relevant projects

This is built using [ruby-cli-skeleton](http://github.com/maxpleaner/ruby-cli-skeleton), which i made. See that readme for more info. In this repo, the `RubyCliSkeleton` class is defined in the [app/cli](app/cli) file.

This serves the same purpose as [job_tracker_cli](http://github.com/maxpleaner/job_tracker_cli) which is made redundant by this project. 

---

## Usage

#### Basic concepts
  
[app/yml/categories/selected_categories.yml](app/yml/categories/selected_categories.yml) should be a list of category names. For example:  
```yml
--- 
- legal
- nonprofits
- music_services
```  

For each of these names, a corresponding companies file can be created i.e. `app/yml/companies/music_services.yml`. This file contains a list of objects. Any key can be added to a company object and used for queries through the `cli` script.

A few keys are already used in query methods in [app/lib/reader.rb](app/lib/reader.rb) (and, by extension, [app/cli](app/cli)):

**basic attributes**
- *:name* (the name of the company),
- *:desc*, (a short description)  

**additional attributes**
- *:applied* - any truthy value signifies a sent application
- *:todo*, any truthy value signifies an interesting-sounding company
- *:skip*, any truthy value signifies a skipped company

#### Notes

**~** The `.yml` extension should be used throughout the code, not `.yaml`

**~** If some company/category yaml file gets changed when the `./cli` REPL is already running, `uncache` needs to be called so that the changes will be included.

**~** Make sure that every file in yml/companies has at least one company entry in it. 

**~** Every company needs to have a name attribute

**~** All keys should be strings. To ensure all a yml file's keys are strings, run `delete_duplicates(category_name)` on the category, which will trigger a rewrite that stringifies all the keys. But make sure to delete any extant duplicate records first. 

----

## Executables

#### `./get_data` uses Javascript to get data from AngelList

  
  1. open a job search results page on AngelList jobs. You can also use a 'startups' search result page but the script is a little different. In that case, use`./get_data companies` instead.
  2. Open the javascript debugger console and paste in the script shown in the terminal
  3. wait until the infinite scroll has fetched all the results then paste in the next command
  4. paste the next command
  5. scroll back to the top of the page and copy the newly added text (in a grey box)
  6. paste the text into a file in `app/yml/companies`. Make sure there is an entry in the [app/yml/categories/selected_categories.yml](app/yml/categories/selected_categories.yml) list with the same name as thie `app/yml/companies` file. The text will have to be formatted a little bit to be proper YAML.

#### Selenium script

  There is also a selenium script which automates these steps. Open `./cli` and call `run_selenium` or `run_selenium(true)` (use the argument for company listing pages as opposed to job listing pages). However, AngelList requires a login in order to see job listings, and the selenium script isn't set up to automate login yet.

  There are a couple `pry` breakpoints in the selenium script where manual input is required:

  1. At the first breakpoint, go to the Firefox window that selenium opened and login to AngelList. Then open the "jobs" search page and confiure your query (location, tags, etc). When finished, enter `continue` into the terminal
  2. At the second breakpoint, copy the extracted data from the top of the page into a yml file (and format it to be syntactic yaml)

#### `./cli` is a query interface to the YAML data.
  1. run `./cli` to start the interactive REPL. Arbitrary Ruby can be run here, like in IRB
  2. type `help` to see a list of methods. When given a method name as an argument, `help` will show its source code. For example:  
  ```txt
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
  3. Add query methods in [app/lib/reader.rb](app/lib/reader.rb). The following methods are implemented:
    - `help(method_name=nil)` prints all the available methods, and can display a method's source code if the method name is passed as a (symbol) argument.
    - `filter(&blk)` can be used to filter companies. Returns a hash where keys are category names and values are arrays of company objects.
    For example:  
    ```ruby
      filter { |company| company["applied"] }
    ```
    - `uncache` will clear the in-memory companies data and prompt a fresh lookup from YML the next time a query is called.
    - `all_categories` will load the file at [yml/categories/categories.yml](yml/categories/categories.yml). This list includes all categories that are present on [this AngelList category directory](https://angel.co/markets). It returns a hash where keys are category names and values are attributes. The attributes includes are counts for the number of investors, followers, companies, and jobs
    - `selected_categories` loads [yml/categories/selected_categories](yml/categories/selected_categories). It returns an array of category names.
    - `companies` is used to load all companies. It returns a hash where keys are category name and values are arrays of category objects.
    - `all_companies` returns an array of all company objects 
    - `applied` returns an array of company names (which have a truthy `applied` value)
    - `todos` returns an array of company names (which have a truthy `todo` value)
    - `blank` returns an array of company names (which have a blank `desc` value)
    - `duplicates` returns an array of company objects which have duplicate entries. For each duplicate `name`, the first matching object is included here. 

    **_Update_**

    I've been adding more methods to the cli.

    - `write(name, content)` will write to the file at `yml/companies/#{name}.yml`. It will overwrite the file if it exists or create it otherwise. `content` is expected to be a ruby object. The method calls `YAML.dump` internally.
    - `add_category(name)`  to add a category to the list at [yml/categories/selected_categories.yml](yml/categories/selected_categories.yml).
    - `add_company(category, attributes_hash)` to add a company to the file at `yml/companies/#{category}.yml` (creating the file if necessary) 
    - `delete_duplicates(category_name)` will delete any companies from the `yml/companies/#{category_name}.yml` file that are duplicates of entries in other files. 
    
    **_Update2**

    - companies are now returned as `Company` objects (a class which inherits from hash)
    - The main point of this is to define methods for creatin attr accessors for `name`, `desc`, `applied`, and `skip` attributes 
