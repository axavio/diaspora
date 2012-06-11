class AddNsfwShieldDisabled < ActiveRecord::Migration
  def self.up
    add_column :users, :nsfw_shield_disabled, :boolean, :null => false, :default => false

    ActiveRecord::Base.connection.execute <<SQL
      UPDATE users
        SET nsfw_shield_disabled = false
SQL
  end

  def self.down
    remove_column :users , :nsfw_shield_disabled
  end
end
