class CreateDashboards < ActiveRecord::Migration
  def up
    create_table :dashboards do |t|
      t.string :slug
      t.string :title
      t.timestamps
    end

    add_index :dashboards, :slug, :unique => true

    create_table :dashboard_graphs do |t|
      t.belongs_to :dashboard, :graph
      t.integer :position
    end

    add_index :dashboard_graphs, :graph_id
    add_index :dashboard_graphs, [:dashboard_id, :position]

    create_table :snapshots do |t|
      t.belongs_to :graph
      t.text :url
      t.timestamps
    end

    add_index :snapshots, :graph_id
  end

  def down
    drop_table :dashboards
    drop_table :dashboard_graphs
    drop_table :snapshots
  end
end
