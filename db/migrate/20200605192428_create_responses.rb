class CreateResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :responses do |t|
      t.string :responseContent
      t.references :article, foreign_key: true

      t.timestamps
    end
  end
end
