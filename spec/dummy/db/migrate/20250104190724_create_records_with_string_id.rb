class CreateRecordsWithStringId < ActiveRecord::Migration[8.0]
  def change
    create_table :records_with_string_id, id: :string do |t|
      t.timestamps
    end
  end
end
