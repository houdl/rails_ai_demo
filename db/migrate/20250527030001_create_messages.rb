class CreateMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.text :content, null: false
      t.string :role, null: false

      t.timestamps
    end

    add_index :messages, [:chat_id, :created_at]
  end
end
