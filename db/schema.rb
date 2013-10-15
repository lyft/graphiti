# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131015023350) do

  create_table "dashboard_graphs", :force => true do |t|
    t.integer "dashboard_id"
    t.integer "graph_id"
    t.integer "position"
  end

  add_index "dashboard_graphs", ["dashboard_id", "position"], :name => "index_dashboard_graphs_on_dashboard_id_and_position"
  add_index "dashboard_graphs", ["graph_id"], :name => "index_dashboard_graphs_on_graph_id"

  create_table "dashboards", :force => true do |t|
    t.string   "slug"
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "dashboards", ["slug"], :name => "index_dashboards_on_slug", :unique => true

  create_table "graphs", :force => true do |t|
    t.string   "uuid"
    t.string   "title"
    t.text     "json"
    t.text     "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "graphs", ["uuid"], :name => "index_graphs_on_uuid", :unique => true

  create_table "snapshots", :force => true do |t|
    t.integer  "graph_id"
    t.text     "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "snapshots", ["graph_id"], :name => "index_snapshots_on_graph_id"

end
