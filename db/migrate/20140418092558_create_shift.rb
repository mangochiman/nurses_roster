class CreateShift < ActiveRecord::Migration
  def self.up
	create_table :shift, :primary_key => :shift_id do |t|
      t.integer :shift_type_id
	  t.date :shift_date
      t.timestamps
    end
  end

  def self.down
	drop_table :shift
  end
end
