Sequel.migration do
  up do
    create_table :chats do
      primary_key :id
      String :name, :size => 64
      String :occupation, :size => 128
      String :location, :size => 128
      String :message, :size => 600
      String :image, :size => 128 
      String :ad, :size => 128
      String :orientation, :size => 64
      
    
    end
  end

  down do
    drop_table :chats
  end
end
