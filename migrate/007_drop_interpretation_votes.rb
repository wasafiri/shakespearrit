Sequel.migration do
  change do
    drop_table?(:interpretation_votes)
  end
end
