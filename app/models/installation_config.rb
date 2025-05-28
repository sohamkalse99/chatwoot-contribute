class InstallationConfig < ApplicationRecord
  # Remove the serialize line entirely and handle JSON directly
  # since the column is already JSONB

  before_validation :set_lock
  validates :name, presence: true
  default_scope { order(created_at: :desc) }
  scope :editable, -> { where(locked: false) }
  after_commit :clear_cache

  def value
    return [] if new_record? && serialized_value.blank?

    # Handle different possible data structures
    if serialized_value.is_a?(Hash)
      # If serialized_value has a 'value' key, return that
      extracted_value = serialized_value.try(:[], 'value') || serialized_value.try(:[], :value)

      # If no 'value' key exists, return the entire hash if it looks like an array structure
      # Otherwise return empty array for consistency
      result = extracted_value || serialized_value

      # Ensure we return an array for compatibility with the + operator
      return result.is_a?(Array) ? result : []
    elsif serialized_value.is_a?(Array)
      # If it's already an array, return it as-is
      return serialized_value
    else
      # For any other data type, return empty array
      return []
    end
  end

  def value=(value_to_assigned)
    self.serialized_value = {
      'value' => value_to_assigned
    }
  end

  private

  def set_lock
    self.locked = true if locked.nil?
  end

  def clear_cache
    GlobalConfig.clear_cache
  end
end