class AddUserTimeZone < ActiveRecord::Migration
  def self.up
    add_column :users, :time_zone, :string, :null => false, :default => 'Canada/Eastern'
  end

  def self.down
    remove_column :users, :time_zone
  end
end
