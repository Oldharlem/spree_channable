class AddSettingsToSettingsTable < ActiveRecord::Migration[5.0]
  def change
    change_table :channable_settings do |t|
      t.string :channable_api_key
      t.string :company_id
      t.string :project_id
    end
  end
end
