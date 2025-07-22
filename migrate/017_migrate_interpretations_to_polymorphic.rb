Sequel.migration do
  up do
    # Copy existing speech_line_id to the new polymorphic columns
    # We check if the column exists for idempotency.
    if self[:interpretations].columns.include?(:speech_line_id)
      self[:interpretations].where(interpretable_id: nil).update(
        interpretable_id: :speech_line_id,
        interpretable_type: 'SpeechLine'
      )
    end
  end

  down do
    # To support a full rollback, we clear the data from the new columns.
    # The down step in the next migration (018) re-creates the old column.
    self[:interpretations].update(interpretable_id: nil, interpretable_type: nil)
  end
end