class AddKnockedOutToPoolEntries < ActiveRecord::Migration[7.0]
  def change
  	add_column :pool_entries, :knocked_out, :boolean, default: false
  end
end
