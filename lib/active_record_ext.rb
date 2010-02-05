ActiveRecord::Base.instance_eval do
  def prefix_and_reset_all_table_names_to(prefix)
    ActiveRecord::Base.table_name_prefix = prefix
    ActiveRecord::Base.reset_all_table_names
  end

  def reset_all_table_names
    subclasses.each do |sc|
      sc.reset_table_name
      puts "Reset #{sc}..."
    end
  end

  def show_all_subclasses
    subclasses.each do |sc|
      puts "#{sc} -> #{sc.table_name}"
    end
  end
end
