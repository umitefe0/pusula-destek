# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_12_000100) do
  create_table "messages", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "author_id", null: false
    t.integer "visibility", default: 0, null: false
    t.text "body", null: false
    t.string "submission_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_messages_on_author_id"
    t.index ["submission_key"], name: "index_messages_on_submission_key", unique: true
    t.index ["ticket_id"], name: "index_messages_on_ticket_id"
  end

  create_table "ticket_events", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "actor_id", null: false
    t.string "action", null: false
    t.string "from_status"
    t.string "to_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_ticket_events_on_actor_id"
    t.index ["ticket_id"], name: "index_ticket_events_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.integer "customer_id", null: false
    t.integer "assignee_id"
    t.string "subject", null: false
    t.text "description", null: false
    t.integer "priority", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.datetime "first_response_due_at", null: false
    t.datetime "first_response_at"
    t.datetime "waiting_since"
    t.datetime "solved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["customer_id"], name: "index_tickets_on_customer_id"
    t.index ["workspace_id", "status", "first_response_due_at"], name: "idx_ticket_queue"
    t.index ["workspace_id"], name: "index_tickets_on_workspace_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "workspace_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "email"], name: "index_users_on_workspace_id_and_email", unique: true
    t.index ["workspace_id"], name: "index_users_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "messages", "tickets"
  add_foreign_key "messages", "users", column: "author_id"
  add_foreign_key "ticket_events", "tickets"
  add_foreign_key "ticket_events", "users", column: "actor_id"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "customer_id"
  add_foreign_key "tickets", "workspaces"
  add_foreign_key "users", "workspaces"
end
