module Trucker

  def self.migrate(name, options={})
    # Grab custom entity label if present
    label = options.delete(:label) if options[:label]

    unless options[:helper]
  
      # Grab model to migrate
      model = name.to_s.classify
  
      # Wipe out existing records
      if options[:delete_existing]
        model.constantize.delete_all
      end

      # Status message
      status = "Migrating "
      status += "#{number_of_records || "all"} #{label || name}"
      status += " after #{offset_for_records}" if offset_for_records
  
      records = query(model)
  
      # Set import counter
      counter = 0
      counter += offset_for_records.to_i if offset_for_records
      total_records = records.size
  
      # Start import
      records.each do |record|
        counter += 1
        puts status + " (#{counter}/#{total_records})"
        record.migrate
      end
    else
      eval options[:helper].to_s
    end
  end

  def self.query(model)
    model_class = "Legacy#{model.classify}".constantize
    model_class.respond_to?(:query) ? model_class.query : eval(construct_query(model))
  end

  def self.construct_query(model)
    base = "Legacy#{model.singularize.titlecase}"
    if ENV['limit'] or ENV['offset'] or ENV['where']
      complete = base + "#{where}#{number_of_records}#{offset_for_records}.order(:id)"
    else
      complete = base + ".order(:id).all"
    end
    complete
  end

  def self.batch(method)
    nil || ".#{method}(#{ENV[method]})" unless ENV[method].blank?
  end

  def self.where
    batch("where")
  end

  def self.number_of_records
    batch("limit")
  end

  def self.offset_for_records
    batch("offset")
  end
  
end
