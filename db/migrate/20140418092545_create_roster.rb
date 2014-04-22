class CreateRoster < ActiveRecord::Migration
  def self.up
	create_table :roster, :id => false do |t|
      t.integer :shift_id
      t.integer :nurse_id
	  t.date :start_date
	  t.date :end_date
      t.timestamps
    end
  end

  def self.down
	  drop_table :roster
  end
end
