class AddContentToArticles < ActiveRecord::Migration[5.0]
  def change
    add_column :articles, :content, :string
  end
end
