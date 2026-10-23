class CreateReplyReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reply_reviews do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.string :body_digest, null: false
      t.string :status, null: false
      t.string :category, null: false
      t.text :reason, null: false
      t.string :model, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :reply_reviews, :created_at
  end
end
