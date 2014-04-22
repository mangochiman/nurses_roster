class CreateNurses < ActiveRecord::Migration
  def self.up
    create_table :nurse, :primary_key => :nurse_id do |t|
      t.string :first_name
      t.string :last_name
	  t.string :gender
	  t.string :grade
      t.timestamps
    end
  end

  def self.down
	 drop_table :nurse
  end
end
