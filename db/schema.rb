# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140418092612) do

  create_table "nurse", :primary_key => "nurse_id", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roster", :id => false, :force => true do |t|
    t.integer  "shift_id"
    t.integer  "nurse_id"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift", :primary_key => "shift_id", :force => true do |t|
    t.integer  "shift_type_id"
    t.date     "shift_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shift_type", :primary_key => "shift_type_id", :force => true do |t|
    t.string   "name"
    t.string   "start_time"
    t.string   "end_time"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
