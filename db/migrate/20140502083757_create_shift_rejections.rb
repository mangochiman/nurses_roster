class CreateShiftRejections < ActiveRecord::Migration
  def self.up
    create_table :shift_rejection, :primary_key => :shift_rejection_id do |t|
	  t.integer :shift_rejection_type_id
	  t.integer :shift_type_id
	  t.integer :nurse_id
	  t.string  :date_or_day
      t.timestamps
    end
  end

  def self.down
    drop_table :shift_rejection
  end
end
