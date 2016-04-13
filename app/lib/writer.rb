module Writer
  def write(name, content)
    File.open("./yml/companies/#{name}.yml", 'w') {
      |file| file.write(YAML.dump content)
    }
  end
  def add_category(name)
    selected_categories = File.read(
      "./yml/categories/selected_categories.yml"
    )
    File.open("./yml/categories/selected_categories.yml", 'w') { |file|
            file.write(
              YAML.dump(
                YAML.load(
                  selected_categories
                ) + [name] 
              )
            )
          }
  end
end