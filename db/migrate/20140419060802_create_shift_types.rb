class CreateShiftTypes < ActiveRecord::Migration
  def self.up
    create_table :shift_types do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :shift_types
  end
end
