class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_digest
      t.string :otp_secret_key
      t.datetime :otp_generated_at
      t.boolean :two_factor_enabled

      t.timestamps
    end
  end
end
