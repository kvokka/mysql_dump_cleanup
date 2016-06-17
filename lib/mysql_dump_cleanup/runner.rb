module MysqlDumpCleanup
  class Runner

    attr_accessor :columns, :table_name

    require 'pry'

    # we have 3 types of secure data: for skip all table (#secret_tables), xor (#secret_xor_data) and skip columns(#secret_data)
    # !!! hor will work only for Integer
    # ENV params [:input_file, :output_file, :key]
    def start
      log "Working with dump #{dump_path}"
      log "Output to #{output_path}"
      read_file do |line|
        new_table! scan_for_table_name line
        add_column! scan_for_column line
        if     scan_for_insert_into line
          next if secret_tables.include? table_name
          # «Some people, when confronted with a problem, think “I know, I’ll use regular expressions.” Now they have two problems.»
          # — Jamie Zawinski
          if disabled_columns = secret_data[table_name]
            line.gsub! regex, used_columns_except( disabled_columns)
          end
          if xor_columns = secret_xor_data[table_name]
            xor_columns_numbers = xor_columns.map { |c| columns.index(c) }
            line.gsub!(regex) do |record|
              record_values = record[1..-2].split(',')
              xor_columns_numbers.each { |record_num| record_values[record_num] = (record_values[record_num].to_i ^ key) % 100_000_000 }
              record_values.join(',').prepend('(').concat(')')
            end
          end
        end
      end
    end



    private

    def scan_for_insert_into line
      Array(line.scan(/^INSERT INTO `(\w+)` VALUES/)).flatten.first
    end

    def scan_for_column line
      Array(line.scan(/^\s*`(\w+)`/)).flatten.first
    end

    def scan_for_table_name line
      Array(line.scan(/^CREATE TABLE.+`(\w+)`/)).flatten.first
    end

    def new_table! table
      return unless table
      self.table_name = table.to_sym
      log "Working with table -- #{table_name}"
      self.columns = []
    end

    def add_column! column
      return unless column
      self.columns ||= []
      self.columns << column.to_sym
    end

    def read_file  &block
      File.readlines(dump_path).each do |line|
        yield(line)
        save_line(line)
      end
      close_outout_file
    end

    def used_columns_except disabled_columns
      # Ruby does not support more, than 9 unnamed regex groups, so i use named
      (1..columns.length).to_a.map { |c| disabled_columns.map { |c| columns.index(c) + 1 }
      .include?(c) ? '' : '\k<p'+"#{c}"+'>' }
      .join(',')
      .prepend('(')
      .concat(')')
    end

    def regex
      Regexp.new(Array.new(columns.length) do |num|
                   %Q[(?<p#{num+1}>[^\(\),]*|'(\\\\'|[^'])*'|"(\\\\"|[^"])*")]
                       end.join(',').prepend('\(').concat('\)'))
    end

  def log(*args)
                       puts [args].join( ' ')
                     end

  # To speed up and not open file in every line
  def close_outout_file
                       @output_file.close
                     end

  def save_line(line)
                       @output_file ||= File.open output_path, 'w'
                       @output_file.write line
                     end

  def dump_path
                       ARGV[0]
                     end

  def output_path
                       'clean.sql'
                     end

  def secret_data
                       user_tables[:remove_columns] || {}
                     end

  def secret_xor_data
                       user_tables[:xor_integer_columns] || {}
                     end

  def secret_tables
                       user_tables[:remove_tables] || []
                     end

  def user_tables
                       eval( ARGV[-1]) || {}
                     end

  def key
                       rand 1..99_999_999
                     end
end  
end  
