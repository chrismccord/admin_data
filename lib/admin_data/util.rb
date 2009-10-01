class AdminData::Util

  def self.javascript_include_tag(*args)
    tmp = []
    tmp << '<script>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','js',"#{arg}.js"))
      tmp << f.read
    end
    tmp << '</script>'
    tmp.join
  end

  def self.stylesheet_link_tag(*args)
    tmp = []
    tmp << '<style>'
    args.each do |arg|
      f = File.new(File.join(AdminDataConfig.setting[:plugin_dir],'lib','css',"#{arg}.css"))
      tmp << f.read
    end
    tmp << '</style>'
    tmp.join
  end

  def self.get_class_name_for_habtm_association(model,habtm_string)
    model.class.reflections.values.detect {|reflection| reflection.name == habtm_string.to_sym}.klass
  end

  def self.get_class_name_for_has_many_association(model,has_many_string)
     # do not really know how to return something from inside the hash.each do 
     # I was getting local jump error
    output = []
    model.class.name.camelize.constantize.reflections.each do |key,value|
      if value.macro.to_s == 'has_many' && value.name.to_s == has_many_string
         output << value.klass
      end
    end
    output.any? ? output.first : nil
  end

  def self.get_class_name_for_belongs_to_class(model,belongs_to_string)
     # do not really know how to return something from inside the hash.each do 
     # I was getting local jump error
    output = []
    model.class.name.camelize.constantize.reflections.each do |key,value|
      if value.macro.to_s == 'belongs_to' && value.name.to_s == belongs_to_string
         output << value.klass
      end
    end
    output.any? ? output.first : nil
  end

  #TODO what about the get_class_name for has_one relationship ??

  def self.has_many_count(model,hm)
    model.send(hm.intern).count
  end

  def self.habtm_count(model,habtm)
    has_many_count(model,habtm)
  end

  #TODO use inject
  def self.has_many_what(klass)
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_many'
    end
    output
  end

  #TODO use inject
  def self.has_one_what(klass)
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'has_one'
    end
    output
  end

  #TODO use inject
  def self.belongs_to_what(klass)
    # is it possible to user inject here to ge rid of output
    output = []
    klass.name.camelize.constantize.reflections.each do |key,value|
      output << value.name.to_s if value.macro.to_s == 'belongs_to'
    end
    output
  end

  def self.admin_data_association_info_size(klass)
    (belongs_to_what(klass).size > 0)  ||
    (has_many_what(klass).size > 0) ||
    (has_one_what(klass).size > 0) ||
    (habtm_what(klass).size > 0)
  end

  def self.habtm_what(klass)
    tmp = klass.name.camelize.constantize.reflections.values.select do |reflection|
      reflection.macro == :has_and_belongs_to_many
    end
    tmp.map(&:name).map(&:to_s)
  end


  def self.string_representation_of_data(value)
    case value
    when BigDecimal
      value.to_s
    when Date, DateTime, Time
      "'#{value.to_s(:db)}'"
    else
      value.inspect
    end
  end

  def self.build_sort_options(klass,sortby)
   klass.columns.inject([]) do |result,column|
      name = column.name

      selected_text = sortby == "#{name} desc" ? "selected='selected'" : ''
      result << "<option value='#{name} desc' #{selected_text}>&nbsp;#{name} desc</option>"

      selected_text = sortby == "#{name} asc" ? "selected='selected'" : ''
      result << "<option value='#{name} asc' #{selected_text}>&nbsp;#{name} asc</option>"
    end
  end

end