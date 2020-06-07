class CreateSesses < ActiveRecord::Migration[5.0]
  def change
    create_table :sesses do |t|
      t.string :variable
      t.string :value

      t.timestamps
    end
  end
end
