# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
 def roster_constraints
    constraints = YAML.load_file("#{Rails.root.to_s}/config/constraints.yml")
    return constraints
 end
end
