class CreateDceLtiNonces < ActiveRecord::Migration
  def change
    create_table :dce_lti_nonces do |t|
      t.string :nonce, nil: false
      t.timestamps
    end

    add_index :dce_lti_nonces, :nonce, unique: true
  end
end
