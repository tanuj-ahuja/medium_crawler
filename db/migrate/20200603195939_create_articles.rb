class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :name
      t.string :title
      t.string :date
      t.string :time
      t.string :link

      t.timestamps
    end
  end
end
