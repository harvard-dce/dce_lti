class CreateDceLtiUsers < ActiveRecord::Migration
  def change
    create_table :dce_lti_users do |t|
      t.string :lti_user_id, nil: false
      t.string :lis_person_contact_email_primary, size: 1.kilobyte
      t.string :lis_person_name_family, size: 1.kilobyte
      t.string :lis_person_name_full, size: 1.kilobyte
      t.string :lis_person_name_given, size: 1.kilobyte
      t.string :lis_person_sourcedid, size: 1.kilobyte
      t.string :user_image, size: 1.kilobyte
      t.string :roles, array: true, default: []

      t.timestamps
    end
  end
end
