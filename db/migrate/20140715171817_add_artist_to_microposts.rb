class AddArtistToMicroposts < ActiveRecord::Migration
  def change
    add_column :microposts, :artist, :string
  end
end
