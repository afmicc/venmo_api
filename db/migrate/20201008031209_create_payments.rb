class CreatePayments < ActiveRecord::Migration[6.0]
  def change
    create_table :payments do |t|
      t.belongs_to :sender, class_name: 'User'
      t.belongs_to :receiver, class_name: 'User'
      t.string :sender_email, null: false
      t.string :receiver_email, null: false
      t.float :amount, null: false, default: 0
      t.text :description, null: false, default: ''
      t.timestamps
    end
  end
end
