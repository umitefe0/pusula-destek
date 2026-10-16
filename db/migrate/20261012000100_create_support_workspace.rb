class CreateSupportWorkspace < ActiveRecord::Migration[8.1]
  def change
    create_table :workspaces do |t|
      t.string :name, null: false
      t.timestamps
    end
    create_table :users do |t|
      t.references :workspace, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.integer :role, null: false, default: 0
      t.timestamps
    end
    add_index :users, [:workspace_id, :email], unique: true
    create_table :tickets do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.text :description, null: false
      t.integer :priority, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.datetime :first_response_due_at, null: false
      t.datetime :first_response_at
      t.datetime :waiting_since
      t.datetime :solved_at
      t.timestamps
    end
    add_index :tickets, [:workspace_id, :status, :first_response_due_at], name: 'idx_ticket_queue'
    create_table :messages do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.integer :visibility, null: false, default: 0
      t.text :body, null: false
      t.string :submission_key
      t.timestamps
    end
    add_index :messages, :submission_key, unique: true
    create_table :ticket_events do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.string :action, null: false
      t.string :from_status
      t.string :to_status
      t.timestamps
    end
  end
end
