class CreateShiftType < ActiveRecord::Migration
  def self.up
	create_table :shift_type, :primary_key => :shift_type_id do |t|
	  t.string :name
	  t.string :start_time
	  t.string :end_time
      t.string :description
      t.timestamps
    end
  end

  def self.down
	drop_table :shift_type
  end
end
