class Hash
  def stringify_keys
    self.keys.reduce({}) do |memo, key|
      memo[key.to_s] = self[key]; memo
    end
  end
end

module Writer
  def write(name, content)
    if content.is_a?(Array) && content[0].is_a?(Hash)
      content = content.map(&:stringify_keys)
    end
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
  def add_company(category, attrs_hash)
    write(category, (
      (
        YAML.load(
          File.read("./yml/companies/#{category}.yml")
        ) || [] rescue []
      ) + [attrs_hash]
    ))
  end
end