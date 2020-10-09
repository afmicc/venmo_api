class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.belongs_to :user
      t.text :content, null: false, default: ''
      t.timestamps
    end
  end
end
