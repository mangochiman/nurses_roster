class CreateShiftRejectionTypes < ActiveRecord::Migration
  def self.up
    create_table :shift_rejection_type, :primary_key => :shift_rejection_type_id do |t|
	  t.string :rejection_type
      t.timestamps
    end
  end

  def self.down
    drop_table :shift_rejection_type
  end
end
