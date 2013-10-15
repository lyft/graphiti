class CreateGraphs < ActiveRecord::Migration
  def up
    create_table :graphs do |t|
      t.string :uuid
      t.string :title
      t.text :json
      t.text :url
      t.timestamps
    end
    add_index :graphs, :uuid, :unique => true
  end

  def down
    drop_table :graphs
  end
end
