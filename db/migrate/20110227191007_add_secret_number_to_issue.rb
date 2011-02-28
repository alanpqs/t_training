class AddSecretNumberToIssue < ActiveRecord::Migration
  def self.up
    add_column :issues, :secret_number, :string
  end

  def self.down
    remove_column :issues, :secret_number
  end
end
